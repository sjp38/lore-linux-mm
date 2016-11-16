Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E41F6B0291
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 16:28:23 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so168049619pgq.7
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 13:28:23 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i6si21437192pgp.114.2016.11.16.13.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 13:28:22 -0800 (PST)
Date: Wed, 16 Nov 2016 14:28:20 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 10/21] mm: Move handling of COW faults into DAX code
Message-ID: <20161116212820.GE31337@linux.intel.com>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-11-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-11-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:06AM +0100, Jan Kara wrote:
> Move final handling of COW faults from generic code into DAX fault
> handler. That way generic code doesn't have to be aware of peculiarities
> of DAX locking so remove that knowledge and make locking functions
> private to fs/dax.c.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---

> @@ -1006,13 +1007,14 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  
>  		if (error)
>  			goto finish_iomap;
> -		if (!radix_tree_exceptional_entry(entry)) {
> +
> +		__SetPageUptodate(vmf->cow_page);
> +		if (!radix_tree_exceptional_entry(entry))
>  			vmf->page = entry;

I don't think we need to set vmf->page anymore.  We would clear it to NULL in
a few lines anyway, and the only call in between is finish_fault(), which
only cares about vmf->cow_page().  This allows us to remove the vmf->page =
NULL line a few lines below as well.

> @@ -1051,7 +1053,7 @@ int dax_iomap_fault(struct vm_area_struct *vma, struct vm_fault *vmf,
>  		}
>  	}
>   unlock_entry:
> -	if (!locked_status || error)
> +	if (vmf_ret != VM_FAULT_LOCKED || error)
>  		put_locked_mapping_entry(mapping, vmf->pgoff, entry);

I don't think this is quite right.  For example, for dax_load_hole(), if we
can't get a page we put_locked_mapping_entry() and return VM_FAULT_OOM.
Previously this logic would have skipped the second call to
put_locked_mapping_entry(), but now with the strict check against
VM_FAULT_LOCKED put the entry twice.

Maybe the right thing to do is just fix dax_load_hole() so it never calls
put_locked_mapping_entry(), and leave this check as you have it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
