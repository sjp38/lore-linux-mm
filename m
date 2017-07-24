Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C27F76B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 18:14:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v68so141067576pfi.13
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 15:14:08 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id u13si1542838plm.1029.2017.07.24.15.14.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 15:14:06 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id k72so8075768pfj.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 15:14:06 -0700 (PDT)
Date: Tue, 25 Jul 2017 01:14:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v5 1/5] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170724221400.pcq5zvke7w2yfkxi@node.shutemov.name>
References: <20170724170616.25810-1-ross.zwisler@linux.intel.com>
 <20170724170616.25810-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724170616.25810-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Mon, Jul 24, 2017 at 11:06:12AM -0600, Ross Zwisler wrote:
> @@ -1658,14 +1658,35 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> -		goto out_unlock;
> +	if (!pte_none(*pte)) {
> +		if (mkwrite) {
> +			/*
> +			 * For read faults on private mappings the PFN passed
> +			 * in may not match the PFN we have mapped if the
> +			 * mapped PFN is a writeable COW page.  In the mkwrite
> +			 * case we are creating a writable PTE for a shared
> +			 * mapping and we expect the PFNs to match.
> +			 */

Can we?

I guess it's up to filesystem if it wants to reuse the same spot to write
data or not. I think your assumptions works for ext4 and xfs. I wouldn't
be that sure for btrfs or other filesystems with CoW support.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
