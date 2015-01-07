Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8ECCF6B0032
	for <linux-mm@kvack.org>; Wed,  7 Jan 2015 09:39:02 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so1736928wid.11
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:39:02 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id e7si4450876wjq.111.2015.01.07.06.39.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Jan 2015 06:39:01 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id x12so1294491wgg.11
        for <linux-mm@kvack.org>; Wed, 07 Jan 2015 06:39:01 -0800 (PST)
Date: Wed, 7 Jan 2015 15:38:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150107143858.GE16553@dhcp22.suse.cz>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <20150107085828.GA2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107085828.GA2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Wed 07-01-15 11:58:28, Vladimir Davydov wrote:
> On Tue, Jan 06, 2015 at 05:14:35PM +0100, Michal Hocko wrote:
> [...]
> > And as a memcg co-maintainer I would like to also discuss the following
> > topics.
> > - We should finally settle down with a set of core knobs exported with
> >   the new unified hierarchy cgroups API. I have proposed this already
> >   http://marc.info/?l=linux-mm&m=140552160325228&w=2 but there is no
> >   clear consensus and the discussion has died later on. I feel it would
> >   be more productive to sit together and come up with a reasonable
> >   compromise between - let's start from the begining and keep useful and
> >   reasonable features.
> >   
> > - kmem accounting is seeing a lot of activity mainly thanks to Vladimir.
> >   He is basically the only active developer in this area. I would be
> >   happy if he can attend as well and discuss his future plans in the
> >   area. The work overlaps with slab allocators and slab shrinkers so
> >   having people familiar with these areas would be more than welcome
> 
> One more memcg related topic that is worth discussing IMO:
> 
>  - On global memory pressure we walk over all memory cgroups and scan
>    pages from each of them. Since there can be hundreds or even
>    thousands of memory cgroups, such a walk can be quite expensive,
>    especially if the cgroups are small so that to reclaim anything from
>    them we have to descend to a lower scan priority.

     We do not get to lower priorities just to scan small cgroups. They
     will simply get ignored unless we are force scanning them.

>    The problem is
>    augmented by offline memory cgroups, which now can be dangling for
>    indefinitely long time.

OK, but shrink_lruvec shouldn't do too much work on a memcg which
doesn't have any pages to scan for the given priority. Or have you seen
this in some profiles?

>    That's why I think we should work out a better algorithm for the
>    memory reclaimer. May be, we could rank memory cgroups somehow (by
>    their age, memory consumption?) and try to scan only the top ranked
>    cgroup during a reclaimer run.

We still have to keep some fairness and reclaim all groups
proportionally and balancing this would be quite non-trivial. I am not
saying we couldn't implement our iterators in a more intelligent way but
this code is quite complex already and I haven't seen this as a big
problem yet. Some overhead is to be expected when thousands of groups
are configured, right?

>    This topic is also very close to the
>    soft limit reclaim improvements, which Michal has been working on for
>    a while.

The patches I have for the low limit reclaim didn't care about an
intelligent filtering of non-reclaimable groups because I thought it
would be too early to complicate the code at this stage. Especially when
non-reclaimable will be a very small minority in the real life. This
wasn't the case with the old soft limit because we had opposite
situation there.

Nevertheless I am definitely open to discussing improvements.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
