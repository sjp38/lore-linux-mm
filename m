Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 610146B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:35:27 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so831418pab.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:35:27 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y20si36846657pfd.167.2016.10.18.11.35.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 11:35:26 -0700 (PDT)
Date: Tue, 18 Oct 2016 12:35:25 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 16/20] mm: Provide helper for finishing mkwrite faults
Message-ID: <20161018183525.GC7796@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-17-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-17-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:20PM +0200, Jan Kara wrote:
> Provide a helper function for finishing write faults due to PTE being
> read-only. The helper will be used by DAX to avoid the need of
> complicating generic MM code with DAX locking specifics.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  include/linux/mm.h |  1 +
>  mm/memory.c        | 65 +++++++++++++++++++++++++++++++-----------------------
>  2 files changed, 39 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1055f2ece80d..e5a014be8932 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -617,6 +617,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
>  int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  		struct page *page);
>  int finish_fault(struct vm_fault *vmf);
> +int finish_mkwrite_fault(struct vm_fault *vmf);
>  #endif
>  
>  /*
> diff --git a/mm/memory.c b/mm/memory.c
> index f49e736d6a36..8c8cb7f2133e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2266,6 +2266,36 @@ oom:
>  	return VM_FAULT_OOM;
>  }
>  
> +/**
> + * finish_mkrite_fault - finish page fault making PTE writeable once the page
      finish_mkwrite_fault

> @@ -2315,26 +2335,17 @@ static int wp_page_shared(struct vm_fault *vmf)
>  			put_page(vmf->page);
>  			return tmp;
>  		}
> -		/*
> -		 * Since we dropped the lock we need to revalidate
> -		 * the PTE as someone else may have changed it.  If
> -		 * they did, we just return, as we can count on the
> -		 * MMU to tell us if they didn't also make it writable.
> -		 */
> -		vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd,
> -						vmf->address, &vmf->ptl);
> -		if (!pte_same(*vmf->pte, vmf->orig_pte)) {
> +		tmp = finish_mkwrite_fault(vmf);
> +		if (unlikely(!tmp || (tmp &
> +				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {

The 'tmp' return from finish_mkwrite_fault() can only be 0 or VM_FAULT_WRITE.
I think this test should just be 

		if (unlikely(!tmp)) {

With that and the small spelling fix:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
