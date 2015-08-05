Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 08D8C6B0254
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 07:43:13 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so204663583wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 04:43:12 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id fz2si28336091wic.3.2015.08.05.04.43.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 04:43:11 -0700 (PDT)
Received: by wibxm9 with SMTP id xm9so204662505wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 04:43:10 -0700 (PDT)
Date: Wed, 5 Aug 2015 14:43:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 06/11] dax: Fix race between simultaneous faults
Message-ID: <20150805114309.GA25784@node.dhcp.inet.fi>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
 <1438718285-21168-7-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438718285-21168-7-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

On Tue, Aug 04, 2015 at 03:58:00PM -0400, Matthew Wilcox wrote:
> diff --git a/mm/memory.c b/mm/memory.c
> index b94b587..5f46350 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2426,11 +2426,16 @@ void unmap_mapping_range(struct address_space *mapping,
>  		details.last_index = ULONG_MAX;
>  
>  
> -	/* DAX uses i_mmap_lock to serialise file truncate vs page fault */
> -	i_mmap_lock_write(mapping);
> +	/*
> +	 * DAX already holds i_mmap_lock to serialise file truncate vs
> +	 * page fault and page fault vs page fault.
> +	 */
> +	if (!IS_DAX(mapping->host))
> +		i_mmap_lock_write(mapping);
>  	if (unlikely(!RB_EMPTY_ROOT(&mapping->i_mmap)))
>  		unmap_mapping_range_tree(&mapping->i_mmap, &details);
> -	i_mmap_unlock_write(mapping);
> +	if (!IS_DAX(mapping->host))
> +		i_mmap_unlock_write(mapping);
>  }
>  EXPORT_SYMBOL(unmap_mapping_range);

Huh? What protects mapping->i_mmap here? I don't see anything up by stack
taking the lock.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
