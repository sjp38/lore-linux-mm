Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8660A6B00DB
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:13:31 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bs8so6368098wib.17
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:13:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dn3si29504809wib.68.2014.11.12.14.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 14:13:30 -0800 (PST)
Message-ID: <5463DAD8.3050601@redhat.com>
Date: Wed, 12 Nov 2014 17:10:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC v6 2/2] mm: swapoff prototype: frontswap handling added
References: <20141112025823.GA7464@kelleynnn-virtual-machine>
In-Reply-To: <20141112025823.GA7464@kelleynnn-virtual-machine>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>, linux-mm@kvack.org, riel@surriel.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On 11/11/2014 09:58 PM, Kelley Nielsen wrote:
> The prototype of the new swapoff (without the quadratic complexity)
> presently ignores the frontswap case. Pass the count of
> pages_to_unuse down the page table walks in try_to_unuse(),
> and return from the walk when the desired number of pages
> has been swapped back in.
> 
> Signed-off-by: Kelley Nielsen <kelleynnn@gmail.com>
> ---
>  mm/shmem.c    |  1 +
>  mm/swapfile.c | 53 +++++++++++++++++++++++++++++++++++++----------------
>  2 files changed, 38 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 2a7179c..e7a813f 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -629,6 +629,7 @@ static int shmem_unuse_inode(struct inode *inode, unsigned int type)
>  	int entries = 0;
>  	swp_entry_t entry;
>  	unsigned int stype;
> +
>  	pgoff_t start = 0;

Why is there an shmem.c blank line in the frontswap patch?

> @@ -1210,6 +1212,15 @@ static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		SetPageDirty(page);
>  		unlock_page(page);
>  		page_cache_release(page);
> +		if (ret && pages_to_unuse > 0) {
> +			pages_to_unuse--;
> +			/*
> +			 * we've unused all we need for frontswap,
> +			 * so return special code to indicate this.
> +			 */
> +			if (pages_to_unuse == 0)
> +				return 2;
> +		}

If you are using a magic value, could you make it a #define so
people can more easily find out why the code is testing for == 2
elsewhere?

One obvious bug is that the pages_to_unuse variable is passed by
value, so try_to_unuse never sees that unuse_pte_range decremented
the counter. You will want to use a pointer instead.

A second issue is that you decrement pages_to_unuse on every pte
unmap, and not on every swap slot that is unused. Would it make
more sense to decrement pages_to_unuse where you call
delete_from_swap_cache?

Other than that, this series looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
