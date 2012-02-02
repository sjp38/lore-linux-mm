Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 717886B13F0
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 03:46:33 -0500 (EST)
Received: by ggnu2 with SMTP id u2so1451984ggn.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 00:46:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120201170443.GE6731@somewhere.redhat.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
Date: Thu, 2 Feb 2012 10:46:32 +0200
Message-ID: <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Wed, Feb 1, 2012 at 7:04 PM, Frederic Weisbecker <fweisbec@gmail.com> wr=
ote:
>
> On Sun, Jan 29, 2012 at 10:25:46AM +0200, Gilad Ben-Yossef wrote:
>
> > If this is of interest, I keep a list tracking global IPI and global
> > task schedulers sources in the core kernel here:
> > https://github.com/gby/linux/wiki.
> >
> > I plan to visit all these potential interference source to see if
> > something can be done to lower their effect on
> > isolated CPUs over time.
>
> Very nice especially as many people seem to be interested in
> CPU isolation.


Yes, that is what drives me as well. I have a bare metal program
I'm trying to kill here, I researched CPU isolation and ran into your
nohz patch set and asked myself: "OK, if we disable the tick what else
is on the way?"

>
>
> When we get the adaptive tickless feature in place, perhaps we'll
> also need to think about some way to have more control on the
> CPU affinity of some non pinned timers to avoid disturbing
> adaptive tickless CPUs. We still need to consider their cache affinity
> though.


Right. I'm thinking we can treat a CPU going in adaptive tick mode in a sim=
ilar
fashion to a CPU going offline for the purpose of timer migration.

Some pinned timers might be able to get special treatment as well - take fo=
r
example the vmstat=A0work being schedule every second, what should we do wi=
th
it for CPU isolation?

It makes sense to me to have that stop scheduling itself when we have the t=
ick
disabled for both idle and a nohz task.

A similar thing can be said for the clocksource watchdog for example - we m=
ight
consider=A0having it not=A0trigger stuff on idle or nohz task CPUs

Maybe we can have some notification mechanism when a task goes into nohz
mode and back to let stuff disable itself and back if it makes sense.
It seems more
sensible=A0then having all these individual pieces check for whether
this CPU or other is
in idle or nohz task mode.

The question for nohz task then is when does the notification needs to go o=
ut?
only when a task=A0managed to go into nohz mode or when we add a cpu to an
adaptive tick cpuset? because for stuff like vmstat, the very existence of =
the
runnable workqueue thread can keep a task from going into nohz mode. bah.
maybe we need two notifications...


Thanks!
Gilad
--
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
