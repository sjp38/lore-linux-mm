Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id E307C6B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 11:24:31 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1597315ghr.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 08:24:30 -0800 (PST)
Date: Thu, 2 Feb 2012 17:24:22 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120202162420.GE9071@somewhere.redhat.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <20120201170443.GE6731@somewhere.redhat.com>
 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 02, 2012 at 10:46:32AM +0200, Gilad Ben-Yossef wrote:
> On Wed, Feb 1, 2012 at 7:04 PM, Frederic Weisbecker <fweisbec@gmail.com> wrote:
> >
> > On Sun, Jan 29, 2012 at 10:25:46AM +0200, Gilad Ben-Yossef wrote:
> >
> > > If this is of interest, I keep a list tracking global IPI and global
> > > task schedulers sources in the core kernel here:
> > > https://github.com/gby/linux/wiki.
> > >
> > > I plan to visit all these potential interference source to see if
> > > something can be done to lower their effect on
> > > isolated CPUs over time.
> >
> > Very nice especially as many people seem to be interested in
> > CPU isolation.
> 
> 
> Yes, that is what drives me as well. I have a bare metal program
> I'm trying to kill here, I researched CPU isolation and ran into your
> nohz patch set and asked myself: "OK, if we disable the tick what else
> is on the way?"
> 
> >
> >
> > When we get the adaptive tickless feature in place, perhaps we'll
> > also need to think about some way to have more control on the
> > CPU affinity of some non pinned timers to avoid disturbing
> > adaptive tickless CPUs. We still need to consider their cache affinity
> > though.
> 
> 
> Right. I'm thinking we can treat a CPU going in adaptive tick mode in a similar
> fashion to a CPU going offline for the purpose of timer migration.
> 
> Some pinned timers might be able to get special treatment as well - take for
> example the vmstat work being schedule every second, what should we do with
> it for CPU isolation?

Right, I remember I saw these vmstat timers on my way when I tried to get 0
interrupts on a CPU.

I think all these timers need to be carefully reviewed before doing anything.
But we certainly shouldn't adopt the behaviour of migrating timers by default.

Some timers really needs to stay on the expected CPU. Note that some
timers may be shutdown by CPU hotplug callbacks. Those wouldn't be migrated
in case of CPU offlining. We need to keep them.

> It makes sense to me to have that stop scheduling itself when we have the tick
> disabled for both idle and a nohz task.

We have deferrable timers, their semantics is to not fire when the CPU is
idle. But beeing idle and beeing adaptive tickless is not the same. On adaptive
tickless the CPU is busy doing things that might be relevant for these deferrable
timers.

So I don't think we can apply the same logic.


> 
> A similar thing can be said for the clocksource watchdog for example - we might
> consider having it not trigger stuff on idle or nohz task CPUs

This one is particular and is only armed when the tsc is unstable (IIUC). I
guess we shouldn't worry about that, it's a corner case.

> Maybe we can have some notification mechanism when a task goes into nohz
> mode and back to let stuff disable itself and back if it makes sense.
> It seems more
> sensible then having all these individual pieces check for whether
> this CPU or other is
> in idle or nohz task mode.
> 
> The question for nohz task then is when does the notification needs to go out?
> only when a task managed to go into nohz mode or when we add a cpu to an
> adaptive tick cpuset? because for stuff like vmstat, the very existence of the
> runnable workqueue thread can keep a task from going into nohz mode. bah.
> maybe we need two notifications...

I think we really need to explore these timers and workqueues case by case.
And may be set up a way to affine these to particular cpusets if needed.

> 
> 
> Thanks!
> Gilad
> --
> Gilad Ben-Yossef
> Chief Coffee Drinker
> gilad@benyossef.com
> Israel Cell: +972-52-8260388
> US Cell: +1-973-8260388
> http://benyossef.com
> 
> "If you take a class in large-scale robotics, can you end up in a
> situation where the homework eats your dog?"
>  -- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
