Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2B36B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:49:02 -0400 (EDT)
Received: by wijp15 with SMTP id p15so261997146wij.0
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:49:01 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id mi6si4410227wic.25.2015.08.13.07.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 07:49:00 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so72978710wic.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:48:59 -0700 (PDT)
Message-ID: <55CCAE57.20009@plexistor.com>
Date: Thu, 13 Aug 2015 17:48:55 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/5] allow mapping page-less memremaped areas into
 KVA
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com> <20150813030109.36703.21738.stgit@otcpl-skl-sds-2.jf.intel.com> <55CC3222.5090503@plexistor.com> <20150813143744.GA17375@lst.de>
In-Reply-To: <20150813143744.GA17375@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org

On 08/13/2015 05:37 PM, Christoph Hellwig wrote:
> Hi Boaz,
> 
> can you please fix your quoting?  I read down about 10 pages but still
> couldn't find a comment from you.  For now I gave up on this mail.
> 

Sorry here:

> +void *kmap_atomic_pfn_t(__pfn_t pfn)
> +{
> +	struct page *page = __pfn_t_to_page(pfn);
> +	resource_size_t addr;
> +	struct kmap *kmap;
> +
> +	rcu_read_lock();
> +	if (page)
> +		return kmap_atomic(page);

Right even with pages I pay rcu_read_lock(); for every access?

> +	addr = __pfn_t_to_phys(pfn);
> +	list_for_each_entry_rcu(kmap, &ranges, list)
> +		if (addr >= kmap->res->start && addr <= kmap->res->end)
> +			return kmap->base + addr - kmap->res->start;
> +

Good god! This loop is a real *joke*. You have just dropped memory access
performance by 10 fold.

The all point of pages and memory_model.h was to have a one to one
relation-ships between Kernel-virtual vs physical vs page *

There is already an object that holds a relationship of physical
to Kernel-virtual. It is called a memory-section. Why not just
widen its definition?

If you are willing to accept this loop. In current Linux 2015 Kernel
Then I have nothing farther to say.

Boaz - go mourning for the death of the Linux Kernel alone in the corner ;-(

> +	/* only unlock in the error case */
> +	rcu_read_unlock();
> +	return NULL;
> +}
> +EXPORT_SYMBOL(kmap_atomic_pfn_t);
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
