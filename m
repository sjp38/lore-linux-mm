Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 0C3E06B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 10:41:47 -0500 (EST)
Message-ID: <4F2AAEB9.9070302@tilera.com>
Date: Thu, 2 Feb 2012 10:41:45 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327591185.2446.102.camel@twins> <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <20120201170443.GE6731@somewhere.redhat.com> <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
In-Reply-To: <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 2/2/2012 3:46 AM, Gilad Ben-Yossef wrote:
> On Wed, Feb 1, 2012 at 7:04 PM, Frederic Weisbecker <fweisbec@gmail.com> wrote:
>> Very nice especially as many people seem to be interested in CPU isolation.

Indeed!

> Yes, that is what drives me as well. I have a bare metal program
> I'm trying to kill here, I researched CPU isolation and ran into your
> nohz patch set and asked myself: "OK, if we disable the tick what else
> is on the way?"

At Tilera we have been supporting a "dataplane" mode (aka Zero Overhead
Linux - the marketing name).  This is configured on a per-cpu basis, and in
addition to setting isolcpus for those nodes, also suppresses various
things that might otherwise run (soft lockup detection, vmstat work,
etc.).  The claim is that you need to specify these kinds of things
per-core since it's not always possible for the kernel to know that you
really don't want the scheduler or any other interrupt source to touch the
core, as opposed to the case where you just happen to have a single process
scheduled on the core and you don't mind occasional interrupts.  But
there's definitely appeal in having the kernel do it adaptively too,
particularly if it can be made to work just as well as configuring it
statically.

We also have a set_dataplane() syscall that a task can make to allow it to
request some additional semantics from the kernel, such as various
debugging modes, a flag to request populating the page table fully, and a
flag to request that all pending kernel timer ticks, etc., happen while the
task spins in the kernel before actually returning to userspace from a
syscall (so you don't get unexpected interrupts once you're back in
userspace).  I've appended the relevant bits of <asm/dataplane.h> for more
details.

We've been planning to start working with the community on returning this,
but since fiddling with the scheduler is pretty tricky stuff and it wasn't
clear there was a lot of interest, we've been deferring it in favor of
other activities.  But seeing more about Frederic Weisbecker's and Gilad
Ben-Yossef's work makes me think that it might be a good time for us to
start that process.  For a start I'll see about putting up a git branch on
kernel.org that has our dataplane stuff in it, for reference.

/*
 * Quiesce the timer interrupt before returning to user space after a
 * system call.  Normally if a task on a dataplane core makes a
 * syscall, the system will run one or more timer ticks after the
 * syscall has completed, causing unexpected interrupts in userspace.
 * Setting DP_QUIESCE avoids that problem by having the kernel "hold"
 * the task in kernel mode until the timer ticks are complete.  This
 * will make syscalls dramatically slower.
 *
 * If multiple dataplane tasks are scheduled on a single core, this
 * in effect silently disables DP_QUIESCE, which allows the tasks to make
 * progress, but without actually disabling the timer tick.
 */
#define DP_QUIESCE      0x1

/*
 * Disallow the application from entering the kernel in any way,
 * unless it calls set_dataplane() again without this bit set.
 * Issuing any other syscall or causing a page fault would generate a
 * kernel message, and "kill -9" the process.
 *
 * Setting this flag automatically sets DP_QUIESCE as well.
 */
#define DP_STRICT       0x2

/*
 * Debug dataplane interrupts, so that if any interrupt source
 * attempts to involve a dataplane cpu, a kernel message and stack
 * backtrace will be generated on the console.  As this warning is a
 * slow event, it may make sense to avoid this mode in production code
 * to avoid making any possible interrupts even more heavyweight.
 *
 * Setting this flag automatically sets DP_QUIESCE as well.
 */
#define DP_DEBUG        0x4

/*
 * Cause all memory mappings to be populated in the page table.
 * Specifying this when entering dataplane mode ensures that no future
 * page fault events will occur to cause interrupts into the Linux
 * kernel, as long as no new mappings are installed by mmap(), etc.
 * Note that since the hardware TLB is of finite size, there will
 * still be the potential for TLB misses that the hypervisor handles,
 * either via its software TLB cache (fast path) or by walking the
 * kernel page tables (slow path), so touching large amounts of memory
 * will still incur hypervisor interrupt overhead.
 */
#define DP_POPULATE     0x8


-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
