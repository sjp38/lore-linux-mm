Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 643696B0038
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 14:42:53 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id kc8so121688606pab.2
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 11:42:53 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s21si16064693pgg.25.2016.10.14.11.42.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Oct 2016 11:42:52 -0700 (PDT)
Date: Fri, 14 Oct 2016 12:42:51 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 03/20] mm: Use pgoff in struct vm_fault instead of
 passing it separately
Message-ID: <20161014184251.GB27575@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <1474992504-20133-4-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1474992504-20133-4-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Sep 27, 2016 at 06:08:07PM +0200, Jan Kara wrote:
> struct vm_fault has already pgoff entry. Use it instead of passing pgoff
> as a separate argument and then assigning it later.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  mm/memory.c | 35 ++++++++++++++++++-----------------
>  1 file changed, 18 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 447a1ef4a9e3..4c2ec9a9d8af 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2275,7 +2275,7 @@ static int wp_pfn_shared(struct vm_fault *vmf, pte_t orig_pte)
>  	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
>  		struct vm_fault vmf2 = {
>  			.page = NULL,
> -			.pgoff = linear_page_index(vma, vmf->address),
> +			.pgoff = vmf->pgoff,

I think there is one path where vmf->pgoff isn't set here.  Here's the path:

__collapse_huge_page_swapin()
  do_swap_page()
    do_wp_page()
      wp_pfn_shared()

We then use an uninitialized vmf->pgoff to set up vmf2->pgoff, which we pass
to vm_ops->pfn_mkwrite().

I think all we need to do to fix this is initialize .pgoff in
__collapse_huge_page_swapin().  With this one change:

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
