Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 83DE56B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 10:17:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x43so9418099wrb.9
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 07:17:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si6694wmb.161.2017.07.19.07.17.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 07:17:02 -0700 (PDT)
Date: Wed, 19 Jul 2017 16:16:59 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v3 1/5] mm: add vm_insert_mixed_mkwrite()
Message-ID: <20170719141659.GB15908@quack2.suse.cz>
References: <20170628220152.28161-1-ross.zwisler@linux.intel.com>
 <20170628220152.28161-2-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170628220152.28161-2-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

On Wed 28-06-17 16:01:48, Ross Zwisler wrote:
> To be able to use the common 4k zero page in DAX we need to have our PTE
> fault path look more like our PMD fault path where a PTE entry can be
> marked as dirty and writeable as it is first inserted, rather than waiting
> for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.
> 
> Right now we can rely on having a dax_pfn_mkwrite() call because we can
> distinguish between these two cases in do_wp_page():
> 
> 	case 1: 4k zero page => writable DAX storage
> 	case 2: read-only DAX storage => writeable DAX storage
> 
> This distinction is made by via vm_normal_page().  vm_normal_page() returns
> false for the common 4k zero page, though, just as it does for DAX ptes.
> Instead of special casing the DAX + 4k zero page case, we will simplify our
> DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
> get rid of dax_pfn_mkwrite() completely.
> 
> This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
> and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
> will do the work that was previously done by wp_page_reuse() as part of the
> dax_pfn_mkwrite() call path.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>

Just one small comment below.

> @@ -1658,14 +1658,26 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
>  	if (!pte)
>  		goto out;
>  	retval = -EBUSY;
> -	if (!pte_none(*pte))
> -		goto out_unlock;
> +	if (!pte_none(*pte)) {
> +		if (mkwrite) {
> +			entry = *pte;
> +			goto out_mkwrite;

Can we maybe check here that (pte_pfn(*pte) == pfn_t_to_pfn(pfn)) and
return -EBUSY otherwise? That way we are sure insert_pfn() isn't doing
anything we don't expect and if I understand the code right, we need to
invalidate all zero page mappings at given file offset (via
unmap_mapping_range()) before mapping an allocated block there and thus the
case of filling the hole won't be affected by this?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
