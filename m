Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF996B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:42:18 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id a3so337227oib.0
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:42:18 -0800 (PST)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id p8si805871obx.27.2014.11.25.04.42.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 04:42:17 -0800 (PST)
Received: by mail-oi0-f53.google.com with SMTP id x69so315621oia.26
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 04:42:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1416852146-9781-3-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1416852146-9781-1-git-send-email-a.ryabinin@samsung.com> <1416852146-9781-3-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Chernenkov <dmitryc@google.com>
Date: Tue, 25 Nov 2014 16:41:56 +0400
Message-ID: <CAA6XgkEzNYgRrUpDGwLeAMrjOotw9qPZbHdXkPX7E9xJ-v97-Q@mail.gmail.com>
Subject: Re: [PATCH v7 02/12] x86_64: load_percpu_segment: read
 irq_stack_union.gs_base before load_segment
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

LGTM

On Mon, Nov 24, 2014 at 9:02 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> Reading irq_stack_union.gs_base after load_segment creates troubles for kasan.
> Compiler inserts __asan_load in between load_segment and wrmsrl. If kernel
> built with stackprotector this will result in boot failure because __asan_load
> has stackprotector.
>
> To avoid this irq_stack_union.gs_base stored to temporary variable before
> load_segment, so __asan_load will be called before load_segment().
>
> There are two alternative ways to fix this:
>  a) Add __attribute__((no_sanitize_address)) to load_percpu_segment(),
>     which tells compiler to not instrument this function. However this
>     will result in build failure with CONFIG_KASAN=y and CONFIG_OPTIMIZE_INLINING=y.
>
>  b) Add -fno-stack-protector for mm/kasan/kasan.c
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  arch/x86/kernel/cpu/common.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
> index 8779d63..97f56f6 100644
> --- a/arch/x86/kernel/cpu/common.c
> +++ b/arch/x86/kernel/cpu/common.c
> @@ -389,8 +389,10 @@ void load_percpu_segment(int cpu)
>  #ifdef CONFIG_X86_32
>         loadsegment(fs, __KERNEL_PERCPU);
>  #else
> +       void *gs_base = per_cpu(irq_stack_union.gs_base, cpu);
> +
>         loadsegment(gs, 0);
> -       wrmsrl(MSR_GS_BASE, (unsigned long)per_cpu(irq_stack_union.gs_base, cpu));
> +       wrmsrl(MSR_GS_BASE, (unsigned long)gs_base);
>  #endif
>         load_stack_canary_segment();
>  }
> --
> 2.1.3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
