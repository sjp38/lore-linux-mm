Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAD3E8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:55:31 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id g7so1906977itg.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:55:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor6793211ioa.135.2018.12.11.02.55.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 02:55:30 -0800 (PST)
MIME-Version: 1.0
References: <20181211103733.22284-1-anders.roxell@linaro.org>
In-Reply-To: <20181211103733.22284-1-anders.roxell@linaro.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 11 Dec 2018 11:55:18 +0100
Message-ID: <CACT4Y+Yz36BDR6WJ0WrPLHd+Z2WpJFhqm=Hv8_VoC7CJ8GEh=Q@mail.gmail.com>
Subject: Re: [PATCH] kasan: mark kasan_check_(read|write) as 'notrace'
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anders.roxell@linaro.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Steven Rostedt <rostedt@goodmis.org>

On Tue, Dec 11, 2018 at 11:37 AM Anders Roxell <anders.roxell@linaro.org> wrote:
>
> When option CONFIG_KASAN is enabled toghether with ftrace, function
> ftrace_graph_caller() gets in to a recursion, via functions
> kasan_check_read() and kasan_check_write().
>
>  Breakpoint 2, ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:179
>  179             mcount_get_pc             x0    //     function's pc
>  (gdb) bt
>  #0  ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:179
>  #1  0xffffff90101406c8 in ftrace_caller () at ../arch/arm64/kernel/entry-ftrace.S:151
>  #2  0xffffff90106fd084 in kasan_check_write (p=0xffffffc06c170878, size=4) at ../mm/kasan/common.c:105
>  #3  0xffffff90104a2464 in atomic_add_return (v=<optimized out>, i=<optimized out>) at ./include/generated/atomic-instrumented.h:71
>  #4  atomic_inc_return (v=<optimized out>) at ./include/generated/atomic-fallback.h:284
>  #5  trace_graph_entry (trace=0xffffffc03f5ff380) at ../kernel/trace/trace_functions_graph.c:441
>  #6  0xffffff9010481774 in trace_graph_entry_watchdog (trace=<optimized out>) at ../kernel/trace/trace_selftest.c:741
>  #7  0xffffff90104a185c in function_graph_enter (ret=<optimized out>, func=<optimized out>, frame_pointer=18446743799894897728, retp=<optimized out>) at ../kernel/trace/trace_functions_graph.c:196
>  #8  0xffffff9010140628 in prepare_ftrace_return (self_addr=18446743592948977792, parent=0xffffffc03f5ff418, frame_pointer=18446743799894897728) at ../arch/arm64/kernel/ftrace.c:231
>  #9  0xffffff90101406f4 in ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:182
>  Backtrace stopped: previous frame identical to this frame (corrupt stack?)
>  (gdb)
>
> Rework so that kasan_check_read() and kasan_check_write() is marked with
> 'notrace'.
>
> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
> ---
>  mm/kasan/common.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 03d5d1374ca7..71507d15712b 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -95,13 +95,13 @@ void kasan_disable_current(void)
>         current->kasan_depth--;
>  }
>
> -void kasan_check_read(const volatile void *p, unsigned int size)
> +void notrace kasan_check_read(const volatile void *p, unsigned int size)
>  {
>         check_memory_region((unsigned long)p, size, false, _RET_IP_);
>  }
>  EXPORT_SYMBOL(kasan_check_read);
>
> -void kasan_check_write(const volatile void *p, unsigned int size)
> +void notrace kasan_check_write(const volatile void *p, unsigned int size)
>  {
>         check_memory_region((unsigned long)p, size, true, _RET_IP_);
>  }

Hi Anders,

Thanks for fixing this!

I wonder if there is some compiler/make flag to turn this off for the
whole file?

We turn as much instrumentation as possible already for this file in Makefile:

KASAN_SANITIZE := n
UBSAN_SANITIZE_kasan.o := n
KCOV_INSTRUMENT := n
CFLAGS_REMOVE_kasan.o = -pg
CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)

These functions call check_memory_region, which is presumably inlined.
But if it's not inlined later in some configuration, or we just
shuffle code a bit, we can get the same problem again.
