Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 47B616B0082
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 16:51:22 -0500 (EST)
Message-ID: <4F3C28D8.3090608@tilera.com>
Date: Wed, 15 Feb 2012 16:51:20 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com> <1327591185.2446.102.camel@twins> <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com> <20120201170443.GE6731@somewhere.redhat.com> <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com> <4F2AAEB9.9070302@tilera.com> <1328899105.25989.37.camel@laptop> <CAOtvUMf11CxFV+FR8YCjqaoEWojGT7oX46_QamjCkXkHzsW3-A@mail.gmail.com>
In-Reply-To: <CAOtvUMf11CxFV+FR8YCjqaoEWojGT7oX46_QamjCkXkHzsW3-A@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 2/10/2012 3:24 PM, Gilad Ben-Yossef wrote:
> On Fri, Feb 10, 2012 at 8:38 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>> On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
>>> /*
>>>  * Quiesce the timer interrupt before returning to user space after a
>>>  * system call.  Normally if a task on a dataplane core makes a
>>>  * syscall, the system will run one or more timer ticks after the
>>>  * syscall has completed, causing unexpected interrupts in userspace.
>>>  * Setting DP_QUIESCE avoids that problem by having the kernel "hold"
>>>  * the task in kernel mode until the timer ticks are complete.  This
>>>  * will make syscalls dramatically slower.
>>>  *
>>>  * If multiple dataplane tasks are scheduled on a single core, this
>>>  * in effect silently disables DP_QUIESCE, which allows the tasks to make
>>>  * progress, but without actually disabling the timer tick.
>>>  */
>>> #define DP_QUIESCE      0x1
>> This is what Frederics work does
> Actually it's not quite the same I believe. Frederic's patch set
> disables the tick
> for an adaptive tick task at some timer tick interrupt after the
> system call, but
> the task doesn't know when that happens, so if timing determinism guarantee is
> what you are after you don't quite know in your user task if its safe
> to start doing
> real time stuff or know.
>
> If I understood Chris quote correctly, they hold the task in kernel
> space until the
> timer tick is off, so that when the user space task continues to run
> after the system
> call it can assume the tick is off.
>
> Of course, nothing stops something (IPI?) from re-enabling it later,
> but I guess it at least
> lets you start in a known state.
>
> I think the concept of giving the task some way to know if the tick is
> disabled or not is nice.
> Not sure the exact feature and surely not the interface are what we
> should adopt - maybe
> allow registering to receive a signal at the end of the tick when it
> is disabled an re-enabled?

The problem with that is that by receiving a signal, you are back where you
started: returning from the kernel to userspace, and potentially leaving
open the possibility that the kernel will still need a scheduler tick or
two to quiesce.

An alternative we considered was to pass in a memory location that the
kernel would update with the current state of the process (tick disabled or
not), and you could then spin reading that location until the kernel
stopped interrupting you and disabled the tick.  But it seemed silly when
we could essentially put that code in the kernel once and get it right.

And note that the "IPI to re-enable it" is an event that is probably a bug
either in your application or in the kernel, which we track with the
DP_DEBUG flag; you wouldn't expect that to happen once your application was
up and running.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
