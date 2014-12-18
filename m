Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC156B0032
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 11:55:07 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so2480163wid.17
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 08:55:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bz8si12921820wjb.73.2014.12.18.08.55.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 08:55:06 -0800 (PST)
Date: Thu, 18 Dec 2014 17:55:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Stalled MM patches for review
Message-ID: <20141218165504.GB957@dhcp22.suse.cz>
References: <20141215150207.67c9a25583c04202d9f4508e@linux-foundation.org>
 <548F7541.8040407@jp.fujitsu.com>
 <20141216030658.GA18569@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412161650540.19867@chino.kir.corp.google.com>
 <20141217021302.GA14148@phnom.home.cmpxchg.org>
 <alpine.DEB.2.10.1412171422330.16260@chino.kir.corp.google.com>
 <20141218022019.GA25071@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141218022019.GA25071@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 17-12-14 21:20:19, Johannes Weiner wrote:
> On Wed, Dec 17, 2014 at 02:28:37PM -0800, David Rientjes wrote:
[...]
> > Why remove 'rebalance'?  In the situation where direct reclaim does free 
> > memory and we're waiting on writeback (no call to the oom killer is made), 
> > it doesn't seem necessary to recalculate classzone_idx.
> > 
> > Additionally, we never called wait_iff_congested() before when the oom 
> > killer freed memory.  This is a no-op if the preferred_zone isn't waiting 
> > on writeback, but seems pointless if we just freed memory by calling the 
> > oom killer.
> 
> Why keep all these undocumented assumptions in the code?  It's really
> simple: if we retry freeing memory (LRU reclaim or OOM kills), we wait
> for congestion, kick kswapd, re-evaluate the current task state,
> regardless of which reclaim method did what or anything at all.  It's
> a slowpath, so there is no reason to not keep this simple and robust.

Agreed, the less subtle loops via labels we have the better.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
