Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 090606B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 18:08:53 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r16so209401707pfg.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 15:08:53 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 7si26772013pfx.1.2016.10.17.15.08.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 15:08:52 -0700 (PDT)
Date: Mon, 17 Oct 2016 16:08:51 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 12/20] mm: Factor out common parts of write fault handling
Message-ID: <20161017220851.GA26960@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-13-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-13-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:16PM +0200, Jan Kara wrote:
> Currently we duplicate handling of shared write faults in
> wp_page_reuse() and do_shared_fault(). Factor them out into a common
> function.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/memory.c | 78 +++++++++++++++++++++++++++++--------------------------------
>  1 file changed, 37 insertions(+), 41 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 63d9c1a54caf..0643b3b5a12a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2063,6 +2063,41 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
>  }
>  
>  /*
> + * Handle dirtying of a page in shared file mapping on a write fault.
> + *
> + * The function expects the page to be locked and unlocks it.
> + */
> +static void fault_dirty_shared_page(struct vm_area_struct *vma,
> +				    struct page *page)
> +{
> +	struct address_space *mapping;
> +	bool dirtied;
> +	bool page_mkwrite = vma->vm_ops->page_mkwrite;

I think you may need to pass in a 'page_mkwrite' parameter if you don't want
to change behavior.  Just checking to see of vma->vm_ops->page_mkwrite is
non-NULL works fine for this path:

do_shared_fault()
	fault_dirty_shared_page()

and for

wp_page_shared()
	wp_page_reuse()
		fault_dirty_shared_page()

But for these paths:

wp_pfn_shared()
	wp_page_reuse()
		fault_dirty_shared_page()

and

do_wp_page()
	wp_page_reuse()
		fault_dirty_shared_page()

we unconditionally pass 0 for the 'page_mkwrite' parameter, even though from
the logic in wp_pfn_shared() especially you can see that
vma->vm_ops->pfn_mkwrite() must be defined some of the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
