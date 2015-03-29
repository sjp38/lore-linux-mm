Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id D26466B0072
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 08:01:34 -0400 (EDT)
Received: by oicf142 with SMTP id f142so98425412oic.3
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 05:01:34 -0700 (PDT)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com. [209.85.214.170])
        by mx.google.com with ESMTPS id 184si4341516oim.124.2015.03.29.05.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 05:01:33 -0700 (PDT)
Received: by obbgh1 with SMTP id gh1so38840780obb.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 05:01:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150328134457.GK27490@worktop.programming.kicks-ass.net>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
	<20150328095322.GH27490@worktop.programming.kicks-ass.net>
	<55169723.3070006@linaro.org>
	<20150328134457.GK27490@worktop.programming.kicks-ass.net>
Date: Sun, 29 Mar 2015 17:31:32 +0530
Message-ID: <CAKohpokgT+PfczvpBV2zEzuGMvu0VY50L7EGtyxvLkY2C9z2hQ@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 28 March 2015 at 19:14, Peter Zijlstra <peterz@infradead.org> wrote:
> Yeah, something like the below (at the very end) should ensure the thing
> is cacheline aligned, that should give us a fair few bits.

> ---
>  kernel/time/timer.c | 36 ++++++++----------------------------
>  1 file changed, 8 insertions(+), 28 deletions(-)
>
> diff --git a/kernel/time/timer.c b/kernel/time/timer.c
> index 2d3f5c504939..c8c45bf50b2e 100644
> --- a/kernel/time/timer.c
> +++ b/kernel/time/timer.c
> @@ -93,6 +93,7 @@ struct tvec_base {
>  struct tvec_base boot_tvec_bases;
>  EXPORT_SYMBOL(boot_tvec_bases);
>  static DEFINE_PER_CPU(struct tvec_base *, tvec_bases) = &boot_tvec_bases;
> +static DEFINE_PER_CPU(struct tvec_base, __tvec_bases);
>
>  /* Functions below help us manage 'deferrable' flag */
>  static inline unsigned int tbase_get_deferrable(struct tvec_base *base)
> @@ -1534,46 +1535,25 @@ EXPORT_SYMBOL(schedule_timeout_uninterruptible);
>
>  static int init_timers_cpu(int cpu)
>  {
> -       int j;
> -       struct tvec_base *base;
> +       struct tvec_base *base = per_cpu(tvec_bases, cpu);
>         static char tvec_base_done[NR_CPUS];
> +       int j;
>
>         if (!tvec_base_done[cpu]) {
>                 static char boot_done;
>
> -               if (boot_done) {
> -                       /*
> -                        * The APs use this path later in boot
> -                        */
> -                       base = kzalloc_node(sizeof(*base), GFP_KERNEL,
> -                                           cpu_to_node(cpu));
> -                       if (!base)
> -                               return -ENOMEM;
> -
> -                       /* Make sure tvec_base has TIMER_FLAG_MASK bits free */
> -                       if (WARN_ON(base != tbase_get_base(base))) {
> -                               kfree(base);
> -                               return -ENOMEM;
> -                       }
> -                       per_cpu(tvec_bases, cpu) = base;
> +               if (!boot_done) {
> +                       boot_done = 1; /* skip the boot cpu */
>                 } else {
> -                       /*
> -                        * This is for the boot CPU - we use compile-time
> -                        * static initialisation because per-cpu memory isn't
> -                        * ready yet and because the memory allocators are not
> -                        * initialised either.
> -                        */
> -                       boot_done = 1;
> -                       base = &boot_tvec_bases;
> +                       base = per_cpu_ptr(&__tvec_bases);
> +                       per_cpu(tvec_bases, cpu) = base;
>                 }
> +
>                 spin_lock_init(&base->lock);
>                 tvec_base_done[cpu] = 1;
>                 base->cpu = cpu;
> -       } else {
> -               base = per_cpu(tvec_bases, cpu);
>         }
>
> -
>         for (j = 0; j < TVN_SIZE; j++) {
>                 INIT_LIST_HEAD(base->tv5.vec + j);
>                 INIT_LIST_HEAD(base->tv4.vec + j);

Even after this with following diff gives me the same warning on blackfin..

diff --git a/include/linux/timer.h b/include/linux/timer.h
index 8c5a197e1587..58bc28d9cef2 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -68,7 +68,7 @@ extern struct tvec_base boot_tvec_bases;
 #define TIMER_DEFERRABLE               0x1LU
 #define TIMER_IRQSAFE                  0x2LU

-#define TIMER_FLAG_MASK                        0x3LU
+#define TIMER_FLAG_MASK                        0x7LU

 #define __TIMER_INITIALIZER(_function, _expires, _data, _flags) { \
                .entry = { .prev = TIMER_ENTRY_STATIC },        \


---------x--------------------x----------------------

Warning:

config: blackfin-allyesconfig (attached as .config)
reproduce:
  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross
-O ~/bin/make.cross
  chmod +x ~/bin/make.cross
  git checkout ca713e393c6eceb54e803df204772a3d6e6c7981
  # save the attached .config to linux build tree
  make.cross ARCH=blackfin

All error/warnings:

   kernel/time/timer.c: In function 'init_timers':
>> kernel/time/timer.c:1648:2: error: call to '__compiletime_assert_1648' declared with attribute error: BUILD_BUG_ON failed: __alignof__(struct tvec_base) & TIMER_FLAG_MASK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
