Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id B63236B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 15:29:51 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gg9so211720722pac.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:29:51 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a13si26719341pag.258.2016.10.17.12.29.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 12:29:50 -0700 (PDT)
Date: Mon, 17 Oct 2016 13:29:49 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 10/20] mm: Move handling of COW faults into DAX code
Message-ID: <20161017192949.GA21002@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-11-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-11-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:14PM +0200, Jan Kara wrote:
> Move final handling of COW faults from generic code into DAX fault
> handler. That way generic code doesn't have to be aware of peculiarities
> of DAX locking so remove that knowledge.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/dax.c            | 22 ++++++++++++++++------
>  include/linux/dax.h |  7 -------
>  include/linux/mm.h  |  9 +--------
>  mm/memory.c         | 14 ++++----------
>  4 files changed, 21 insertions(+), 31 deletions(-)
> 
> diff --git a/fs/dax.c b/fs/dax.c
> index 0dc251ca77b8..b1c503930d1d 100644
> --- a/fs/dax.c
> +++ b/fs/dax.c
> @@ -876,10 +876,15 @@ int dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			goto unlock_entry;
>  		if (!radix_tree_exceptional_entry(entry)) {
>  			vmf->page = entry;
> -			return VM_FAULT_LOCKED;
> +			if (unlikely(PageHWPoison(entry))) {
> +				put_locked_mapping_entry(mapping, vmf->pgoff,
> +							 entry);
> +				return VM_FAULT_HWPOISON;
> +			}
>  		}
> -		vmf->entry = entry;
> -		return VM_FAULT_DAX_LOCKED;
> +		error = finish_fault(vmf);
> +		put_locked_mapping_entry(mapping, vmf->pgoff, entry);
> +		return error ? error : VM_FAULT_DONE_COW;
>  	}
>  
>  	if (!buffer_mapped(&bh)) {
> @@ -1430,10 +1435,15 @@ int iomap_dax_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  			goto unlock_entry;
>  		if (!radix_tree_exceptional_entry(entry)) {
>  			vmf->page = entry;

In __do_fault() we explicitly clear vmf->page in the case where PageHWPoison()
is set.  I think we can get the same behavior here by moving the call that
sets vmf->page after the PageHWPoison() check.

> -			return VM_FAULT_LOCKED;
> +			if (unlikely(PageHWPoison(entry))) {
> +				put_locked_mapping_entry(mapping, vmf->pgoff,
> +							 entry);
> +				return VM_FAULT_HWPOISON;
> +			}
>  		}
> -		vmf->entry = entry;
> -		return VM_FAULT_DAX_LOCKED;

I think we're missing a call to 

	__SetPageUptodate(new_page);

before finish_fault()?  This call currently lives in do_cow_fault(), and
is part of the path that we don't skip as part of the VM_FAULT_DAX_LOCKED
logic.

Both of these comments apply equally to the iomap_dax_fault() code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
