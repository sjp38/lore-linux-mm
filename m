Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E5D2F6B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 07:33:56 -0400 (EDT)
Received: by pddn5 with SMTP id n5so18071585pdd.2
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 04:33:56 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id lx6si19073771pdb.209.2015.03.31.04.33.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 31 Mar 2015 04:33:55 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM200AC3QYZCZ10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 31 Mar 2015 12:37:47 +0100 (BST)
Message-id: <551A861B.7020701@samsung.com>
Date: Tue, 31 Mar 2015 14:33:47 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com>
 <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com>
 <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

On 03/27/2015 01:50 AM, David Rientjes wrote:
> We don't have a need to set PAGE_EXT_DEBUG_POISON on these pages sitting 
> in the reserved pool, nor do we have a need to do kmap_atomic() since it's 
> already mapped and must be mapped to be on the reserved pool, which is 
> handled by mempool_free().
> 

Hmm.. I just realized that this statement might be wrong.
Why pages has to be mapped to be on reserved pool?
mempool could be used for highmem pages and there is no need to kmap()
until these pages will be used.

drbd (drivers/block/drbd) already uses mempool for highmem pages:

static int drbd_create_mempools(void)
{
....
	drbd_md_io_page_pool = mempool_create_page_pool(DRBD_MIN_POOL_PAGES, 0);
....
}



static void bm_page_io_async(struct drbd_bm_aio_ctx *ctx, int page_nr) __must_hold(local)
{
....
		page = mempool_alloc(drbd_md_io_page_pool, __GFP_HIGHMEM|__GFP_WAIT);
		copy_highpage(page, b->bm_pages[page_nr]);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
