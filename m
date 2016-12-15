Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5DB76B0069
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 09:04:40 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so23411378wjc.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 06:04:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rb6si2145664wjb.250.2016.12.15.06.04.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 06:04:39 -0800 (PST)
Date: Thu, 15 Dec 2016 15:04:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 3/3] mm, dax: move pmd_fault() to take only vmf
 parameter
Message-ID: <20161215140434.GC13811@quack2.suse.cz>
References: <148174532372.194339.4875475197715168429.stgit@djiang5-desk3.ch.intel.com>
 <148174533516.194339.9865528020619155270.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148174533516.194339.9865528020619155270.stgit@djiang5-desk3.ch.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, linux-nvdimm@lists.01.org, david@fromorbit.com, hch@lst.de, linux-mm@kvack.org, tytso@mit.edu, ross.zwisler@linux.intel.com, dan.j.williams@intel.com

On Wed 14-12-16 12:55:35, Dave Jiang wrote:
> pmd_fault() and relate functions really only need the vmf parameter since
> the additional parameters are all included in the vmf struct. Removing
> additional parameter and simplify pmd_fault() and friends.
> 
> Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
...
> diff --git a/fs/dax.c b/fs/dax.c
> index 157f77f..66c8f2e 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1226,9 +1226,9 @@ EXPORT_SYMBOL_GPL(dax_iomap_fault);
>   */
>  #define PG_PMD_COLOUR	((PMD_SIZE >> PAGE_SHIFT) - 1)
>  
> -static int dax_pmd_insert_mapping(struct vm_area_struct *vma, pmd_t *pmd,
> -		struct vm_fault *vmf, unsigned long address,
> -		struct iomap *iomap, loff_t pos, bool write, void **entryp)
> +static int dax_pmd_insert_mapping(struct vm_area_struct *vma,
> +		struct vm_fault *vmf, struct iomap *iomap, loff_t pos,
> +		bool write, void **entryp)

Any reason for keeping 'vma' and 'write' arguments? They can be fetched
from vmf as well...

> -static int dax_pmd_load_hole(struct vm_area_struct *vma, pmd_t *pmd,
> -		struct vm_fault *vmf, unsigned long address,
> +static int dax_pmd_load_hole(struct vm_area_struct *vma, struct vm_fault *vmf,
>  		struct iomap *iomap, void **entryp)

Ditto with vma here.

Otherwise the patch looks good to me.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
