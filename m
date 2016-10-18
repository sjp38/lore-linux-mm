Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEEA6B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 15:53:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r16so1605521pfg.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 12:53:34 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id di1si31007471pad.270.2016.10.18.12.53.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 12:53:33 -0700 (PDT)
Date: Tue, 18 Oct 2016 13:53:32 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 19/20] dax: Protect PTE modification on WP fault by radix
 tree entry lock
Message-ID: <20161018195332.GF7796@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-20-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-20-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:23PM +0200, Jan Kara wrote:
> Currently PTE gets updated in wp_pfn_shared() after dax_pfn_mkwrite()
> has released corresponding radix tree entry lock. When we want to
> writeprotect PTE on cache flush, we need PTE modification to happen
> under radix tree entry lock to ensure consisten updates of PTE and radix
					consistent

> tree (standard faults use page lock to ensure this consistency). So move
> update of PTE bit into dax_pfn_mkwrite().
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c    | 22 ++++++++++++++++------
>  mm/memory.c |  2 +-
>  2 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index c6cadf8413a3..a2d3781c9f4e 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -1163,17 +1163,27 @@ int dax_pfn_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
>  {
>  	struct file *file = vma->vm_file;
>  	struct address_space *mapping = file->f_mapping;
> -	void *entry;
> +	void *entry, **slot;
>  	pgoff_t index = vmf->pgoff;
>  
>  	spin_lock_irq(&mapping->tree_lock);
> -	entry = get_unlocked_mapping_entry(mapping, index, NULL);
> -	if (!entry || !radix_tree_exceptional_entry(entry))
> -		goto out;
> +	entry = get_unlocked_mapping_entry(mapping, index, &slot);
> +	if (!entry || !radix_tree_exceptional_entry(entry)) {
> +		if (entry)
> +			put_unlocked_mapping_entry(mapping, index, entry);

I don't think you need this call to put_unlocked_mapping_entry().  If we get
in here we know that 'entry' is a page cache page, in which case
put_unlocked_mapping_entry() will just return without doing any work.

With that nit & the spelling error above:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
