Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A868B6B000A
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 12:30:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25-v6so3676093pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 09:30:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p11-v6si54473616pfj.294.2018.06.07.09.30.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jun 2018 09:30:39 -0700 (PDT)
Date: Thu, 7 Jun 2018 18:30:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 11/12] mm, memory_failure: Teach memory_failure()
 about dev_pagemap pages
Message-ID: <20180607163036.o7vmi6onrsexphrk@quack2.suse.cz>
References: <152815389835.39010.13253559944508110923.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152815395775.39010.9355109660470832490.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152815395775.39010.9355109660470832490.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon 04-06-18 16:12:37, Dan Williams wrote:
>     mce: Uncorrected hardware memory error in user-access at af34214200
>     {1}[Hardware Error]: It has been corrected by h/w and requires no further action
>     mce: [Hardware Error]: Machine check events logged
>     {1}[Hardware Error]: event severity: corrected
>     Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
>     [..]
>     Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
>     mce: Memory error not recovered
> 
> In contrast to typical memory, dev_pagemap pages may be dax mapped. With
> dax there is no possibility to map in another page dynamically since dax
> establishes 1:1 physical address to file offset associations. Also
> dev_pagemap pages associated with NVDIMM / persistent memory devices can
> internal remap/repair addresses with poison. While memory_failure()
> assumes that it can discard typical poisoned pages and keep them
> unmapped indefinitely, dev_pagemap pages may be returned to service
> after the error is cleared.
> 
> Teach memory_failure() to detect and handle MEMORY_DEVICE_HOST
> dev_pagemap pages that have poison consumed by userspace. Mark the
> memory as UC instead of unmapping it completely to allow ongoing access
> via the device driver (nd_pmem). Later, nd_pmem will grow support for
> marking the page back to WB when the error is cleared.

...

> +static int memory_failure_dev_pagemap(unsigned long pfn, int flags,
> +		struct dev_pagemap *pgmap)
> +{
> +	struct page *page = pfn_to_page(pfn);
> +	const bool unmap_success = true;
> +	struct address_space *mapping;
> +	unsigned long size;
> +	LIST_HEAD(tokill);
> +	int rc = -EBUSY;
> +	loff_t start;
> +
> +	/*
> +	 * Prevent the inode from being freed while we are interrogating
> +	 * the address_space, typically this would be handled by
> +	 * lock_page(), but dax pages do not use the page lock.
> +	 */
> +	rcu_read_lock();
> +	mapping = page->mapping;
> +	if (!mapping) {
> +		rcu_read_unlock();
> +		goto out;
> +	}
> +	if (!igrab(mapping->host)) {
> +		mapping = NULL;
> +		rcu_read_unlock();
> +		goto out;
> +	}
> +	rcu_read_unlock();

Why don't you use radix tree entry lock here instead? That is a direct
replacement of the page lock and you don't have to play games with pinning
the inode and verifying the mapping afterwards.

> +out:
> +	if (mapping)
> +		iput(mapping->host);

BTW, this would have to be prepared to do full inode deletion which I'm not
quite sure is safe from this context.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
