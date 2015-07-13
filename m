Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 284796B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 09:08:44 -0400 (EDT)
Received: by widic2 with SMTP id ic2so11899530wid.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 06:08:43 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k4si28472404wjn.135.2015.07.13.06.08.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 06:08:42 -0700 (PDT)
Date: Mon, 13 Jul 2015 09:08:12 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm, memcontrol: use vma_is_anonymous() to check for
 anon VMA
Message-ID: <20150713130812.GA8115@cmpxchg.org>
References: <1436784852-144369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436784852-144369-6-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436784852-144369-6-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

On Mon, Jul 13, 2015 at 01:54:12PM +0300, Kirill A. Shutemov wrote:
> !vma->vm_file is not reliable to detect anon VMA, because not all
> drivers bother set it. Let's use vma_is_anonymous() instead.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index acb93c554f6e..a624709f0dd7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4809,7 +4809,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  	struct address_space *mapping;
>  	pgoff_t pgoff;
>  
> -	if (!vma->vm_file) /* anonymous vma */
> +	if (vma_is_anonymous(vma)) /* anonymous vma */
>  		return NULL;
>  	if (!(mc.flags & MOVE_FILE))
>  		return NULL;

The next line does vma->vm_file->f_mapping, so it had better be !NULL.

It's not about reliably detecting anonymous vs. file, it is about
whether there is a mapping against which we can do find_get_page().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
