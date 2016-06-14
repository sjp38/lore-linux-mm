Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 644B76B0005
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 07:12:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so283868790pfa.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:12:26 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h192si38208094pfc.70.2016.06.14.04.12.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Jun 2016 04:12:24 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm, tree wide: replace __GFP_REPEAT by __GFP_RETRY_HARD with more useful semantic
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160607123149.GK12305@dhcp22.suse.cz>
	<201606112335.HBG09891.OLFJOFtVMOQHSF@I-love.SAKURA.ne.jp>
	<20160613113726.GE6518@dhcp22.suse.cz>
	<201606132354.AJG05292.MOFVQJOFLFSHtO@I-love.SAKURA.ne.jp>
	<20160613151726.GL6518@dhcp22.suse.cz>
In-Reply-To: <20160613151726.GL6518@dhcp22.suse.cz>
Message-Id: <201606142012.HEJ69240.FFLFOOtMJVOSHQ@I-love.SAKURA.ne.jp>
Date: Tue, 14 Jun 2016 20:12:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > > That _somebody_ might release oom_lock without invoking the OOM killer (e.g.
> > > > doing !__GFP_FS allocation), which means that we have reached the OOM condition
> > > > and nobody is actually handling the OOM on our behalf. __GFP_RETRY_HARD becomes
> > > > as weak as __GFP_NORETRY. I think this is a regression.
> > > 
> > > I really fail to see your point. We are talking about a gfp flag which
> > > tells the allocator to retry as much as it is feasible. Getting through
> > > all the reclaim attempts two times without any progress sounds like a
> > > fair criterion. Well, we could try $NUM times but that wouldn't make too
> > > much difference to what you are writing above. The fact whether somebody
> > > has been killed or not is not really that important IMHO.
> > 
> > If all the reclaim attempt first time made no progress, all the reclaim
> > attempt second time unlikely make progress unless the OOM killer kills
> > something. Thus, doing all the reclaim attempts two times without any progress
> > without killing somebody sounds almost equivalent to doing all the reclaim
> > attempt only once.
> 
> Yes, that is possible. You might have a GFP_NOFS only load where nothing
> really invokes the OOM killer. Does that actually matter, though? The
> semantic of the flag is to retry hard while the page allocator believes
> it can make a forward progress. But not for ever. We never know whether
> a progress is possible at all. We have certain heuristics when to give
> up, try to invoke OOM killer and try again hoping things have changed.
> This is not much different except we declare that no hope to getting to
> the OOM point again without being able to succeed. Are you suggesting
> a more precise heuristic? Or do you claim that we do not need a flag
> which would put a middle ground between __GFP_NORETRY and __GFP_NOFAIL
> which are on the extreme sides?

Well, maybe we can get rid of __GFP_RETRY (or make __GFP_RETRY used for only
huge pages). Many __GFP_RETRY users are ready to fall back to vmalloc().

We are not sure whether such __GFP_RETRY users want to retry with OOM-killing
somebody (we don't have __GFP_MAY_OOM_KILL which explicitly asks for "retry
with OOM-killing somebody").

If __GFP_RETRY means nothing but try once more,

	void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
	if (!n)
		n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);

will emulate it.



----- arch/powerpc/include/asm/book3s/64/pgalloc.h -----

static inline pgd_t *radix__pgd_alloc(struct mm_struct *mm)
{
#ifdef CONFIG_PPC_64K_PAGES
        return (pgd_t *)__get_free_page(PGALLOC_GFP);
#else
        struct page *page;
        page = alloc_pages(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO | __GFP_REPEAT, 4);
        if (!page)
                return NULL;
        return (pgd_t *) page_address(page);
#endif
}

----- arch/powerpc/kvm/book3s_64_mmu_hv.c -----

        kvm->arch.hpt_cma_alloc = 0;
        page = kvm_alloc_hpt(1ul << (order - PAGE_SHIFT));
        if (page) {
                hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));
                memset((void *)hpt, 0, (1ul << order));
                kvm->arch.hpt_cma_alloc = 1;
        }

        /* Lastly try successively smaller sizes from the page allocator */
        /* Only do this if userspace didn't specify a size via ioctl */
        while (!hpt && order > 18 && !htab_orderp) {
                hpt = __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT|
                                       __GFP_NOWARN, order - PAGE_SHIFT);
                if (!hpt)
                        --order;
        }

        if (!hpt)
                return -ENOMEM;

----- drivers/vhost/vhost.c -----

static void *vhost_kvzalloc(unsigned long size)
{
        void *n = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);

        if (!n)
                n = vzalloc(size);
        return n;
}

----- drivers/vhost/scsi.c -----

        vs = kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!vs) {
                vs = vzalloc(sizeof(*vs));
                if (!vs)
                        goto err_vs;
        }

----- drivers/vhost/net.c -----

        n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!n) {
                n = vmalloc(sizeof *n);
                if (!n)
                        return -ENOMEM;
        }

----- drivers/block/xen-blkfront.c -----

                /* Stage 1: Make a safe copy of the shadow state. */
                copy = kmemdup(rinfo->shadow, sizeof(rinfo->shadow),
                               GFP_NOIO | __GFP_REPEAT | __GFP_HIGH);
                if (!copy)
                        return -ENOMEM;

----- drivers/mmc/host/wbsd.c -----

        /*
         * We need to allocate a special buffer in
         * order for ISA to be able to DMA to it.
         */
        host->dma_buffer = kmalloc(65536,
                GFP_NOIO | GFP_DMA | __GFP_REPEAT | __GFP_NOWARN);
        if (!host->dma_buffer)
                goto free;

----- drivers/target/target_core_transport.c -----

        se_sess->sess_cmd_map = kzalloc(tag_num * tag_size,
                                        GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!se_sess->sess_cmd_map) {
                se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
                if (!se_sess->sess_cmd_map) {
                        pr_err("Unable to allocate se_sess->sess_cmd_map\n");
                        return -ENOMEM;
                }
        }

----- drivers/s390/char/vmcp.c -----

        if (mutex_lock_interruptible(&session->mutex)) {
                kfree(cmd);
                return -ERESTARTSYS;
        }
        if (!session->response)
                session->response = (char *)__get_free_pages(GFP_KERNEL
                                                | __GFP_REPEAT | GFP_DMA,
                                                get_order(session->bufsize));
        if (!session->response) {
                mutex_unlock(&session->mutex);
                kfree(cmd);
                return -ENOMEM;
        }

----- fs/btrfs/raid56.c -----

        table_size = sizeof(*table) + sizeof(*h) * num_entries;
        table = kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!table) {
                table = vzalloc(table_size);
                if (!table)
                        return -ENOMEM;
        }

----- fs/btrfs/check-integrity.c -----

        state = kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!state) {
                state = vzalloc(sizeof(*state));
                if (!state) {
                        printk(KERN_INFO "btrfs check-integrity: vzalloc() failed!\n");
                        return -1;
                }
        }

----- mm/sparse-vmemmap.c -----

void * __meminit vmemmap_alloc_block(unsigned long size, int node)
{
        /* If the main allocator is up use that, fallback to bootmem. */
        if (slab_is_available()) {
                struct page *page;

                if (node_state(node, N_HIGH_MEMORY))
                        page = alloc_pages_node(
                                node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
                                get_order(size));
                else
                        page = alloc_pages(
                                GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
                                get_order(size));
                if (page)
                        return page_address(page);
                return NULL;
        } else
                return __earlyonly_bootmem_alloc(node, size, size,
                                __pa(MAX_DMA_ADDRESS));
}

----- mm/hugetlb.c -----

static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
{
        struct page *page;

        page = __alloc_pages_node(nid,
                htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
                                                __GFP_REPEAT|__GFP_NOWARN,
                huge_page_order(h));
        if (page) {
                prep_new_huge_page(h, page, nid);
        }

        return page;
}

static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
                struct vm_area_struct *vma, unsigned long addr, int nid)
{
        int order = huge_page_order(h);
        gfp_t gfp = htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
        unsigned int cpuset_mems_cookie;

----- net/core/skbuff.c -----

        gfp_head = gfp_mask;
        if (gfp_head & __GFP_DIRECT_RECLAIM)
                gfp_head |= __GFP_REPEAT;

        *errcode = -ENOBUFS;
        skb = alloc_skb(header_len, gfp_head);
        if (!skb)
                return NULL;

----- net/core/dev.c -----

        rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!rx) {
                rx = vzalloc(sz);
                if (!rx)
                        return -ENOMEM;
        }
        dev->_rx = rx;

        tx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!tx) {
                tx = vzalloc(sz);
                if (!tx)
                        return -ENOMEM;
        }
        dev->_tx = tx;

        p = kzalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
        if (!p)
                p = vzalloc(alloc_size);
        if (!p)
                return NULL;

----- net/sched/sch_fq.c -----

static void *fq_alloc_node(size_t sz, int node)
{
        void *ptr;

        ptr = kmalloc_node(sz, GFP_KERNEL | __GFP_REPEAT | __GFP_NOWARN, node);
        if (!ptr)
                ptr = vmalloc_node(sz, node);
        return ptr;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
