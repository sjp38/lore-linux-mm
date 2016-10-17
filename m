Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1049D6B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:40:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id i85so202366020pfa.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:40:44 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x74si843686pfa.171.2016.10.17.10.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 10:40:42 -0700 (PDT)
Date: Mon, 17 Oct 2016 11:40:42 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 09/20] mm: Factor out functionality to finish page faults
Message-ID: <20161017174042.GB6104@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-10-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-10-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:13PM +0200, Jan Kara wrote:
> Introduce function finish_fault() as a helper function for finishing
> page faults. It is rather thin wrapper around alloc_set_pte() but since
> we'd want to call this from DAX code or filesystems, it is still useful
> to avoid some boilerplate code.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---

> diff --git a/mm/memory.c b/mm/memory.c
> index 17db88a38e8a..f54cfad7fe04 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3029,6 +3029,36 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
>  	return 0;
>  }
>  
> +
> +/**
> + * finish_fault - finish page fault once we have prepared the page to fault
> + *
> + * @vmf: structure describing the fault
> + *
> + * This function handles all that is needed to finish a page fault once the
> + * page to fault in is prepared. It handles locking of PTEs, inserts PTE for
> + * given page, adds reverse page mapping, handles memcg charges and LRU
> + * addition. The function returns 0 on success, VM_FAULT_ code in case of
> + * error.
> + *
> + * The function expects the page to be locked.
> + */
> +int finish_fault(struct vm_fault *vmf)
> +{
> +	struct page *page;
> +	int ret;
> +
> +	/* Did we COW the page? */
> +	if (vmf->flags & FAULT_FLAG_WRITE && !(vmf->vma->vm_flags & VM_SHARED))

Oh, sorry, I did have one bit of feedback.  Maybe added parens around the flag
check for readability:

	if ((vmf->flags & FAULT_FLAG_WRITE) && !(vmf->vma->vm_flags & VM_SHARED))

Aside from that one nit:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
