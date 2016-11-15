Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7578B6B02D8
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 17:40:27 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so10102979wmu.1
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:40:27 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id k5si30447140wjo.179.2016.11.15.14.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 14:40:26 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id m203so4876543wma.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 14:40:26 -0800 (PST)
Date: Wed, 16 Nov 2016 01:40:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 13/21] mm: Pass vm_fault structure into do_page_mkwrite()
Message-ID: <20161115224023.GM23021@node>
References: <1478233517-3571-1-git-send-email-jack@suse.cz>
 <1478233517-3571-14-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1478233517-3571-14-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Nov 04, 2016 at 05:25:09AM +0100, Jan Kara wrote:
> We will need more information in the ->page_mkwrite() helper for DAX to
> be able to fully finish faults there. Pass vm_fault structure to
> do_page_mkwrite() and use it there so that information propagates
> properly from upper layers.
> 
> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/memory.c | 19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 4da66c984c2c..c89f99c270bc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2038,20 +2038,14 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
>   *
>   * We do this without the lock held, so that it can sleep if it needs to.
>   */
> -static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
> -	       unsigned long address)
> +static int do_page_mkwrite(struct vm_fault *vmf)
>  {
> -	struct vm_fault vmf;
>  	int ret;
> +	struct page *page = vmf->page;
>  
> -	vmf.address = address;
> -	vmf.pgoff = page->index;
> -	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
> -	vmf.gfp_mask = __get_fault_gfp_mask(vma);
> -	vmf.page = page;
> -	vmf.cow_page = NULL;
> +	vmf->flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;

This can be destructive: we loose rest of the flags here. It's probably
okay in current state of the code, but may be should restore them before
return from do_page_mkwrite()?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
