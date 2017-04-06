Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDA0A6B03F7
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 03:27:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o70so4930957wrb.11
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 00:27:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si1673088wmf.160.2017.04.06.00.27.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 00:27:58 -0700 (PDT)
Date: Thu, 6 Apr 2017 09:27:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
Message-ID: <20170406072754.GC5497@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
 <20170405113157.GM6035@dhcp22.suse.cz>
 <ee6649ed-b0e8-1c59-c193-d1688fdfe7f5@nod.at>
 <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
 <fe1c21a4-0bc6-529c-5446-382b01d4c99e@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe1c21a4-0bc6-529c-5446-382b01d4c99e@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>

On Thu 06-04-17 09:33:44, Adrian Hunter wrote:
> On 05/04/17 14:39, Vlastimil Babka wrote:
> > On 04/05/2017 01:36 PM, Richard Weinberger wrote:
> >> Michal,
> >>
> >> Am 05.04.2017 um 13:31 schrieb Michal Hocko:
> >>> On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
> >>>> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
> >>>> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
> >>>> No functional change.
> >>>
> >>> This one smells like an abuser. Why the hell should read/write path
> >>> touch memory reserves at all!
> >>
> >> Could be. Let's ask Adrian, AFAIK he wrote that code.
> >> Adrian, can you please clarify why nandsim needs to play with PF_MEMALLOC?
> > 
> > I was thinking about it and concluded that since the simulator can be
> > used as a block device where reclaimed pages go to, writing the data out
> > is a memalloc operation. Then reading can be called as part of r-m-w
> > cycle, so reading as well.
> 
> IIRC it was to avoid getting stuck with nandsim waiting on memory reclaim
> and memory reclaim waiting on nandsim.

I've got lost in the indirection. Could you describe how would reclaim
get stuck waiting on these paths please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
