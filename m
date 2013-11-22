Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEE66B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 02:28:31 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so661300bkb.16
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:28:30 -0800 (PST)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id qw8si5563167bkb.123.2013.11.21.23.28.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 23:28:30 -0800 (PST)
Received: by mail-lb0-f178.google.com with SMTP id c11so644988lbj.9
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 23:28:30 -0800 (PST)
Date: Fri, 22 Nov 2013 08:28:03 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: user defined OOM policies
Message-ID: <20131122072758.GA1853@hp530>
References: <20131119131400.GC20655@dhcp22.suse.cz>
 <20131119134007.GD20655@dhcp22.suse.cz>
 <20131120172119.GA1848@hp530>
 <20131120173357.GC18809@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20131120173357.GC18809@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 20, 2013 at 06:33:57PM +0100, Michal Hocko wrote: > On Wed
20-11-13 18:21:23, Vladimir Murzin wrote: > > On Tue, Nov 19, 2013 at
02:40:07PM +0100, Michal Hocko wrote: > > Hi Michal > > > On Tue 19-11-13
14:14:00, Michal Hocko wrote:
> > > [...]
> > > > We have basically ended up with 3 options AFAIR:
> > > > 	1) allow memcg approach (memcg.oom_control) on the root level
> > > >            for both OOM notification and blocking OOM killer and handle
> > > >            the situation from the userspace same as we can for other
> > > > 	   memcgs.
> > > 
> > > This looks like a straightforward approach as the similar thing is done
> > > on the local (memcg) level. There are several problems though.
> > > Running userspace from within OOM context is terribly hard to do
> > > right. This is true even in the memcg case and we strongly discurage
> > > users from doing that. The global case has nothing like outside of OOM
> > > context though. So any hang would blocking the whole machine. Even
> > > if the oom killer is careful and locks in all the resources it would
> > > have hard time to query the current system state (existing processes
> > > and their states) without any allocation.  There are certain ways to
> > > workaround these issues - e.g. give the killer access to memory reserves
> > > - but this all looks scary and fragile.
> > > 
> > > > 	2) allow modules to hook into OOM killer path and take the
> > > > 	   appropriate action.
> > > 
> > > This already exists actually. There is oom_notify_list callchain and
> > > {un}register_oom_notifier that allow modules to hook into oom and
> > > skip the global OOM if some memory is freed. There are currently only
> > > s390 and powerpc which seem to abuse it for something that looks like a
> > > shrinker except it is done in OOM path...
> > > 
> > > I think the interface should be changed if something like this would be
> > > used in practice. There is a lot of information lost on the way. I would
> > > basically expect to get everything that out_of_memory gets.
> > 
> > Some time ago I was trying to hook OOM with custom module based policy. I
> > needed to select process based on uss/pss values which required page walking
> > (yes, I know it is extremely expensive, but sometimes I'd pay the bill). The
> > learned lesson is quite simple - it is harmful to expose (all?) internal
> > functions and locking into modules - the result is going to be completely
> > unreliable and non predictable mess, unless the well defined interface and
> > helpers will be established. 
> 
> OK, I was a bit vague it seems. I meant to give zonelist, gfp_mask,
> allocation order and nodemask parameters to the modules. So they have a
> better picture of what is the OOM context.

I think it make sense if we suppose modules are able to postpone task killing
by freeing memory or like that. However, it seems to we come back to the
shrinker interface. If we suppose that OOM is about task killing it is not
clear for me how information about gfp mask and order can be used here
efficiently. I'd be grateful if you elaborate more about that.

I definitely missed something, and I'm curious what OOM policy means here?

1) calculation of the metric for the victim, like oom_badness, so we can input
some info and make judgment based on the output.

2) selecting the victim process, like select_bad_process, so we can just query
module and than kill the victim selected by the module.

3) completely delegate OOM handling to the module, not matter how it will free
the memory.

4) other?

Thanks
Vladimir

> What everything ould modules need to do an effective work is a matter
> for discussion.
> 
> > > > 	3) create a generic filtering mechanism which could be
> > > > 	   controlled from the userspace by a set of rules (e.g.
> > > > 	   something analogous to packet filtering).
> > > 
> > > This looks generic enough but I have no idea about the complexity.
> > 
> > Never thought about it, but just wonder which input and output supposed to
> > have for this filtering mechanism?
> 
> I wasn't an author of this idea and didn't think about details so much.
> My very superficial understanding is that oom basically needs to filter
> and cathegory tasks into few cathegories. Those to kill immediatelly,
> those that can wait for a fallback and those that should never be
> touched. I didn't get beyond this level of thinking. I have mentioned
> that merely because this idea was mentioned in the room at the time.
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
