Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7013E6B13F3
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:38:36 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1RvvMh-0007C2-7n
	for linux-mm@kvack.org; Fri, 10 Feb 2012 18:38:35 +0000
Received: from 178-85-86-190.dynamic.upc.nl ([178.85.86.190] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RvvMg-0006P2-QZ
	for linux-mm@kvack.org; Fri, 10 Feb 2012 18:38:35 +0000
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4F2AAEB9.9070302@tilera.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	 <1327591185.2446.102.camel@twins>
	 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	 <20120201170443.GE6731@somewhere.redhat.com>
	 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	 <4F2AAEB9.9070302@tilera.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Feb 2012 19:38:25 +0100
Message-ID: <1328899105.25989.37.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
> 
> /*
>  * Quiesce the timer interrupt before returning to user space after a
>  * system call.  Normally if a task on a dataplane core makes a
>  * syscall, the system will run one or more timer ticks after the
>  * syscall has completed, causing unexpected interrupts in userspace.
>  * Setting DP_QUIESCE avoids that problem by having the kernel "hold"
>  * the task in kernel mode until the timer ticks are complete.  This
>  * will make syscalls dramatically slower.
>  *
>  * If multiple dataplane tasks are scheduled on a single core, this
>  * in effect silently disables DP_QUIESCE, which allows the tasks to make
>  * progress, but without actually disabling the timer tick.
>  */
> #define DP_QUIESCE      0x1

This is what Frederics work does

> 
> /*
>  * Disallow the application from entering the kernel in any way,
>  * unless it calls set_dataplane() again without this bit set.
>  * Issuing any other syscall or causing a page fault would generate a
>  * kernel message, and "kill -9" the process.
>  *
>  * Setting this flag automatically sets DP_QUIESCE as well.
>  */
> #define DP_STRICT       0x2

This is a debug feature.. you'd better know what your own software does.

> 
> /*
>  * Debug dataplane interrupts, so that if any interrupt source
>  * attempts to involve a dataplane cpu, a kernel message and stack
>  * backtrace will be generated on the console.  As this warning is a
>  * slow event, it may make sense to avoid this mode in production code
>  * to avoid making any possible interrupts even more heavyweight.
>  *
>  * Setting this flag automatically sets DP_QUIESCE as well.
>  */
> #define DP_DEBUG        0x4

This too is a debug feature, one that doesn't cover all possible
scenarios.

> /*
>  * Cause all memory mappings to be populated in the page table.
>  * Specifying this when entering dataplane mode ensures that no future
>  * page fault events will occur to cause interrupts into the Linux
>  * kernel, as long as no new mappings are installed by mmap(), etc.
>  * Note that since the hardware TLB is of finite size, there will
>  * still be the potential for TLB misses that the hypervisor handles,
>  * either via its software TLB cache (fast path) or by walking the
>  * kernel page tables (slow path), so touching large amounts of memory
>  * will still incur hypervisor interrupt overhead.
>  */
> #define DP_POPULATE     0x8 

map()s MAP_POPULATE will pre-populate the stuff for you, as will
mlock(), the latter will (mostly) ensure they stay around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
