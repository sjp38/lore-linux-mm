Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED7206B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:25:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v82so27243294pgb.5
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:25:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si9286402pfl.547.2017.09.13.04.25.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 04:25:18 -0700 (PDT)
Date: Wed, 13 Sep 2017 13:25:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] ksm: Fix unlocked iteration over vmas in
 cmp_and_merge_page()
Message-ID: <20170913112509.mus2fuccajoe2l25@dhcp22.suse.cz>
References: <150512788393.10691.8868381099691121308.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150512788393.10691.8868381099691121308.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, minchan@kernel.org, zhongjiang@huawei.com, mingo@kernel.org, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

[CC Claudio and Hugh]

On Mon 11-09-17 14:05:05, Kirill Tkhai wrote:
> In this place mm is unlocked, so vmas or list may change.
> Down read mmap_sem to protect them from modifications.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> (and compile-tested-by)

Fixes: e86c59b1b12d ("mm/ksm: improve deduplication of zero pages with colouring")
AFAICS. Maybe even CC: stable as unstable vma can cause large variety of
issues including memory corruption.

The fix lookds good to me
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/ksm.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index db20f8436bc3..86f0db3d6cdb 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1990,6 +1990,7 @@ static void stable_tree_append(struct rmap_item *rmap_item,
>   */
>  static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  {
> +	struct mm_struct *mm = rmap_item->mm;
>  	struct rmap_item *tree_rmap_item;
>  	struct page *tree_page = NULL;
>  	struct stable_node *stable_node;
> @@ -2062,9 +2063,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	if (ksm_use_zero_pages && (checksum == zero_checksum)) {
>  		struct vm_area_struct *vma;
>  
> -		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
> +		down_read(&mm->mmap_sem);
> +		vma = find_mergeable_vma(mm, rmap_item->address);
>  		err = try_to_merge_one_page(vma, page,
>  					    ZERO_PAGE(rmap_item->address));
> +		up_read(&mm->mmap_sem);
>  		/*
>  		 * In case of failure, the page was not really empty, so we
>  		 * need to continue. Otherwise we're done.
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
