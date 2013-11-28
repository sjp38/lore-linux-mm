Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 64B9D6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 06:36:56 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id z12so7905514wgg.3
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:36:55 -0800 (PST)
Received: from mail-ea0-x22d.google.com (mail-ea0-x22d.google.com [2a00:1450:4013:c01::22d])
        by mx.google.com with ESMTPS id gh6si12355156wic.41.2013.11.28.03.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 03:36:47 -0800 (PST)
Received: by mail-ea0-f173.google.com with SMTP id g15so5677048eak.18
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:36:47 -0800 (PST)
Date: Thu, 28 Nov 2013 12:36:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131128113641.GI2761@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com>
 <20131120152251.GA18809@dhcp22.suse.cz>
 <CAA25o9S5EQBvyk=HP3obdCaXKjoUVtzeb4QsNmoLMq6NnOYifA@mail.gmail.com>
 <alpine.DEB.2.02.1311201933420.7167@chino.kir.corp.google.com>
 <CAA25o9Q64eK5LHhrRyVn73kFz=Z7Jji=rYWS=9jWL_4y9ZGbQA@mail.gmail.com>
 <20131122180835.GO3556@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131122180835.GO3556@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Luigi Semenzato <semenzato@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 22-11-13 13:08:35, Johannes Weiner wrote:
> On Wed, Nov 20, 2013 at 11:03:33PM -0800, Luigi Semenzato wrote:
> > On Wed, Nov 20, 2013 at 7:36 PM, David Rientjes <rientjes@google.com> wrote:
> > > On Wed, 20 Nov 2013, Luigi Semenzato wrote:
> > >
> > >> Chrome OS uses a custom low-memory notification to minimize OOM kills.
> > >>  When the notifier triggers, the Chrome browser tries to free memory,
> > >> including by shutting down processes, before the full OOM occurs.  But
> > >> OOM kills cannot always be avoided, depending on the speed of
> > >> allocation and how much CPU the freeing tasks are able to use
> > >> (certainly they could be given higher priority, but it get complex).
> > >>
> > >> We may end up using memcg so we can use the cgroup
> > >> memory.pressure_level file instead of our own notifier, but we have no
> > >> need for finer control over OOM kills beyond the very useful kill
> > >> priority.  One process at a time is good enough for us.
> > >>
> > >
> > > Even with your own custom low-memory notifier or memory.pressure_level,
> > > it's still possible that all memory is depleted and you run into an oom
> > > kill before your userspace had a chance to wakeup and prevent it.  I think
> > > what you'll want is either your custom notifier of memory.pressure_level
> > > to do pre-oom freeing but fallback to a userspace oom handler that
> > > prevents kernel oom kills until it ensures userspace did everything it
> > > could to free unneeded memory, do any necessary logging, etc, and do so
> > > over a grace period of memory.oom_delay_millisecs before the kernel
> > > eventually steps in and kills.
> > 
> > Yes, I agree that we can't always prevent OOM situations, and in fact
> > we tolerate OOM kills, although they have a worse impact on the users
> > than controlled freeing does.
> > 
> > Well OK here it goes.  I hate to be a party-pooper, but the notion of
> > a user-level OOM-handler scares me a bit for various reasons.
> > 
> > 1. Our custom notifier sends low-memory warnings well ahead of memory
> > depletion.  If we don't have enough time to free memory then, what can
> > the last-minute OOM handler do?
> >
> > 2. In addition to the time factor, it's not trivial to do anything,
> > including freeing memory, without allocating memory first, so we'll
> > need a reserve, but how much, and who is allowed to use it?
> > 
> > 3. How does one select the OOM-handler timeout?  If the freeing paths
> > in the code are swapped out, the time needed to bring them in can be
> > highly variable.
> > 
> > 4. Why wouldn't the OOM-handler also do the killing itself?  (Which is
> > essentially what we do.)  Then all we need is a low-memory notifier
> > which can predict how quickly we'll run out of memory.
> > 
> > 5. The use case mentioned earlier (the fact that the killing of one
> > process can make an entire group of processes useless) can be dealt
> > with using OOM priorities and user-level code.
> 
> I would also be interested in the answers to all these questions.
> 
> > I confess I am surprised that the OOM killer works as well as I think
> > it does.  Adding a user-level component would bring a whole new level
> > of complexity to code that's already hard to fully comprehend, and
> > might not really address the fundamental issues.
> 
> Agreed.
> 
> OOM killing is supposed to be a last resort and should be avoided as
> much as possible.  The situation is so precarious at this point that
> the thought of involving USERSPACE to fix it seems crazy to me.

Please remember that this discussion is about User/Admin defined policy
for OOM killer. Not necessarily user space handling of global OOM.

I am skeptical to userspace handler as well but I admit that there might
be usecases where this is doable. But let's focus on the proper
interface for the policies (aka what kind of action should be taken
under OOM - kill process, group, reboot, etc...).

> It would make much more sense to me to focus on early notifications
> and deal with looming situations while we still have the resources to
> do so.

We already have those at least in the memcg world (vmpressure).

> Before attempting to build a teleportation device in the kernel, maybe
> we should just stop painting ourselves into corners?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
