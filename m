Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0318C6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 09:23:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w14-v6so4249412qkw.2
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 06:23:33 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id c79-v6si3670231qkg.128.2018.07.27.06.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 06:23:32 -0700 (PDT)
Subject: Re: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
References: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
 <20180726194209.GB12992@bombadil.infradead.org>
 <b3430dd4-a4d6-28f1-09a1-82e0bf4a3b83@cybernetics.com>
 <20180727000708.GA785@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <cae33099-3147-5014-ab4e-c22a4d66dc49@cybernetics.com>
Date: Fri, 27 Jul 2018 09:23:30 -0400
MIME-Version: 1.0
In-Reply-To: <20180727000708.GA785@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

On 07/26/2018 08:07 PM, Matthew Wilcox wrote:
> On Thu, Jul 26, 2018 at 04:06:05PM -0400, Tony Battersby wrote:
>> On 07/26/2018 03:42 PM, Matthew Wilcox wrote:
>>> On Thu, Jul 26, 2018 at 02:54:56PM -0400, Tony Battersby wrote:
>>>> dma_pool_free() scales poorly when the pool contains many pages because
>>>> pool_find_page() does a linear scan of all allocated pages.  Improve its
>>>> scalability by replacing the linear scan with a red-black tree lookup. 
>>>> In big O notation, this improves the algorithm from O(n^2) to O(n * log n).
>>> This is a lot of code to get us to O(n * log(n)) when we can use less
>>> code to go to O(n).  dma_pool_free() is passed the virtual address.
>>> We can go from virtual address to struct page with virt_to_page().
>>> In struct page, we have 5 words available (20/40 bytes), and it's trivial
>>> to use one of them to point to the struct dma_page.
>>>
>> Thanks for the tip.A  I will give that a try.
> If you're up for more major surgery, then I think we can put all the
> information currently stored in dma_page into struct page.  Something
> like this:
>
> +++ b/include/linux/mm_types.h
> @@ -152,6 +152,12 @@ struct page {
>                         unsigned long hmm_data;
>                         unsigned long _zd_pad_1;        /* uses mapping */
>                 };
> +               struct {        /* dma_pool pages */
> +                       struct list_head dma_list;
> +                       unsigned short in_use;
> +                       unsigned short offset;
> +                       dma_addr_t dma;
> +               };
>  
>                 /** @rcu_head: You can use this to free a page by RCU. */
>                 struct rcu_head rcu_head;
>
> page_list -> dma_list
> vaddr goes away (page_to_virt() exists)
> dma -> dma
> in_use and offset shrink from 4 bytes to 2.
>
> Some 32-bit systems have a 64-bit dma_addr_t, and on those systems,
> this will be 8 + 2 + 2 + 8 = 20 bytes.  On 64-bit systems, it'll be
> 16 + 2 + 2 + 4 bytes of padding + 8 = 32 bytes (we have 40 available).
>
>
offset at least needs more bits, since allocations can be multi-page.A 
See the following from mpt3sas:

cat /sys/devices/pci0000:80/0000:80:07.0/0000:85:00.0/pools
(manually cleaned up column alignment)
poolinfo - 0.1
reply_post_free_array pool  1      21     192     1
reply_free pool             1      1      41728   1
reply pool                  1      1      1335296 1
sense pool                  1      1      970272  1
chain pool                  373959 386048 128     12064
reply_post_free pool        12     12     166528  12
                                          ^size^

In my initial implementation I also added a pointer from struct page to
the dma_pool so that dma_pool_free() could sanity-check that the page
really belongs to the pool, as in:

pg = virt_to_page(vaddr);
if (unlikely(pg->dma_pool != pool)) {
	handle error...
}
page = pg->dma_page;

The linked-list search previously implemented that check as a
by-product, and I didn't want to lose it.A  It all seems to be working so
far.
