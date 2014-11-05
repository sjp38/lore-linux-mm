Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A5A7B6B0080
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 11:04:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kx10so1032682pab.34
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:04:21 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id cy1si3260929pdb.248.2014.11.05.08.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 08:04:19 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id y13so993287pdi.34
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 08:04:18 -0800 (PST)
Date: Wed, 5 Nov 2014 08:04:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 10/10] mm/hugetlb: share the i_mmap_rwsem
In-Reply-To: <1415149183.6673.12.camel@linux-t7sj.site>
Message-ID: <alpine.LSU.2.11.1411050757170.4224@eggly.anvils>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net> <1414697657-1678-11-git-send-email-dave@stgolabs.net> <alpine.LSU.2.11.1411032208390.15596@eggly.anvils> <1415149183.6673.12.camel@linux-t7sj.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 4 Nov 2014, Davidlohr Bueso wrote:
> 8<------------------------------------------------
> From: Davidlohr Bueso <dave@stgolabs.net>
> Subject: [PATCH 11/10] mm/memory.c: share the i_mmap_rwsem
> 
> The unmap_mapping_range family of functions do the unmapping
> of user pages (ultimately via zap_page_range_single) without
> touching the actual interval tree, thus share the lock.
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>

Acked-by: Hugh Dickins <hughd@google.com>

Yes, thanks, let's get this 11/10 into mmotm along with the rest,
but put the hugetlb 10/10 on the shelf for now, until we've had
time to contemplate it more deeply.

> ---
>  mm/memory.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2ca3105..06f2458 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2396,12 +2396,12 @@ void unmap_mapping_range(struct address_space *mapping,
>  		details.last_index = ULONG_MAX;
>  
>  
> -	i_mmap_lock_write(mapping);
> +	i_mmap_lock_read(mapping);
>  	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>  		unmap_mapping_range_tree(&mapping->i_mmap, &details);
>  	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear)))
>  		unmap_mapping_range_list(&mapping->i_mmap_nonlinear, &details);
> -	i_mmap_unlock_write(mapping);
> +	i_mmap_unlock_read(mapping);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);
>  
> -- 
> 1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
