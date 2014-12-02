Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1A52F6B0071
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 04:19:42 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so16416925wgh.25
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 01:19:41 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id er1si34065511wjd.152.2014.12.02.01.19.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 01:19:41 -0800 (PST)
Date: Tue, 2 Dec 2014 10:19:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 3/3] mm: memory: merge shared-writable dirtying branches
 in do_wp_page()
Message-ID: <20141202091939.GC9092@quack.suse.cz>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 01-12-14 17:58:02, Johannes Weiner wrote:
> Whether there is a vm_ops->page_mkwrite or not, the page dirtying is
> pretty much the same.  Make sure the page references are the same in
> both cases, then merge the two branches.
> 
> It's tempting to go even further and page-lock the !page_mkwrite case,
> to get it in line with everybody else setting the page table and thus
> further simplify the model.  But that's not quite compelling enough to
> justify dropping the pte lock, then relocking and verifying the entry
> for filesystems without ->page_mkwrite, which notably includes tmpfs.
> Leave it for now and lock the page late in the !page_mkwrite case.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memory.c | 46 ++++++++++++++++------------------------------
>  1 file changed, 16 insertions(+), 30 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2a2e3648ed65..ff92abfa5303 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
...
> @@ -2147,42 +2147,28 @@ reuse:
>  		pte_unmap_unlock(page_table, ptl);
>  		ret |= VM_FAULT_WRITE;
>  
> -		if (!dirty_page)
> -			return ret;
> -
> -		if (!page_mkwrite) {
> +		if (dirty_shared) {
>  			struct address_space *mapping;
>  			int dirtied;
>  
> -			lock_page(dirty_page);
> -			dirtied = set_page_dirty(dirty_page);
> -			mapping = dirty_page->mapping;
> -			unlock_page(dirty_page);
> +			if (!page_mkwrite)
> +				lock_page(old_page);
>  
> -			if (dirtied && mapping) {
> -				/*
> -				 * Some device drivers do not set page.mapping
> -				 * but still dirty their pages
> -				 */
> -				balance_dirty_pages_ratelimited(mapping);
> -			}
> +			dirtied = set_page_dirty(old_page);
> +			mapping = old_page->mapping;
> +			unlock_page(old_page);
> +			page_cache_release(old_page);
>  
> -			file_update_time(vma->vm_file);
> -		}
> -		put_page(dirty_page);
> -		if (page_mkwrite) {
> -			struct address_space *mapping = dirty_page->mapping;
> -
> -			set_page_dirty(dirty_page);
> -			unlock_page(dirty_page);
> -			page_cache_release(dirty_page);
> -			if (mapping)	{
> +			if ((dirtied || page_mkwrite) && mapping) {
  Why do we actually call balance_dirty_pages_ratelimited() even if we
didn't dirty the page when ->page_mkwrite() exists? Is it because
filesystem may dirty the page in ->page_mkwrite() and we don't want it to
deal with calling balance_dirty_pages_ratelimited()?

Otherwise the patch looks good to me.

								Honza

>  				/*
>  				 * Some device drivers do not set page.mapping
>  				 * but still dirty their pages
>  				 */
>  				balance_dirty_pages_ratelimited(mapping);
>  			}
> +
> +			if (!page_mkwrite)
> +				file_update_time(vma->vm_file);
>  		}
>  
>  		return ret;
> -- 
> 2.1.3
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
