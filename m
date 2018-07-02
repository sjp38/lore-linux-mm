Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D37216B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 06:36:04 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v19-v6so5530772eds.3
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 03:36:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17-v6si433670edr.169.2018.07.02.03.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 03:36:03 -0700 (PDT)
Date: Mon, 2 Jul 2018 12:36:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702103601.GG19043@dhcp22.suse.cz>
References: <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
 <20180702055251.GV3014@mtr-leonro.mtl.com>
 <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
 <20180702063403.GX3014@mtr-leonro.mtl.com>
 <cd6ec2d7-0c19-fb34-e8d3-0459671432b8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd6ec2d7-0c19-fb34-e8d3-0459671432b8@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Leon Romanovsky <leon@kernel.org>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Sun 01-07-18 23:41:21, John Hubbard wrote:
> On 07/01/2018 11:34 PM, Leon Romanovsky wrote:
> > On Sun, Jul 01, 2018 at 11:10:04PM -0700, John Hubbard wrote:
[...]
> >>> Sorry for naive question, but won't it create too much dirty pages
> >>> so writeback will be called "non-stop" to rebalance watermarks without
> >>> ability to progress?
> >>>
> >>
> >> That is an interesting point.
> >>
> >> Holding off page writeback of this region does seem like it could cause
> >> problems under memory pressure. Maybe adjusting the watermarks so that we
> >> tell the writeback  system, "all is well, just ignore this region until
> >> we're done with it" might help? Any ideas here are welcome...
> > 
> > AFAIR, it is per-zone, so the solution to count dirty-but-untouchable
> > number of pages to take them into account for accounting can work, but
> > it seems like an overkill. Can we create special ZONE for such gup
> > pages, or this is impossible too?
> > 
> 
> Let's see what Michal and others prefer. The zone idea intrigues me. 

No new zones please. Pinned pages are essentially mlocked pages, except
they are worse because they cannot be even migrated. What we really
needs is a) limit their usage and b) have a way to find out that pins
are not ephemeral and a special action needs to be taken. What is that
special action is yet to be decided but please do not add even more
complexity on top.

-- 
Michal Hocko
SUSE Labs
