Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3D11C6B1A43
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 13:38:23 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d40-v6so10289003pla.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 10:38:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s2-v6si11174066pfs.2.2018.08.20.10.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 Aug 2018 10:38:21 -0700 (PDT)
Date: Mon, 20 Aug 2018 10:38:16 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: introduce kvvirt_to_page() helper
Message-ID: <20180820173816.GE25153@bombadil.infradead.org>
References: <1534596541-31393-1-git-send-email-lirongqing@baidu.com>
 <20180820144116.GO29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820144116.GO29735@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Li RongQing <lirongqing@baidu.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>, darrick.wong@oracle.com

On Mon, Aug 20, 2018 at 04:41:16PM +0200, Michal Hocko wrote:
> > +++ b/fs/xfs/xfs_buf.c
> >  	for (i = 0; i < bp->b_page_count; i++) {
> > -		bp->b_pages[i] = mem_to_page((void *)pageaddr);
> > +		bp->b_pages[i] = kvvirt_to_page((void *)pageaddr);
> >  		pageaddr += PAGE_SIZE;

This wants mem_range_to_page_array().

> > +++ b/net/9p/trans_virtio.c
> >  		for (index = 0; index < nr_pages; index++) {
> > -			if (is_vmalloc_addr(p))
> > -				(*pages)[index] = vmalloc_to_page(p);
> > -			else
> > -				(*pages)[index] = kmap_to_page(p);
> > +			(*pages)[index] = kvvirt_to_page(p);

Also mem_range_to_page_array().

> > +++ b/net/ceph/crypto.c
> > @@ -191,11 +191,7 @@ static int setup_sgtable(struct sg_table *sgt, struct scatterlist *prealloc_sg,
> >  		struct page *page;
> >  		unsigned int len = min(chunk_len - off, buf_len);
> >  
> > -		if (is_vmalloc)
> > -			page = vmalloc_to_page(buf);
> > -		else
> > -			page = virt_to_page(buf);
> > -
> > +		page = kvvirt_to_page(buf);
> >  		sg_set_page(sg, page, len, off);
> >  
> >  		off = 0;

This whole function wants to move into the core and be called something like
sg_alloc_table_from_virt().

> > +++ b/net/packet/af_packet.c
> > @@ -374,15 +367,15 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
> >  	switch (po->tp_version) {
> >  	case TPACKET_V1:
> >  		h.h1->tp_status = status;
> > -		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h1->tp_status));

This driver really wants flush_dcache_range(start, len).
