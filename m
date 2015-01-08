Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 459166B0071
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 03:34:02 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so9889412pdb.10
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 00:34:02 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id sy7si7395270pbc.64.2015.01.08.00.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 00:34:00 -0800 (PST)
Date: Thu, 8 Jan 2015 11:33:53 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150108083353.GB2110@esperanza>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <20150107085828.GA2110@esperanza>
 <20150107143858.GE16553@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150107143858.GE16553@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed, Jan 07, 2015 at 03:38:58PM +0100, Michal Hocko wrote:
> On Wed 07-01-15 11:58:28, Vladimir Davydov wrote:
> > On Tue, Jan 06, 2015 at 05:14:35PM +0100, Michal Hocko wrote:
> > [...]
> > > And as a memcg co-maintainer I would like to also discuss the following
> > > topics.
> > > - We should finally settle down with a set of core knobs exported with
> > >   the new unified hierarchy cgroups API. I have proposed this already
> > >   http://marc.info/?l=linux-mm&m=140552160325228&w=2 but there is no
> > >   clear consensus and the discussion has died later on. I feel it would
> > >   be more productive to sit together and come up with a reasonable
> > >   compromise between - let's start from the begining and keep useful and
> > >   reasonable features.
> > >   
> > > - kmem accounting is seeing a lot of activity mainly thanks to Vladimir.
> > >   He is basically the only active developer in this area. I would be
> > >   happy if he can attend as well and discuss his future plans in the
> > >   area. The work overlaps with slab allocators and slab shrinkers so
> > >   having people familiar with these areas would be more than welcome
> > 
> > One more memcg related topic that is worth discussing IMO:
> > 
> >  - On global memory pressure we walk over all memory cgroups and scan
> >    pages from each of them. Since there can be hundreds or even
> >    thousands of memory cgroups, such a walk can be quite expensive,
> >    especially if the cgroups are small so that to reclaim anything from
> >    them we have to descend to a lower scan priority.
> 
>      We do not get to lower priorities just to scan small cgroups. They
>      will simply get ignored unless we are force scanning them.

That means that small cgroups (< 16 M) may not be scanned at all if
there are enough reclaimable pages in bigger cgroups. I'm not sure if
anyone will mix small and big cgroups on the same host though. However,
currently this may render offline memory cgroups hanging around forever
if they have some memory on destruction, because they will become small
due to global reclaim sooner or later. OTOH, we could always forcefully
scan lruvecs that belong to dead cgroups, or limit the maximal number of
dead cgroups, w/o reworking the reclaimer.

> 
> >    The problem is
> >    augmented by offline memory cgroups, which now can be dangling for
> >    indefinitely long time.
> 
> OK, but shrink_lruvec shouldn't do too much work on a memcg which
> doesn't have any pages to scan for the given priority. Or have you
> seen this in some profiles?

In real life, no.

> 
> >    That's why I think we should work out a better algorithm for the
> >    memory reclaimer. May be, we could rank memory cgroups somehow (by
> >    their age, memory consumption?) and try to scan only the top ranked
> >    cgroup during a reclaimer run.
> 
> We still have to keep some fairness and reclaim all groups
> proportionally and balancing this would be quite non-trivial. I am not
> saying we couldn't implement our iterators in a more intelligent way but
> this code is quite complex already and I haven't seen this as a big
> problem yet. Some overhead is to be expected when thousands of groups
> are configured, right?

Right, sounds convincing. Let's cross out this topic then until we see
complains from real users. No need to spend time on it right now.

Sorry for the noise.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
