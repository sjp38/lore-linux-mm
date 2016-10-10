Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81AFF6B0263
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 11:59:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n3so41874317lfn.5
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 08:59:19 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id gm1si2659394wjd.166.2016.10.10.08.59.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 08:59:18 -0700 (PDT)
Date: Mon, 10 Oct 2016 17:59:17 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v5 15/17] dax: add struct iomap based DAX PMD support
Message-ID: <20161010155917.GA19978@lst.de>
References: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com> <1475874544-24842-16-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475874544-24842-16-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Fri, Oct 07, 2016 at 03:09:02PM -0600, Ross Zwisler wrote:
> -	if (RADIX_DAX_TYPE(entry) == RADIX_DAX_PMD)
> +	if ((unsigned long)entry & RADIX_DAX_PMD)

Please introduce a proper inline helper that mask all the possible type
bits out of the radix tree entry, and use them wherever you do the
open cast.

>  restart:
>  	spin_lock_irq(&mapping->tree_lock);
>  	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> +
> +	if (entry) {
> +		if (size_flag & RADIX_DAX_PMD) {
> +			if (!radix_tree_exceptional_entry(entry) ||
> +			    !((unsigned long)entry & RADIX_DAX_PMD)) {
> +				entry = ERR_PTR(-EEXIST);
> +				goto out_unlock;
> +			}
> +		} else { /* trying to grab a PTE entry */
> +			if (radix_tree_exceptional_entry(entry) &&
> +			    ((unsigned long)entry & RADIX_DAX_PMD) &&
> +			    ((unsigned long)entry &
> +			     (RADIX_DAX_HZP|RADIX_DAX_EMPTY))) {

And when we do these cases N times next to each other we should
have a local variable the valid flag bits of entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
