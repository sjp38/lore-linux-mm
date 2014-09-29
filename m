Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 957716B003A
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 10:27:52 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so1873573qgf.21
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:27:52 -0700 (PDT)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id w2si13743554qab.9.2014.09.29.07.27.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 07:27:51 -0700 (PDT)
Received: by mail-qg0-f49.google.com with SMTP id q107so11818752qgd.8
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 07:27:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com> <1411562649-28231-14-git-send-email-a.ryabinin@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 Sep 2014 18:27:30 +0400
Message-ID: <CACT4Y+aPNJ6c_FDTG75PFhCKToZuzqTdZN+njPOdQSLoCx7R2A@mail.gmail.com>
Subject: Re: [RFC PATCH v3 13/13] kasan: introduce inline instrumentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Marek <mmarek@suse.cz>

On Wed, Sep 24, 2014 at 4:44 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> This patch only demonstration how easy this could be achieved.
> GCC doesn't support this feature yet. Two patches required for this:
>     https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00452.html
>     https://gcc.gnu.org/ml/gcc-patches/2014-09/msg00605.html
>
> In inline instrumentation mode compiler directly inserts code
> checking shadow memory instead of __asan_load/__asan_store
> calls.
> This is usually faster than outline. In some workloads inline is
> 2 times faster than outline instrumentation.
>
> The downside of inline instrumentation is bloated kernel's .text size:
>
> size noasan/vmlinux
>    text     data     bss      dec     hex    filename
> 11759720  1566560  946176  14272456  d9c7c8  noasan/vmlinux
>
> size outline/vmlinux
>    text    data     bss      dec      hex    filename
> 16553474  1602592  950272  19106338  1238a22 outline/vmlinux
>
> size inline/vmlinux
>    text    data     bss      dec      hex    filename
> 32064759  1598688  946176  34609623  21019d7 inline/vmlinux
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  Makefile          |  5 +++++
>  lib/Kconfig.kasan | 24 ++++++++++++++++++++++++
>  mm/kasan/report.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 74 insertions(+)
>
> diff --git a/Makefile b/Makefile
> index 6cefe5e..fe7c534 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -773,6 +773,11 @@ KBUILD_CFLAGS += $(call cc-option, -fno-inline-functions-called-once)
>  endif
>
>  ifdef CONFIG_KASAN
> +ifdef CONFIG_KASAN_INLINE
> +CFLAGS_KASAN += $(call cc-option, -fasan-shadow-offset=$(CONFIG_KASAN_SHADOW_OFFSET)) \
> +                $(call cc-option, --param asan-instrumentation-with-call-threshold=10000)
> +endif
> +
>    ifeq ($(CFLAGS_KASAN),)
>      $(warning Cannot use CONFIG_KASAN: \
>               -fsanitize=kernel-address not supported by compiler)
> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
> index faddb0e..c4ac040 100644
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -27,4 +27,28 @@ config TEST_KASAN
>           out of bounds accesses, use after free. It is usefull for testing
>           kernel debugging features like kernel address sanitizer.
>
> +choice
> +       prompt "Instrumentation type"
> +       depends on KASAN
> +       default KASAN_INLINE if X86_64
> +
> +config KASAN_OUTLINE
> +       bool "Outline instrumentation"
> +       help
> +         Before every memory access compiler insert function call
> +         __asan_load*/__asan_store*. These functions performs check
> +         of shadow memory. This is slower than inline instrumentation,
> +         however it doesn't bloat size of kernel's .text section so
> +         much as inline does.
> +
> +config KASAN_INLINE
> +       bool "Inline instrumentation"
> +       help
> +         Compiler directly inserts code checking shadow memory before
> +         memory accesses. This is faster than outline (in some workloads
> +         it gives about x2 boost over outline instrumentation), but
> +         make kernel's .text size much bigger.
> +
> +endchoice
> +
>  endif
> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
> index c42f6ba..a9262f8 100644
> --- a/mm/kasan/report.c
> +++ b/mm/kasan/report.c
> @@ -212,3 +212,48 @@ void kasan_report_user_access(struct access_info *info)
>                 "=================================\n");
>         spin_unlock_irqrestore(&report_lock, flags);
>  }
> +
> +#define CALL_KASAN_REPORT(__addr, __size, __is_write) \
> +       struct access_info info;                      \
> +       info.access_addr = __addr;                    \
> +       info.access_size = __size;                    \
> +       info.is_write = __is_write;                   \
> +       info.ip = _RET_IP_;                           \
> +       kasan_report_error(&info)


Make it a function. And also call it from check_memory_region.
It uses _RET_IP_, but check_memory_region uses _RET_IP_ as well and
relies on __always_inline.


Otherwise looks good to me.


> +#define DEFINE_ASAN_REPORT_LOAD(size)                     \
> +void __asan_report_recover_load##size(unsigned long addr) \
> +{                                                         \
> +       CALL_KASAN_REPORT(addr, size, false);             \
> +}                                                         \
> +EXPORT_SYMBOL(__asan_report_recover_load##size)
> +
> +#define DEFINE_ASAN_REPORT_STORE(size)                     \
> +void __asan_report_recover_store##size(unsigned long addr) \
> +{                                                          \
> +       CALL_KASAN_REPORT(addr, size, true);               \
> +}                                                          \
> +EXPORT_SYMBOL(__asan_report_recover_store##size)
> +
> +DEFINE_ASAN_REPORT_LOAD(1);
> +DEFINE_ASAN_REPORT_LOAD(2);
> +DEFINE_ASAN_REPORT_LOAD(4);
> +DEFINE_ASAN_REPORT_LOAD(8);
> +DEFINE_ASAN_REPORT_LOAD(16);
> +DEFINE_ASAN_REPORT_STORE(1);
> +DEFINE_ASAN_REPORT_STORE(2);
> +DEFINE_ASAN_REPORT_STORE(4);
> +DEFINE_ASAN_REPORT_STORE(8);
> +DEFINE_ASAN_REPORT_STORE(16);
> +
> +void __asan_report_recover_load_n(unsigned long addr, size_t size)
> +{
> +       CALL_KASAN_REPORT(addr, size, false);
> +}
> +EXPORT_SYMBOL(__asan_report_recover_load_n);
> +
> +void __asan_report_recover_store_n(unsigned long addr, size_t size)
> +{
> +       CALL_KASAN_REPORT(addr, size, true);
> +}
> +EXPORT_SYMBOL(__asan_report_recover_store_n);
> --
> 2.1.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
