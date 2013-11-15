Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id B1B8A6B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 17:01:40 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so4121030pbc.26
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:01:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.136])
        by mx.google.com with SMTP id hb3si3123574pac.7.2013.11.15.14.01.37
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 14:01:39 -0800 (PST)
Received: by mail-ve0-f181.google.com with SMTP id jx11so3446117veb.12
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 14:01:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Nov 2013 14:01:36 -0800
Message-ID: <CA+8MBbL-WpcC6_wfZeFW6Buqq0p1PStH5ScF-USHae40H3MXfg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: Properly separate the bloated ptl from the
 regular case
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 7, 2013 at 6:14 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:

> diff --git a/kernel/bounds.c b/kernel/bounds.c
> index e8ca97b5c386..578782ef6ae1 100644
> --- a/kernel/bounds.c
> +++ b/kernel/bounds.c
> @@ -11,6 +11,7 @@
>  #include <linux/kbuild.h>
>  #include <linux/page_cgroup.h>
>  #include <linux/log2.h>
> +#include <linux/spinlock.h>
>
>  void foo(void)
>  {
> @@ -21,5 +22,6 @@ void foo(void)
>  #ifdef CONFIG_SMP
>         DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
>  #endif
> +       DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(int));
>         /* End of constants */
>  }

This patch arrived in Linus' tree today - and broke the ia64 build :-(

  CC      kernel/bounds.s
In file included from
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:9,
                 from include/linux/thread_info.h:54,
                 from include/asm-generic/preempt.h:4,
                 from arch/ia64/include/generated/asm/preempt.h:1,
                 from include/linux/preempt.h:18,
                 from include/linux/spinlock.h:50,
                 from kernel/bounds.c:14:
/home/aegl/generic-smp/arch/ia64/include/asm/asm-offsets.h:1:35:
error: generated/asm-offsets.h: No such file or directory
In file included from include/linux/thread_info.h:54,
                 from include/asm-generic/preempt.h:4,
                 from arch/ia64/include/generated/asm/preempt.h:1,
                 from include/linux/preempt.h:18,
                 from include/linux/spinlock.h:50,
                 from kernel/bounds.c:14:
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h: In
function 'set_restore_sigmask':
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:138: error:
'IA64_TASK_SIZE' undeclared (first use in this function)
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:138: error:
(Each undeclared identifier is reported only once
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:138: error:
for each function it appears in.)
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h: In
function 'clear_restore_sigmask':
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:144: error:
'IA64_TASK_SIZE' undeclared (first use in this function)
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h: In
function 'test_restore_sigmask':
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:148: error:
'IA64_TASK_SIZE' undeclared (first use in this function)
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h: In
function 'test_and_clear_restore_sigmask':
/home/aegl/generic-smp/arch/ia64/include/asm/thread_info.h:152: error:
'IA64_TASK_SIZE' undeclared (first use in this function)
In file included from arch/ia64/include/generated/asm/preempt.h:1,
                 from include/linux/preempt.h:18,
                 from include/linux/spinlock.h:50,
                 from kernel/bounds.c:14:
include/asm-generic/preempt.h: In function 'preempt_count':
include/asm-generic/preempt.h:12: error: 'IA64_TASK_SIZE' undeclared
(first use in this function)
include/asm-generic/preempt.h: In function 'preempt_count_ptr':
include/asm-generic/preempt.h:17: error: 'IA64_TASK_SIZE' undeclared
(first use in this function)
make[1]: *** [kernel/bounds.s] Error 1
make: *** [prepare0] Error 2
make: *** Waiting for unfinished jobs....

The problem is somewhat circular: IA64_TASK_SIZE will later be defined
by asm-offsets.h,
but we haven't even tried to generate that yet.

My "grep" skills are failing to find the Makefile that decides it wants to build
kernel/bounds.s so early :-(

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
