Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE8728089F
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 03:57:11 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u65so7623568wrc.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 00:57:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m73si5369053wmg.161.2017.02.09.00.57.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 00:57:10 -0800 (PST)
Date: Thu, 9 Feb 2017 09:57:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Fix nodes for reclaim in fast path
Message-ID: <20170209085706.GE10257@dhcp22.suse.cz>
References: <1486532455-29613-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170208100850.GD5686@dhcp22.suse.cz>
 <20170208230618.GA4142@gwshan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170208230618.GA4142@gwshan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, akpm@linux-foundation.org, anton@samba.org, mpe@ellerman.id.au, "# v3 . 16+" <stable@vger.kernel.org>

On Thu 09-02-17 10:06:18, Gavin Shan wrote:
> On Wed, Feb 08, 2017 at 11:08:50AM +0100, Michal Hocko wrote:
> >On Wed 08-02-17 16:40:55, Gavin Shan wrote:
> >> When @node_reclaim_node isn't 0, the page allocator tries to reclaim
> >> pages if the amount of free memory in the zones are below the low
> >> watermark. On Power platform, none of NUMA nodes are scanned for page
> >> reclaim because no nodes match the condition in zone_allows_reclaim().
> >> On Power platform, RECLAIM_DISTANCE is set to 10 which is the distance
> >> of Node-A to Node-A. So the preferred node even won't be scanned for
> >> page reclaim.
> >
> >This is quite confusing. I can see 56608209d34b ("powerpc/numa: Set a
> >smaller value for RECLAIM_DISTANCE to enable zone reclaim") which
> >enforced the zone_reclaim by reducing the RECLAIM_DISTANCE, now you are
> >building on top of that. Having RECLAIM_DISTANCE == LOCAL_DISTANCE is
> >really confusing. What are distances of other nodes (in other words what
> >does numactl --hardware tells)? I am wondering whether we shouldn't
> >rather revert 56608209d34b as the node_reclaim (these days) is not
> >enabled by default anymore.
> >
> 
> Michael, Yeah, it's a bit confusing. Let me try to summarize the history:
> the code 56608209d34b (2.6.35) depends, which is shown in its commit log,
> was removed by 957f822a0ab9 (3.10). Since then, the code change introduced
> by 56608209d34b (2.6.35) becomes obsoleted. However, the local pagecache
> (with @node_reclaim_mode turned on manually) was able to be shrinked at
> that point (3.10) until 5f7a75acdb24 (3.16) was merged. This patch fixes
> the issue introduced by 5f7a75acdb24 and needs go to 3.16+. Hope this
> makes things more clear, not more confusing :-)

yeah, it is clear as mud ;)

> Yes, I already planned to set PowerPC specific RECLAIM_DISTANCE to 30, same
> value to the generic one, as I said in the last reply of the thread:
> https://patchwork.ozlabs.org/patch/718830/

just drop the ppc specific definition and use the generic one instead.
 
> >> Fixes: 5f7a75acdb24 ("mm: page_alloc: do not cache reclaim distances")
> >> Cc: <stable@vger.kernel.org> # v3.16+
> >> Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
> >
> >anyway the patch looks OK as it brings the previous behavior back. Not
> >that I would be entirely happy about that behavior as it is quite nasty
> >- e.g. it will trigger direct reclaim from the allocator fast path way
> >too much and basically skip the kswapd wake up most of the time if there
> >is anything reclaimable... But this used to be there before as well.
> >
> >Acked-by: Michal Hocko <mhocko@suse.com>
> >
> >but I would really like to get rid of the ppc specific RECLAIM_DISTANCE
> >if possible as well.
> >
> 
> Yes, I will post one patch for this and you will be copied.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
