Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF3C6B6ED0
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 14:07:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 33-v6so2290589plf.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 11:07:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k127-v6si22011479pga.407.2018.09.04.11.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 11:07:10 -0700 (PDT)
Date: Tue, 4 Sep 2018 20:07:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: slowly shrink slabs with a relatively small number
 of objects
Message-ID: <20180904180707.GS14951@dhcp22.suse.cz>
References: <20180831203450.2536-1-guro@fb.com>
 <3b05579f964cca1d44551913f1a9ee79d96f198e.camel@surriel.com>
 <20180831213138.GA9159@tower.DHCP.thefacebook.com>
 <20180903182956.GE15074@dhcp22.suse.cz>
 <20180903202803.GA6227@castle.DHCP.thefacebook.com>
 <20180904070005.GG14951@dhcp22.suse.cz>
 <20180904153445.GA22328@tower.DHCP.thefacebook.com>
 <20180904161431.GP14951@dhcp22.suse.cz>
 <20180904175243.GA4889@tower.DHCP.thefacebook.com>
 <20180904180631.GR14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904180631.GR14951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

[now CC Vladimir for real]

On Tue 04-09-18 20:06:31, Michal Hocko wrote:
> On Tue 04-09-18 10:52:46, Roman Gushchin wrote:
> > On Tue, Sep 04, 2018 at 06:14:31PM +0200, Michal Hocko wrote:
> [...]
> > > I am not opposing your patch but I am trying to figure out whether that
> > > is the best approach.
> > 
> > I don't think the current logic does make sense. Why should cgroups
> > with less than 4k kernel objects be excluded from being scanned?
> 
> How is it any different from the the LRU reclaim? Maybe it is just not
> that visible because there usually more pages there. But in principle it
> is the same issue AFAICS.
> 
> > Reparenting of all pages is definitely an option to consider,
> > but it's not free in any case, so if there is no problem,
> > why should we? Let's keep it as a last measure. In my case,
> > the proposed patch works perfectly: the number of dying cgroups
> > jumps around 100, where it grew steadily to 2k and more before.
> 
> Let me emphasise that I am not opposing the patch. I just think that we
> have made some decisions which are not ideal but I would really like to
> prevent from building workarounds on top. If we have to reconsider some
> of those decisions then let's do it. Maybe the priority scaling is just
> too coarse and what seem to work work for normal LRUs doesn't work for
> shrinkers.
> 
> > I believe that reparenting of LRU lists is required to minimize
> > the number of LRU lists to scan, but I'm not sure.
> 
> Well, we do have more lists to scan for normal LRUs. It is true that
> shrinkers add multiplining factor to that but in principle I guess we
> really want to distinguish dead memcgs because we do want to reclaim
> those much more than the rest. Those objects are basically of no use
> just eating resources. The pagecache has some chance to be reused at
> least but I fail to see why we should keep kernel objects around. Sure,
> some of them might be harder to reclaim due to different life time and
> internal object management but this doesn't change the fact that we
> should try hard to reclaim those. So my gut feeling tells me that we
> should have a way to distinguish them.
> 
> Btw. I do not see Vladimir on the CC list. Added (the thread starts
> here http://lkml.kernel.org/r/20180831203450.2536-1-guro@fb.com)

-- 
Michal Hocko
SUSE Labs
