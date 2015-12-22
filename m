Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6179C82F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 17:46:07 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id u7so66364544pfb.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 14:46:07 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q74si28232404pfi.237.2015.12.22.14.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 14:46:06 -0800 (PST)
Date: Tue, 22 Dec 2015 14:46:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 2/7] dax: support dirty DAX entries in radix tree
Message-Id: <20151222144605.08a84ded98a42d6125a7991e@linux-foundation.org>
In-Reply-To: <1450502540-8744-3-git-send-email-ross.zwisler@linux.intel.com>
References: <1450502540-8744-1-git-send-email-ross.zwisler@linux.intel.com>
	<1450502540-8744-3-git-send-email-ross.zwisler@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org, xfs@oss.sgi.com, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Fri, 18 Dec 2015 22:22:15 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:

> Add support for tracking dirty DAX entries in the struct address_space
> radix tree.  This tree is already used for dirty page writeback, and it
> already supports the use of exceptional (non struct page*) entries.
> 
> In order to properly track dirty DAX pages we will insert new exceptional
> entries into the radix tree that represent dirty DAX PTE or PMD pages.
> These exceptional entries will also contain the writeback addresses for the
> PTE or PMD faults that we can use at fsync/msync time.
> 
> There are currently two types of exceptional entries (shmem and shadow)
> that can be placed into the radix tree, and this adds a third.  We rely on
> the fact that only one type of exceptional entry can be found in a given
> radix tree based on its usage.  This happens for free with DAX vs shmem but
> we explicitly prevent shadow entries from being added to radix trees for
> DAX mappings.
> 
> The only shadow entries that would be generated for DAX radix trees would
> be to track zero page mappings that were created for holes.  These pages
> would receive minimal benefit from having shadow entries, and the choice
> to have only one type of exceptional entry in a given radix tree makes the
> logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> 
>
> ...
>
> --- a/include/linux/dax.h
> +++ b/include/linux/dax.h
> @@ -36,4 +36,9 @@ static inline bool vma_is_dax(struct vm_area_struct *vma)
>  {
>  	return vma->vm_file && IS_DAX(vma->vm_file->f_mapping->host);
>  }
> +
> +static inline bool dax_mapping(struct address_space *mapping)
> +{
> +	return mapping->host && IS_DAX(mapping->host);
> +}

Can we make this evaluate to plain old "0" when CONFIG_FS_DAX=n?  That
way a bunch of code in callers will fall away as well.

If the compiler has any brains then a good way to do this would be to
make IS_DAX be "0" but one would need to check that the zeroness
properly propagated out of the inline.

>  #endif
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3aa5142..b9ac534 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -433,6 +433,7 @@ struct address_space {
>  	/* Protected by tree_lock together with the radix tree */
>  	unsigned long		nrpages;	/* number of total pages */
>  	unsigned long		nrshadows;	/* number of shadow entries */
> +	unsigned long		nrdax;	        /* number of DAX entries */

hm, that's unfortunate - machines commonly carry tremendous numbers of
address_spaces in memory and adding pork to them is rather a big deal. 
We can't avoid this somehow?  Maybe share the space with nrshadows by
some means?  Find some other field which is unused for dax files?

> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -11,6 +11,7 @@
>   */
>  #include <linux/export.h>
>  #include <linux/compiler.h>
> +#include <linux/dax.h>
>  #include <linux/fs.h>
>  #include <linux/uaccess.h>
>  #include <linux/capability.h>
> @@ -579,6 +580,12 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
>  		if (!radix_tree_exceptional_entry(p))
>  			return -EEXIST;
> +
> +		if (dax_mapping(mapping)) {
> +			WARN_ON(1);
> +			return -EINVAL;
> +		}

this:

--- a/mm/filemap.c~dax-support-dirty-dax-entries-in-radix-tree-fix
+++ a/mm/filemap.c
@@ -581,10 +581,8 @@ static int page_cache_tree_insert(struct
 		if (!radix_tree_exceptional_entry(p))
 			return -EEXIST;
 
-		if (dax_mapping(mapping)) {
-			WARN_ON(1);
+		if (WARN_ON(dax_mapping(mapping)))
 			return -EINVAL;
-		}
 
 		if (shadowp)
 			*shadowp = p;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
