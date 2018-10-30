Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C49346B04C2
	for <linux-mm@kvack.org>; Tue, 30 Oct 2018 02:06:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so8775076edb.3
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 23:06:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si4673918edi.191.2018.10.29.23.06.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 23:06:05 -0700 (PDT)
Date: Tue, 30 Oct 2018 07:06:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: use kvmalloc instead of kmalloc
Message-ID: <20181030060601.GR32673@dhcp22.suse.cz>
References: <1540790176-32339-1-git-send-email-miles.chen@mediatek.com>
 <20181029080708.GA32673@dhcp22.suse.cz>
 <20181029081706.GC32673@dhcp22.suse.cz>
 <1540862950.12374.40.camel@mtkswgap22>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1540862950.12374.40.camel@mtkswgap22>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miles Chen <miles.chen@mediatek.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mediatek@lists.infradead.org, wsd_upstream@mediatek.com

On Tue 30-10-18 09:29:10, Miles Chen wrote:
> On Mon, 2018-10-29 at 09:17 +0100, Michal Hocko wrote:
> > On Mon 29-10-18 09:07:08, Michal Hocko wrote:
> > [...]
> > > Besides that, the following doesn't make much sense to me. It simply
> > > makes no sense to use vmalloc for sub page allocation regardless of
> > > HIGHMEM.
> > 
> > OK, it is still early morning here. Now I get the point of the patch.
> > You just want to (ab)use highmeme for smaller requests. I do not like
> > this, to be honest. It causes an internal fragmentation and more
> > importantly the VMALLOC space on 32b where HIGHMEM is enabled (do we
> > have any 64b with HIGHMEM btw?) is quite small to be wasted like that.
> > 
> thanks for your comment. It looks like that using vmalloc fallback for
> sub page allocation is not good here.
> 
> Your comment gave another idea:
> 
> 1. force kbuf to PAGE_SIZE
> 2. allocate a page by alloc_page(GFP_KERNEL | __GFP_HIGHMEM); so we can
> get a highmem page if possible
> 3. use kmap/kunmap pair to create mapping for this page. No vmalloc
> space is used.
> 4. do not change kvmalloc logic.

If you mean for this particular situation then is this really worth
it? I mean this is a short term allocation for root only so you do not
have to worry about low mem depletion.

If you are thiking in more generic terms to allow kmalloc to use highmem
then I am not really sure this will work out.
-- 
Michal Hocko
SUSE Labs
