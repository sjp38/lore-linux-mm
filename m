Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id C5E966B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 10:52:56 -0500 (EST)
Received: by qadz32 with SMTP id z32so4794967qad.14
        for <linux-mm@kvack.org>; Thu, 09 Feb 2012 07:52:55 -0800 (PST)
Date: Thu, 9 Feb 2012 16:52:49 +0100
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
Message-ID: <20120209155246.GD22552@somewhere.redhat.com>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
 <1327591185.2446.102.camel@twins>
 <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
 <20120201170443.GE6731@somewhere.redhat.com>
 <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
 <20120202162420.GE9071@somewhere.redhat.com>
 <alpine.DEB.2.00.1202021028120.6221@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.00.1202021028120.6221@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu, Feb 02, 2012 at 10:29:57AM -0600, Christoph Lameter wrote:
> On Thu, 2 Feb 2012, Frederic Weisbecker wrote:
> 
> > > Some pinned timers might be able to get special treatment as well - take for
> > > example the vmstat work being schedule every second, what should we do with
> > > it for CPU isolation?
> >
> > Right, I remember I saw these vmstat timers on my way when I tried to get 0
> > interrupts on a CPU.
> >
> > I think all these timers need to be carefully reviewed before doing anything.
> > But we certainly shouldn't adopt the behaviour of migrating timers by default.
> >
> > Some timers really needs to stay on the expected CPU. Note that some
> > timers may be shutdown by CPU hotplug callbacks. Those wouldn't be migrated
> > in case of CPU offlining. We need to keep them.
> >
> > > It makes sense to me to have that stop scheduling itself when we have the tick
> > > disabled for both idle and a nohz task.
> 
> The vmstat timer only makes sense when the OS is doing something on the
> processor. Otherwise if no counters are incremented and the page and slab
> allocator caches are empty then there is no need to run the vmstat timer.

So this is a typical example of a timer we want to shutdown when the CPU is idle
but we want to keep it running when we run in adaptive tickless mode (ie: shutdown
the tick while the CPU is busy).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
