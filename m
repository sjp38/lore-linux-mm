Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C77896B0038
	for <linux-mm@kvack.org>; Fri, 30 Sep 2016 05:44:37 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id fu14so189472860pad.0
        for <linux-mm@kvack.org>; Fri, 30 Sep 2016 02:44:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 7si19329598pfy.231.2016.09.30.02.44.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Sep 2016 02:44:37 -0700 (PDT)
Date: Fri, 30 Sep 2016 02:44:19 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 07/12] dax: coordinate locking for offsets in PMD range
Message-ID: <20160930094419.GA5299@infradead.org>
References: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
 <1475189370-31634-8-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475189370-31634-8-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-xfs@vger.kernel.org

> +static pgoff_t dax_entry_start(pgoff_t index, void *entry)
> +{
> +	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> +		index &= (PMD_MASK >> PAGE_SHIFT);
> +	return index;
> +}
> +
>  static wait_queue_head_t *dax_entry_waitqueue(struct address_space *mapping,
> -					      pgoff_t index)
> +					      pgoff_t entry_start)
>  {
> -	unsigned long hash = hash_long((unsigned long)mapping ^ index,
> +	unsigned long hash = hash_long((unsigned long)mapping ^ entry_start,
>  				       DAX_WAIT_TABLE_BITS);
>  	return wait_table + hash;
>  }

All callers of dax_entry_waitqueue need to calculate entry_start
using this new dax_entry_start helper.  Either we should move the
call to dax_entry_start into this helper.  Or at least use local
variables for in the callers as both of them also fill out a
wait_exceptional_entry_queue structure with it.  Or do both by
letting dax_entry_waitqueue fill out that structure as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
