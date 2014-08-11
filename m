Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 98C3F6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 03:49:53 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w62so8141028wes.29
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 00:49:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si25108692wja.153.2014.08.11.00.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 00:49:52 -0700 (PDT)
Date: Mon, 11 Aug 2014 09:49:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/4] mm: memcontrol: reduce reclaim invocations for
 higher order requests
Message-ID: <20140811074950.GA15312@dhcp22.suse.cz>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <1407186897-21048-2-git-send-email-hannes@cmpxchg.org>
 <20140807130822.GB12730@dhcp22.suse.cz>
 <20140807153141.GD14734@cmpxchg.org>
 <20140808123258.GK4004@dhcp22.suse.cz>
 <20140808132635.GJ14734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140808132635.GJ14734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 08-08-14 09:26:35, Johannes Weiner wrote:
> On Fri, Aug 08, 2014 at 02:32:58PM +0200, Michal Hocko wrote:
> > On Thu 07-08-14 11:31:41, Johannes Weiner wrote:
[...]
> > > although system time is reduced with the high limit.
> > > High limit reclaim with SWAP_CLUSTER_MAX has better fault latency but
> > > it doesn't actually contain the workload - with 1G high and a 4G load,
> > > the consumption at the end of the run is 3.7G.
> > 
> > Wouldn't it help to simply fail the charge and allow the charger to
> > fallback for THP allocations if the usage is above high limit too
> > much? The follow up single page charge fallback would be still
> > throttled.
> 
> This is about defining the limit semantics in unified hierarchy, and
> not really the time or place to optimize THP charge latency.
> 
> What are you trying to accomplish here?

Well there are two things. The first one is that this patch changes the way
how THP are charged for the hard limit without any data to back it up in the
changelog. This is the primary concern.

The other part is the high limit behavior for large excess. You have
chosen to reclaim all excessive charges even when quite a lot of pages
might be direct reclaimed. This is potentially dangerous because the
excess might be really huge (consider multiple tasks charging THPs
simultaneously on many CPUs). Do you really want to direct reclaim
nr_online_cpus * 512 pages in the single direct reclaim pass and for
all those cpus? This is an extreme case, all right, but the point
stays. There has to be a certain cap. Also it seems that the primary
source of troubles is THP so the question is. Do we really want to push
hard to reclaim enough charges or do we rather fail THP charge and go
with single page retry?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
