Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49F706B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 01:35:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 68so77354462lfq.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:35:30 -0700 (PDT)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id c135si18541348lfc.193.2016.05.08.22.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 22:35:28 -0700 (PDT)
Received: by mail-lf0-x22e.google.com with SMTP id u64so188489492lff.3
        for <linux-mm@kvack.org>; Sun, 08 May 2016 22:35:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160506115048.GA2611@cherokee.in.rdlabs.hpecorp.net>
References: <20160506115048.GA2611@cherokee.in.rdlabs.hpecorp.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 9 May 2016 07:35:08 +0200
Message-ID: <CACT4Y+Zwv6J+8ovnXAb4EbsHWf4J-8cKr-h25Ucxq5T3kjSn=A@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] kasan: add kasan_double_free() test
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, May 6, 2016 at 1:50 PM, Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com> wrote:
> This patch adds a new 'test_kasan' test for KASAN double-free error
> detection when the same slab object is concurrently deallocated.
>
> Signed-off-by: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
> ---
> Changes in v2:
> - This patch is new for v2.
> ---
>  lib/test_kasan.c |   79 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 79 insertions(+), 0 deletions(-)
>
> diff --git a/lib/test_kasan.c b/lib/test_kasan.c
> index bd75a03..dec5f74 100644
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -16,6 +16,7 @@
>  #include <linux/slab.h>
>  #include <linux/string.h>
>  #include <linux/module.h>
> +#include <linux/kthread.h>
>
>  static noinline void __init kmalloc_oob_right(void)
>  {
> @@ -389,6 +390,83 @@ static noinline void __init ksize_unpoisons_memory(void)
>         kfree(ptr);
>  }
>
> +#ifdef CONFIG_SLAB
> +#ifdef CONFIG_SMP

Will it fail without CONFIG_SMP if we create more than 1 kthread? If
it does not fail, then please remove the ifdef.
Also see below.


> +static DECLARE_COMPLETION(starting_gun);
> +static DECLARE_COMPLETION(finish_line);
> +
> +static int try_free(void *p)
> +{
> +       wait_for_completion(&starting_gun);
> +       kfree(p);
> +       complete(&finish_line);
> +       return 0;
> +}
> +
> +/*
> + * allocs an object; then all cpus concurrently attempt to free the
> + * same object.
> + */
> +static noinline void __init kasan_double_free(void)
> +{
> +       char *p;
> +       int cpu;
> +       struct task_struct **tasks;
> +       size_t size = (KMALLOC_MAX_CACHE_SIZE/4 + 1);

Is it important to use such tricky size calculation here? If it is not
important, then please replace it with some small constant.
There are some tests that calculate size based on
KMALLOC_MAX_CACHE_SIZE, but that's important for them.



> +       /*
> +        * max slab size instrumented by KASAN is KMALLOC_MAX_CACHE_SIZE/2.
> +        * Do not increase size beyond this: slab corruption from double-free
> +        * may ensue.
> +        */
> +       pr_info("concurrent double-free test\n");
> +       init_completion(&starting_gun);
> +       init_completion(&finish_line);
> +       tasks = kzalloc((sizeof(tasks) * nr_cpu_ids), GFP_KERNEL);
> +       if (!tasks) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +       p = kmalloc(size, GFP_KERNEL);
> +       if (!p) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +
> +       for_each_online_cpu(cpu) {


Won't the test fail with 1 cpu?
By failing I mean that it won't detect the double-free. Soon we will
start automatically ensuring that a double-free test in fact detects a
double-free.
I think it will be much simpler to use just, say, 4 threads. It will
eliminate kzmalloc, kfree, allocation failure tests, memory leaks and
also fix !CONFIG_SMP.



> +               tasks[cpu] = kthread_create(try_free, (void *)p, "try_free%d",
> +                               cpu);
> +               if (IS_ERR(tasks[cpu])) {
> +                       WARN(1, "kthread_create failed.\n");
> +                       return;
> +               }
> +               kthread_bind(tasks[cpu], cpu);
> +               wake_up_process(tasks[cpu]);
> +       }
> +
> +       complete_all(&starting_gun);
> +       for_each_online_cpu(cpu)
> +               wait_for_completion(&finish_line);
> +       kfree(tasks);
> +}
> +#else
> +static noinline void __init kasan_double_free(void)

This test should work with CONFIG_SLAB as well.
Please name the tests differently (e.g. kasan_double_free and
kasan_double_free_threaded), and run kasan_double_free always.
If kasan_double_free_threaded fails, but kasan_double_free does not,
that's already some useful info. And if both fail, then it's always
better to have a simpler reproducer.


> +{
> +       char *p;
> +       size_t size = 2049;
> +
> +       pr_info("double-free test\n");
> +       p = kmalloc(size, GFP_KERNEL);
> +       if (!p) {
> +               pr_err("Allocation failed\n");
> +               return;
> +       }
> +       kfree(p);
> +       kfree(p);
> +}
> +#endif
> +#endif
> +
>  static int __init kmalloc_tests_init(void)
>  {
>         kmalloc_oob_right();
> @@ -414,6 +492,7 @@ static int __init kmalloc_tests_init(void)
>         kasan_global_oob();
>  #ifdef CONFIG_SLAB
>         kasan_quarantine_cache();
> +       kasan_double_free();
>  #endif
>         ksize_unpoisons_memory();
>         return -EAGAIN;
> --
> 1.7.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
