Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4B94B6B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 06:46:28 -0500 (EST)
Received: by vcbf13 with SMTP id f13so4397069vcb.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 03:46:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F2AAEB9.9070302@tilera.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
	<CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	<4F2AAEB9.9070302@tilera.com>
Date: Sun, 5 Feb 2012 13:46:25 +0200
Message-ID: <CAOtvUMfE3xpwmRKnFPTsstr3SuUG7SnpWn5eomEQzkap4_nfrg@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 2, 2012 at 5:41 PM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> On 2/2/2012 3:46 AM, Gilad Ben-Yossef wrote:
>
>> Yes, that is what drives me as well. I have a bare metal program
>> I'm trying to kill here, I researched CPU isolation and ran into your
>> nohz patch set and asked myself: "OK, if we disable the tick what else
>> is on the way?"
>
> At Tilera we have been supporting a "dataplane" mode (aka Zero Overhead
> Linux - the marketing name). =A0This is configured on a per-cpu basis, an=
d in
> addition to setting isolcpus for those nodes, also suppresses various
> things that might otherwise run (soft lockup detection, vmstat work,
> etc.). =A0The claim is that you need to specify these kinds of things
> per-core since it's not always possible for the kernel to know that you
> really don't want the scheduler or any other interrupt source to touch th=
e
> core, as opposed to the case where you just happen to have a single proce=
ss
> scheduled on the core and you don't mind occasional interrupts. =A0But
> there's definitely appeal in having the kernel do it adaptively too,
> particularly if it can be made to work just as well as configuring it
> statically.

Currently adaptive tick needs to be enabled as a cpuset property in
order to apply,
but once enabled it is activated automatically when feasible.

The combination of per cpuset enabling and automatic activation makes
sense to me
since cpuset is the way to go to isolate cpus for specific tasks going forw=
ard.
>
> We also have a set_dataplane() syscall that a task can make to allow it t=
o
> request some additional semantics from the kernel, such as various
> debugging modes, a flag to request populating the page table fully, and a
> flag to request that all pending kernel timer ticks, etc., happen while t=
he
> task spins in the kernel before actually returning to userspace from a
> syscall (so you don't get unexpected interrupts once you're back in
> userspace).

Oohh.. I like that :-)

> I've appended the relevant bits of <asm/dataplane.h> for more
> details.
>
> We've been planning to start working with the community on returning this=
,
> but since fiddling with the scheduler is pretty tricky stuff and it wasn'=
t
> clear there was a lot of interest, we've been deferring it in favor of
> other activities. =A0But seeing more about Frederic Weisbecker's and Gila=
d
> Ben-Yossef's work makes me think that it might be a good time for us to
> start that process. =A0For a start I'll see about putting up a git branch=
 on
> kernel.org that has our dataplane stuff in it, for reference.
>

This sounds very interesting. Thanks you!

I for one will be delighted to see that tree as a reference. There is nothi=
ng
I hate more then re-inventing the wheel... :-)

> /*
> =A0* Quiesce the timer interrupt before returning to user space after a
> =A0* system call. =A0Normally if a task on a dataplane core makes a
> =A0* syscall, the system will run one or more timer ticks after the
> =A0* syscall has completed, causing unexpected interrupts in userspace.
> =A0* Setting DP_QUIESCE avoids that problem by having the kernel "hold"
> =A0* the task in kernel mode until the timer ticks are complete. =A0This
> =A0* will make syscalls dramatically slower.
> =A0*
> =A0* If multiple dataplane tasks are scheduled on a single core, this
> =A0* in effect silently disables DP_QUIESCE, which allows the tasks to ma=
ke
> =A0* progress, but without actually disabling the timer tick.
> =A0*/
> #define DP_QUIESCE =A0 =A0 =A00x1
>
> /*
> =A0* Disallow the application from entering the kernel in any way,
> =A0* unless it calls set_dataplane() again without this bit set.
> =A0* Issuing any other syscall or causing a page fault would generate a
> =A0* kernel message, and "kill -9" the process.
> =A0*
> =A0* Setting this flag automatically sets DP_QUIESCE as well.
> =A0*/
> #define DP_STRICT =A0 =A0 =A0 0x2
>
> /*
> =A0* Debug dataplane interrupts, so that if any interrupt source
> =A0* attempts to involve a dataplane cpu, a kernel message and stack
> =A0* backtrace will be generated on the console. =A0As this warning is a
> =A0* slow event, it may make sense to avoid this mode in production code
> =A0* to avoid making any possible interrupts even more heavyweight.
> =A0*
> =A0* Setting this flag automatically sets DP_QUIESCE as well.
> =A0*/
> #define DP_DEBUG =A0 =A0 =A0 =A00x4
>
> /*
> =A0* Cause all memory mappings to be populated in the page table.
> =A0* Specifying this when entering dataplane mode ensures that no future
> =A0* page fault events will occur to cause interrupts into the Linux
> =A0* kernel, as long as no new mappings are installed by mmap(), etc.
> =A0* Note that since the hardware TLB is of finite size, there will
> =A0* still be the potential for TLB misses that the hypervisor handles,
> =A0* either via its software TLB cache (fast path) or by walking the
> =A0* kernel page tables (slow path), so touching large amounts of memory
> =A0* will still incur hypervisor interrupt overhead.
> =A0*/
> #define DP_POPULATE =A0 =A0 0x8

hmm... I've probably missed something, but doesn't this replicate
mlockall (MCL_CURRENT|MCL_FUTURE) ?

Thanks!
Gilad




--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
