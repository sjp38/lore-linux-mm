Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 439196B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 16:47:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so350956768pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 13:47:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m89si16227558pfk.254.2016.07.25.13.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 13:47:33 -0700 (PDT)
Date: Mon, 25 Jul 2016 13:47:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Move readahead limit outside of readahead, and
 advisory syscalls
Message-Id: <20160725134732.b21912c54ef1ffe820ccdbca@linux-foundation.org>
In-Reply-To: <1469457565-22693-1-git-send-email-kwalker@redhat.com>
References: <1469457565-22693-1-git-send-email-kwalker@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Geliang Tang <geliangtang@163.com>, Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <klamm@yandex-team.ru>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 25 Jul 2016 10:39:25 -0400 Kyle Walker <kwalker@redhat.com> wrote:

> Java workloads using the MappedByteBuffer library result in the fadvise()
> and madvise() syscalls being used extensively. Following recent readahead
> limiting alterations, such as 600e19af ("mm: use only per-device readahead
> limit") and 6d2be915 ("mm/readahead.c: fix readahead failure for
> memoryless NUMA nodes and limit readahead pages"), application performance
> suffers in instances where small readahead is configured.

Can this suffering be quantified please?

> By moving this limit outside of the syscall codepaths, the syscalls are
> able to advise an inordinately large amount of readahead when desired.
> With a cap being imposed based on the half of NR_INACTIVE_FILE and
> NR_FREE_PAGES. In essence, allowing performance tuning efforts to define a
> small readahead limit, but then benefiting from large sequential readahead
> values selectively.
> 
> ...
>
> --- a/mm/readahead.c
> +++ b/mm/readahead.c
> @@ -211,7 +211,9 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
>  	if (unlikely(!mapping->a_ops->readpage && !mapping->a_ops->readpages))
>  		return -EINVAL;
>  
> -	nr_to_read = min(nr_to_read, inode_to_bdi(mapping->host)->ra_pages);
> +	nr_to_read = min(nr_to_read, (global_page_state(NR_INACTIVE_FILE) +
> +				     (global_page_state(NR_FREE_PAGES)) / 2));
> +
>  	while (nr_to_read) {
>  		int err;
>  
> @@ -484,6 +486,7 @@ void page_cache_sync_readahead(struct address_space *mapping,
>  
>  	/* be dumb */
>  	if (filp && (filp->f_mode & FMODE_RANDOM)) {
> +		req_size = min(req_size, inode_to_bdi(mapping->host)->ra_pages);
>  		force_page_cache_readahead(mapping, filp, offset, req_size);
>  		return;
>  	}

Linus probably has opinions ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
