Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9917B6B0039
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 18:02:50 -0400 (EDT)
Date: Wed, 20 Mar 2013 15:02:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH} mm: Merging memory blocks resets mempolicy
Message-Id: <20130320150248.116db8557253509972bcceda@linux-foundation.org>
In-Reply-To: <CD6BFEA8.10FFB%steven.t.hampson@intel.com>
References: <CD6BFEA8.10FFB%steven.t.hampson@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hampson, Steven T" <steven.t.hampson@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, 18 Mar 2013 06:13:42 +0000 "Hampson, Steven T" <steven.t.hampson@intel.com> wrote:

> Using mbind to change the mempolicy to MPOL_BIND on several adjacent
> mmapped blocks
> may result in a reset of the mempolicy to MPOL_DEFAULT in vma_adjust.
> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -820,7 +820,7 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		if (next->anon_vma)
>  			anon_vma_merge(vma, next);
>  		mm->map_count--;
> -		mpol_put(vma_policy(next));
> +		vma_set_policy(vma, vma_policy(next));
>  		kmem_cache_free(vm_area_cachep, next);
>  		/*
>  		 * In mprotect's case 6 (see comments on vma_merge),

Is this missing an mpol_put(vma_policy(vma))?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
