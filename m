Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 59E706B03C0
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 08:09:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p111so1334045wrc.10
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 05:09:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r22si24087014wme.123.2017.04.05.05.09.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 05:09:40 -0700 (PDT)
Date: Wed, 5 Apr 2017 14:09:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
Message-ID: <20170405120936.GN6035@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
 <20170405113157.GM6035@dhcp22.suse.cz>
 <ee6649ed-b0e8-1c59-c193-d1688fdfe7f5@nod.at>
 <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9b9d5bca-e125-e07b-b700-196cc800bbd7@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Richard Weinberger <richard@nod.at>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Adrian Hunter <adrian.hunter@intel.com>

On Wed 05-04-17 13:39:16, Vlastimil Babka wrote:
> On 04/05/2017 01:36 PM, Richard Weinberger wrote:
> > Michal,
> > 
> > Am 05.04.2017 um 13:31 schrieb Michal Hocko:
> >> On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
> >>> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
> >>> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
> >>> No functional change.
> >>
> >> This one smells like an abuser. Why the hell should read/write path
> >> touch memory reserves at all!
> > 
> > Could be. Let's ask Adrian, AFAIK he wrote that code.
> > Adrian, can you please clarify why nandsim needs to play with PF_MEMALLOC?
> 
> I was thinking about it and concluded that since the simulator can be
> used as a block device where reclaimed pages go to, writing the data out
> is a memalloc operation. Then reading can be called as part of r-m-w
> cycle, so reading as well. But it would be great if somebody more
> knowledgeable confirmed this.

then this deserves a big fat comment explaining all the details,
including how the complete depletion of reserves is prevented.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
