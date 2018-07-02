Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C483B6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 10:48:33 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f6-v6so5848105eds.6
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 07:48:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 28-v6si461272eds.137.2018.07.02.07.48.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 07:48:32 -0700 (PDT)
Date: Mon, 2 Jul 2018 16:48:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180702144827.GC19043@dhcp22.suse.cz>
References: <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
 <20180627145718.GB20171@ziepe.ca>
 <20180627170246.qfvucs72seqabaef@quack2.suse.cz>
 <1f6e79c5-5801-16d2-18a6-66bd0712b5b8@nvidia.com>
 <20180628091743.khhta7nafuwstd3m@quack2.suse.cz>
 <20180702055251.GV3014@mtr-leonro.mtl.com>
 <235a23e3-6e02-234c-3e20-b2dddc93e568@nvidia.com>
 <20180702070227.jj5udrdk3rxzjj4t@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702070227.jj5udrdk3rxzjj4t@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Leon Romanovsky <leon@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Mon 02-07-18 09:02:27, Jan Kara wrote:
> On Sun 01-07-18 23:10:04, John Hubbard wrote:
[...]
> > That is an interesting point. 
> > 
> > Holding off page writeback of this region does seem like it could cause
> > problems under memory pressure. Maybe adjusting the watermarks so that we
> > tell the writeback  system, "all is well, just ignore this region until
> > we're done with it" might help? Any ideas here are welcome...
> > 
> > Longer term, maybe some additional work could allow the kernel to be able
> > to writeback the gup-pinned pages (while DMA is happening--snapshots), but
> > that seems like a pretty big overhaul.
> 
> We could use bounce pages to safely writeback pinned pages. However I don't
> think it would buy us anything. From MM point of view these pages are
> impossible-to-get-rid-of (page refcount is increased) and pernamently-dirty
> when GUP was for write (we don't know when dirty data arrives there). So
> let's not just fool MM by pretending we can make them clean. That's going
> to lead to just more problems down the road.

Absolutely agreed! We really need to have means to identify those pages
first. Only then we can make an educated guess what to do about them.
Adding kludges here and there is a wrong way about dealing with this
whole problem. So try to focus on a) a reliable way to detect a longterm
pin and b) provide an API that would tell the page to be released by its
current owner (ideally in two modes, async to kick the process in the
background and continue with something else and sync if there is no
other way than waiting for the pin.

-- 
Michal Hocko
SUSE Labs
