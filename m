Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D16986B01A3
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 01:52:16 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so6256471wib.8
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 22:52:15 -0700 (PDT)
Date: Fri, 14 Sep 2012 07:52:10 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 0/8] Avoid cache trashing on clearing huge/gigantic
 page
Message-ID: <20120914055210.GC9043@gmail.com>
References: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120913160506.d394392a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913160506.d394392a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 20 Aug 2012 16:52:29 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > Clearing a 2MB huge page will typically blow away several levels of CPU
> > caches.  To avoid this only cache clear the 4K area around the fault
> > address and use a cache avoiding clears for the rest of the 2MB area.
> > 
> > This patchset implements cache avoiding version of clear_page only for
> > x86. If an architecture wants to provide cache avoiding version of
> > clear_page it should to define ARCH_HAS_USER_NOCACHE to 1 and implement
> > clear_page_nocache() and clear_user_highpage_nocache().
> 
> Patchset looks nice to me, but the changelogs are terribly 
> short of performance measurements.  For this sort of change I 
> do think it is important that pretty exhaustive testing be 
> performed, and that the results (or a readable summary of 
> them) be shown.  And that testing should be designed to probe 
> for slowdowns, not just the speedups!

That is my general impression as well.

Firstly, doing before/after "perf stat --repeat 3 ..." runs 
showing a statistically significant effect on a workload that is 
expected to win from this, and on a workload expected to be 
hurting from this would go a long way towards convincing me.

Secondly, if you can find some user-space simulation of the 
intended positive (and negative) effects then a 'perf bench' 
testcase designed to show weakness of any such approach, running 
the very kernel assembly code in user-space would also be rather 
useful.

See:

comet:~/tip> git grep x86 tools/perf/bench/ | grep inclu
tools/perf/bench/mem-memcpy-arch.h:#include "mem-memcpy-x86-64-asm-def.h"
tools/perf/bench/mem-memcpy-x86-64-asm.S:#include "../../../arch/x86/lib/memcpy_64.S"
tools/perf/bench/mem-memcpy.c:#include "mem-memcpy-x86-64-asm-def.h"
tools/perf/bench/mem-memset-arch.h:#include "mem-memset-x86-64-asm-def.h"
tools/perf/bench/mem-memset-x86-64-asm.S:#include "../../../arch/x86/lib/memset_64.S"
tools/perf/bench/mem-memset.c:#include "mem-memset-x86-64-asm-def.h"

that code uses the kernel-side assembly code and runs it in 
user-space.

Although obviously clearing pages on page faults needs some care 
to properly simulate in user-space.

Without repeatable hard numbers such code just gets into the 
kernel and bitrots there as new CPU generations come in - a few 
years down the line the original decisions often degrade to pure 
noise. We've been there, we've done that, we don't want to 
repeat it.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
