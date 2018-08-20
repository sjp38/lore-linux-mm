Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13A626B198B
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 10:49:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id n21-v6so10088521plp.9
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 07:49:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 82-v6si10001599pfo.229.2018.08.20.07.49.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 Aug 2018 07:49:28 -0700 (PDT)
Date: Mon, 20 Aug 2018 07:49:23 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: introduce kvvirt_to_page() helper
Message-ID: <20180820144923.GA25153@bombadil.infradead.org>
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
> On Sat 18-08-18 20:49:01, Li RongQing wrote:
> > The new helper returns address mapping page, which has several users
> > in individual subsystem, like mem_to_page in xfs_buf.c and pgv_to_page
> > in af_packet.c, unify them
> 
> kvvirt_to_page is a weird name. I guess you wanted it to fit into
> kv*alloc, kvfree naming, right? If yes then I guess kvmem_to_page
> would be slightly better.
> 
> Other than that the patch makes sense to me. It would be great to add
> some documentation and be explicit that the call is only safe on
> directly mapped kernel address and vmalloc areas.

... and not safe if the length crosses a page boundary.  I don't want to
see new code emerge that does kvmalloc(PAGE_SIZE * 2, ...); kvmem_to_page()
and have it randomly crash when kvmalloc happens to fall back to vmalloc()
under heavy memory pressure.

Also, people are going to start using this for stack addresses.  Perhaps
we should have a debug option to guard against them doing that.

> > Signed-off-by: Zhang Yu <zhangyu31@baidu.com>
> > Signed-off-by: Li RongQing <lirongqing@baidu.com>
> > ---
> >  fs/xfs/xfs_buf.c       | 13 +------------
> >  include/linux/mm.h     |  8 ++++++++
> >  net/9p/trans_virtio.c  |  5 +----
> >  net/ceph/crypto.c      |  6 +-----
> >  net/packet/af_packet.c | 31 ++++++++++++-------------------
> >  5 files changed, 23 insertions(+), 40 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> > index e839907e8492..edd22b33f49e 100644
> > --- a/fs/xfs/xfs_buf.c
> > +++ b/fs/xfs/xfs_buf.c
> > @@ -866,17 +866,6 @@ xfs_buf_set_empty(
> >  	bp->b_maps[0].bm_len = bp->b_length;
> >  }
> >  
> > -static inline struct page *
> > -mem_to_page(
> > -	void			*addr)
> > -{
> > -	if ((!is_vmalloc_addr(addr))) {
> > -		return virt_to_page(addr);
> > -	} else {
> > -		return vmalloc_to_page(addr);
> > -	}
> > -}
> > -
> >  int
> >  xfs_buf_associate_memory(
> >  	xfs_buf_t		*bp,
> > @@ -909,7 +898,7 @@ xfs_buf_associate_memory(
> >  	bp->b_offset = offset;
> >  
> >  	for (i = 0; i < bp->b_page_count; i++) {
> > -		bp->b_pages[i] = mem_to_page((void *)pageaddr);
> > +		bp->b_pages[i] = kvvirt_to_page((void *)pageaddr);
> >  		pageaddr += PAGE_SIZE;
> >  	}
> >  
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 68a5121694ef..bb34a3c71df5 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -599,6 +599,14 @@ static inline void *kvcalloc(size_t n, size_t size, gfp_t flags)
> >  	return kvmalloc_array(n, size, flags | __GFP_ZERO);
> >  }
> >  
> > +static inline struct page *kvvirt_to_page(const void *addr)
> > +{
> > +	if (!is_vmalloc_addr(addr))
> > +		return virt_to_page(addr);
> > +	else
> > +		return vmalloc_to_page(addr);
> > +}
> > +
> >  extern void kvfree(const void *addr);
> >  
> >  static inline atomic_t *compound_mapcount_ptr(struct page *page)
> > diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
> > index 05006cbb3361..8f1895f15593 100644
> > --- a/net/9p/trans_virtio.c
> > +++ b/net/9p/trans_virtio.c
> > @@ -368,10 +368,7 @@ static int p9_get_mapped_pages(struct virtio_chan *chan,
> >  		*need_drop = 0;
> >  		p -= (*offs = offset_in_page(p));
> >  		for (index = 0; index < nr_pages; index++) {
> > -			if (is_vmalloc_addr(p))
> > -				(*pages)[index] = vmalloc_to_page(p);
> > -			else
> > -				(*pages)[index] = kmap_to_page(p);
> > +			(*pages)[index] = kvvirt_to_page(p);
> >  			p += PAGE_SIZE;
> >  		}
> >  		return len;
> > diff --git a/net/ceph/crypto.c b/net/ceph/crypto.c
> > index 02172c408ff2..cc5f0723a44d 100644
> > --- a/net/ceph/crypto.c
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
> > diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> > index 5610061e7f2e..1bec111122ad 100644
> > --- a/net/packet/af_packet.c
> > +++ b/net/packet/af_packet.c
> > @@ -359,13 +359,6 @@ static void unregister_prot_hook(struct sock *sk, bool sync)
> >  		__unregister_prot_hook(sk, sync);
> >  }
> >  
> > -static inline struct page * __pure pgv_to_page(void *addr)
> > -{
> > -	if (is_vmalloc_addr(addr))
> > -		return vmalloc_to_page(addr);
> > -	return virt_to_page(addr);
> > -}
> > -
> >  static void __packet_set_status(struct packet_sock *po, void *frame, int status)
> >  {
> >  	union tpacket_uhdr h;
> > @@ -374,15 +367,15 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
> >  	switch (po->tp_version) {
> >  	case TPACKET_V1:
> >  		h.h1->tp_status = status;
> > -		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h1->tp_status));
> >  		break;
> >  	case TPACKET_V2:
> >  		h.h2->tp_status = status;
> > -		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h2->tp_status));
> >  		break;
> >  	case TPACKET_V3:
> >  		h.h3->tp_status = status;
> > -		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h3->tp_status));
> >  		break;
> >  	default:
> >  		WARN(1, "TPACKET version not supported.\n");
> > @@ -401,13 +394,13 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
> >  	h.raw = frame;
> >  	switch (po->tp_version) {
> >  	case TPACKET_V1:
> > -		flush_dcache_page(pgv_to_page(&h.h1->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h1->tp_status));
> >  		return h.h1->tp_status;
> >  	case TPACKET_V2:
> > -		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h2->tp_status));
> >  		return h.h2->tp_status;
> >  	case TPACKET_V3:
> > -		flush_dcache_page(pgv_to_page(&h.h3->tp_status));
> > +		flush_dcache_page(kvvirt_to_page(&h.h3->tp_status));
> >  		return h.h3->tp_status;
> >  	default:
> >  		WARN(1, "TPACKET version not supported.\n");
> > @@ -462,7 +455,7 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
> >  	}
> >  
> >  	/* one flush is safe, as both fields always lie on the same cacheline */
> > -	flush_dcache_page(pgv_to_page(&h.h1->tp_sec));
> > +	flush_dcache_page(kvvirt_to_page(&h.h1->tp_sec));
> >  	smp_wmb();
> >  
> >  	return ts_status;
> > @@ -728,7 +721,7 @@ static void prb_flush_block(struct tpacket_kbdq_core *pkc1,
> >  
> >  	end = (u8 *)PAGE_ALIGN((unsigned long)pkc1->pkblk_end);
> >  	for (; start < end; start += PAGE_SIZE)
> > -		flush_dcache_page(pgv_to_page(start));
> > +		flush_dcache_page(kvvirt_to_page(start));
> >  
> >  	smp_wmb();
> >  #endif
> > @@ -741,7 +734,7 @@ static void prb_flush_block(struct tpacket_kbdq_core *pkc1,
> >  
> >  #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE == 1
> >  	start = (u8 *)pbd1;
> > -	flush_dcache_page(pgv_to_page(start));
> > +	flush_dcache_page(kvvirt_to_page(start));
> >  
> >  	smp_wmb();
> >  #endif
> > @@ -2352,7 +2345,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
> >  					macoff + snaplen);
> >  
> >  		for (start = h.raw; start < end; start += PAGE_SIZE)
> > -			flush_dcache_page(pgv_to_page(start));
> > +			flush_dcache_page(kvvirt_to_page(start));
> >  	}
> >  	smp_wmb();
> >  #endif
> > @@ -2508,7 +2501,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
> >  			return -EFAULT;
> >  		}
> >  
> > -		page = pgv_to_page(data);
> > +		page = kvvirt_to_page(data);
> >  		data += len;
> >  		flush_dcache_page(page);
> >  		get_page(page);
> > @@ -4385,7 +4378,7 @@ static int packet_mmap(struct file *file, struct socket *sock,
> >  			int pg_num;
> >  
> >  			for (pg_num = 0; pg_num < rb->pg_vec_pages; pg_num++) {
> > -				page = pgv_to_page(kaddr);
> > +				page = kvvirt_to_page(kaddr);
> >  				err = vm_insert_page(vma, start, page);
> >  				if (unlikely(err))
> >  					goto out;
> > -- 
> > 2.16.2
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
