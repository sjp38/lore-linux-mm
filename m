Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A2F116B05CC
	for <linux-mm@kvack.org>; Fri, 18 May 2018 05:41:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a127-v6so3440200wmh.6
        for <linux-mm@kvack.org>; Fri, 18 May 2018 02:41:35 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id l13-v6si6516041wrg.412.2018.05.18.02.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 02:41:33 -0700 (PDT)
Date: Fri, 18 May 2018 11:46:16 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v10] mm: introduce MEMORY_DEVICE_FS_DAX and
	CONFIG_DEV_PAGEMAP_OPS
Message-ID: <20180518094616.GA25838@lst.de>
References: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152658753673.26786.16458605771414761966.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>, kbuild test robot <lkp@intel.com>, Thomas Meyer <thomas@m3y3r.de>, Dave Jiang <dave.jiang@intel.com>, Christoph Hellwig <hch@lst.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

This looks reasonable to me.  A few more comments below.

> This patch replaces and consolidates patch 2 [1] and 4 [2] from the v9
> series [3] for "dax: fix dma vs truncate/hole-punch".

Can you repost the whole series?  Otherwise things might get a little
too confusing.

>  		WARN_ON(IS_ENABLED(CONFIG_ARCH_HAS_PMEM_API));
> +		return 0;
>  	} else if (pfn_t_devmap(pfn)) {
> +		struct dev_pagemap *pgmap;

This should probably become something like:

	bool supported = false;

	...


	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED) && pfn_t_special(pfn)) {
		...
		supported = true;
	} else if (pfn_t_devmap(pfn)) {
		pgmap = get_dev_pagemap(pfn_t_to_pfn(pfn), NULL);
		if (pgmap && pgmap->type == MEMORY_DEVICE_FS_DAX)
			supported = true;
		put_dev_pagemap(pgmap);
	}

	if (!supported) {
		pr_debug("VFS (%s): error: dax support not enabled\n",
			sb->s_id);
		return -EOPNOTSUPP;
	}
	return 0;

> +	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)

Btw, what was the reason again we couldn't get rid of FS_DAX_LIMITED?

> +void generic_dax_pagefree(struct page *page, void *data)
> +{
> +	wake_up_var(&page->_refcount);
> +}
> +EXPORT_SYMBOL_GPL(generic_dax_pagefree);

Why is this here and exported instead of static in drivers/nvdimm/pmem.c?
