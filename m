Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id D2C186B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:34:00 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so1280763bkz.15
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 09:34:00 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h2si4092422bko.267.2013.11.20.09.33.59
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 09:33:59 -0800 (PST)
Date: Wed, 20 Nov 2013 18:33:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: user defined OOM policies
Message-ID: <20131120173357.GC18809@dhcp22.suse.cz>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <20131120172119.GA1848@hp530>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120172119.GA1848@hp530>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <murzin.v@gmail.com>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 20-11-13 18:21:23, Vladimir Murzin wrote:
> On Tue, Nov 19, 2013 at 02:40:07PM +0100, Michal Hocko wrote:
> Hi Michal
> > On Tue 19-11-13 14:14:00, Michal Hocko wrote:
> > [...]
> > > We have basically ended up with 3 options AFAIR:
> > > 	1) allow memcg approach (memcg.oom_control) on the root level
> > >            for both OOM notification and blocking OOM killer and handle
> > >            the situation from the userspace same as we can for other
> > > 	   memcgs.
> > 
> > This looks like a straightforward approach as the similar thing is done
> > on the local (memcg) level. There are several problems though.
> > Running userspace from within OOM context is terribly hard to do
> > right. This is true even in the memcg case and we strongly discurage
> > users from doing that. The global case has nothing like outside of OOM
> > context though. So any hang would blocking the whole machine. Even
> > if the oom killer is careful and locks in all the resources it would
> > have hard time to query the current system state (existing processes
> > and their states) without any allocation.  There are certain ways to
> > workaround these issues - e.g. give the killer access to memory reserves
> > - but this all looks scary and fragile.
> > 
> > > 	2) allow modules to hook into OOM killer path and take the
> > > 	   appropriate action.
> > 
> > This already exists actually. There is oom_notify_list callchain and
> > {un}register_oom_notifier that allow modules to hook into oom and
> > skip the global OOM if some memory is freed. There are currently only
> > s390 and powerpc which seem to abuse it for something that looks like a
> > shrinker except it is done in OOM path...
> > 
> > I think the interface should be changed if something like this would be
> > used in practice. There is a lot of information lost on the way. I would
> > basically expect to get everything that out_of_memory gets.
> 
> Some time ago I was trying to hook OOM with custom module based policy. I
> needed to select process based on uss/pss values which required page walking
> (yes, I know it is extremely expensive, but sometimes I'd pay the bill). The
> learned lesson is quite simple - it is harmful to expose (all?) internal
> functions and locking into modules - the result is going to be completely
> unreliable and non predictable mess, unless the well defined interface and
> helpers will be established. 

OK, I was a bit vague it seems. I meant to give zonelist, gfp_mask,
allocation order and nodemask parameters to the modules. So they have a
better picture of what is the OOM context.
What everything ould modules need to do an effective work is a matter
for discussion.

> > > 	3) create a generic filtering mechanism which could be
> > > 	   controlled from the userspace by a set of rules (e.g.
> > > 	   something analogous to packet filtering).
> > 
> > This looks generic enough but I have no idea about the complexity.
> 
> Never thought about it, but just wonder which input and output supposed to
> have for this filtering mechanism?

I wasn't an author of this idea and didn't think about details so much.
My very superficial understanding is that oom basically needs to filter
and cathegory tasks into few cathegories. Those to kill immediatelly,
those that can wait for a fallback and those that should never be
touched. I didn't get beyond this level of thinking. I have mentioned
that merely because this idea was mentioned in the room at the time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
