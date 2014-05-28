Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 129566B0035
	for <linux-mm@kvack.org>; Wed, 28 May 2014 19:09:51 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so11905793pbb.22
        for <linux-mm@kvack.org>; Wed, 28 May 2014 16:09:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id po7si25490523pbb.66.2014.05.28.16.09.49
        for <linux-mm@kvack.org>;
        Wed, 28 May 2014 16:09:50 -0700 (PDT)
Date: Wed, 28 May 2014 16:09:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: dont call mmu_notifier_invalidate_page during
 munlock
Message-Id: <20140528160948.489fde6e0285885d13f7c656@linux-foundation.org>
In-Reply-To: <20140528075955.20300.22758.stgit@zurg>
References: <20140528075955.20300.22758.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 28 May 2014 11:59:55 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:

> try_to_munlock() searches other mlocked vmas, it never unmaps pages.
> There is no reason for invalidation because ptes are left unchanged.
> 
> ...
>
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1225,7 +1225,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  
>  out_unmap:
>  	pte_unmap_unlock(pte, ptl);
> -	if (ret != SWAP_FAIL)
> +	if (ret != SWAP_FAIL && TTU_ACTION(flags) != TTU_MUNLOCK)
>  		mmu_notifier_invalidate_page(mm, address);
>  out:
>  	return ret;

The patch itself looks reasonable but there is no such thing as
try_to_munlock().  I rewrote the changelog thusly:

: In its munmap mode, try_to_unmap_one() searches other mlocked vmas, it
: never unmaps pages.  There is no reason for invalidation because ptes are
: left unchanged.

Also, the name try_to_unmap_one() is now pretty inaccurate/incomplete. 
Perhaps if someone is feeling enthusiastic they might think up a better
name for the various try_to_unmap functions and see if we can
appropriately document try_to_unmap_one().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
