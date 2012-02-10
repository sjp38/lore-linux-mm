Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id F2FBC6B13F1
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 15:25:00 -0500 (EST)
Received: by vbip1 with SMTP id p1so2959558vbi.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:25:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328899105.25989.37.camel@laptop>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
	<CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	<4F2AAEB9.9070302@tilera.com>
	<1328899105.25989.37.camel@laptop>
Date: Fri, 10 Feb 2012 22:24:59 +0200
Message-ID: <CAOtvUMf11CxFV+FR8YCjqaoEWojGT7oX46_QamjCkXkHzsW3-A@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 10, 2012 at 8:38 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
>>
>> /*
>> =A0* Quiesce the timer interrupt before returning to user space after a
>> =A0* system call. =A0Normally if a task on a dataplane core makes a
>> =A0* syscall, the system will run one or more timer ticks after the
>> =A0* syscall has completed, causing unexpected interrupts in userspace.
>> =A0* Setting DP_QUIESCE avoids that problem by having the kernel "hold"
>> =A0* the task in kernel mode until the timer ticks are complete. =A0This
>> =A0* will make syscalls dramatically slower.
>> =A0*
>> =A0* If multiple dataplane tasks are scheduled on a single core, this
>> =A0* in effect silently disables DP_QUIESCE, which allows the tasks to m=
ake
>> =A0* progress, but without actually disabling the timer tick.
>> =A0*/
>> #define DP_QUIESCE =A0 =A0 =A00x1
>
> This is what Frederics work does

Actually it's not quite the same I believe. Frederic's patch set
disables the tick
for an adaptive tick task at some timer tick interrupt after the
system call, but
the task doesn't know when that happens, so if timing determinism guarantee=
 is
what you are after you don't quite know in your user task if its safe
to start doing
real time stuff or know.

If I understood Chris quote correctly, they hold the task in kernel
space until the
timer tick is off, so that when the user space task continues to run
after the system
call it can assume the tick is off.

Of course, nothing stops something (IPI?) from re-enabling it later,
but I guess it at least
lets you start in a known state.

I think the concept of giving the task some way to know if the tick is
disabled or not is nice.
Not sure the exact feature and surely not the interface are what we
should adopt - maybe
allow registering to receive a signal at the end of the tick when it
is disabled an re-enabled?

>
>>
>> /*
>> =A0* Disallow the application from entering the kernel in any way,
>> =A0* unless it calls set_dataplane() again without this bit set.
>> =A0* Issuing any other syscall or causing a page fault would generate a
>> =A0* kernel message, and "kill -9" the process.
>> =A0*
>> =A0* Setting this flag automatically sets DP_QUIESCE as well.
>> =A0*/
>> #define DP_STRICT =A0 =A0 =A0 0x2
>
> This is a debug feature.. you'd better know what your own software does.
>
>>
>> /*
>> =A0* Debug dataplane interrupts, so that if any interrupt source
>> =A0* attempts to involve a dataplane cpu, a kernel message and stack
>> =A0* backtrace will be generated on the console. =A0As this warning is a
>> =A0* slow event, it may make sense to avoid this mode in production code
>> =A0* to avoid making any possible interrupts even more heavyweight.
>> =A0*
>> =A0* Setting this flag automatically sets DP_QUIESCE as well.
>> =A0*/
>> #define DP_DEBUG =A0 =A0 =A0 =A00x4
>
> This too is a debug feature, one that doesn't cover all possible
> scenarios.

I like the idea of these but suspect a trace event is more suitable to
provide the same information.

>
>> /*
>> =A0* Cause all memory mappings to be populated in the page table.
>> =A0* Specifying this when entering dataplane mode ensures that no future
>> =A0* page fault events will occur to cause interrupts into the Linux
>> =A0* kernel, as long as no new mappings are installed by mmap(), etc.
>> =A0* Note that since the hardware TLB is of finite size, there will
>> =A0* still be the potential for TLB misses that the hypervisor handles,
>> =A0* either via its software TLB cache (fast path) or by walking the
>> =A0* kernel page tables (slow path), so touching large amounts of memory
>> =A0* will still incur hypervisor interrupt overhead.
>> =A0*/
>> #define DP_POPULATE =A0 =A0 0x8
>
> map()s MAP_POPULATE will pre-populate the stuff for you, as will
> mlock(), the latter will (mostly) ensure they stay around.
>

Yeap.


I think it's a collection of nice ideas that somehow got grouped together
under a specific interface and I guess we adopt the ideas but not neccisiar=
ly
the implementation or interface:

- trace events for the debug notifications
- recommend mlock & friends for the VM stuff
- Perhaps a signal handler for tick notification?

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
