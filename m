Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B33F36B0253
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 15:40:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so206061318pfg.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:40:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id gt2si26787962pac.80.2016.10.17.12.40.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 12:40:42 -0700 (PDT)
Date: Mon, 17 Oct 2016 13:40:41 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 11/20] mm: Remove unnecessary vma->vm_ops check
Message-ID: <20161017194041.GB21002@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-12-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-12-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:15PM +0200, Jan Kara wrote:
> We don't check whether vma->vm_ops is NULL in do_shared_fault() so
> there's hardly any point in checking it in wp_page_shared() which gets
> called only for shared file mappings as well.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index a4522e8999b2..63d9c1a54caf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2301,7 +2301,7 @@ static int wp_page_shared(struct vm_fault *vmf, struct page *old_page)
>  
>  	get_page(old_page);
>  
> -	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
> +	if (vma->vm_ops->page_mkwrite) {
>  		int tmp;
>  
>  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> -- 
> 2.6.6

Does this apply equally to the check in wp_pfn_shared()?  Both
wp_page_shared() and wp_pfn_shared() are called for shared file mappings via
do_wp_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
