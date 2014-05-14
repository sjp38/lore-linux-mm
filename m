Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id CC5AE6B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 14:12:21 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id i8so3406408qcq.4
        for <linux-mm@kvack.org>; Wed, 14 May 2014 11:12:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m4si1307096qae.50.2014.05.14.11.12.20
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 11:12:21 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm, hugetlb: use list_for_each_entry in region_xxx
Date: Wed, 14 May 2014 14:12:08 -0400
Message-Id: <5373b205.0429e00a.7447.ffffbab9SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1400051359-19942-1-git-send-email-nasa4836@gmail.com>
References: <1400051359-19942-1-git-send-email-nasa4836@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nasa4836@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, steve.capper@linaro.org, davidlohr@hp.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 14, 2014 at 03:09:19PM +0800, Jianyu Zhan wrote:
> Commit 7b24d8616be3 ("mm, hugetlb: fix race in region tracking") has
> changed to use a per resv_map spinlock to serialize against any
> concurrent write operations to the resv_map, thus we don't need
> list_for_each_entry_safe to interate over file_region's any more.
> Use list_for_each_entry is enough.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/hugetlb.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c82290b..26b1464 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -156,7 +156,7 @@ struct file_region {
>  static long region_add(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head = &resv->regions;
> -	struct file_region *rg, *nrg, *trg;
> +	struct file_region *rg, *nrg;
>  
>  	spin_lock(&resv->lock);
>  	/* Locate the region we are either in or before. */
> @@ -170,7 +170,7 @@ static long region_add(struct resv_map *resv, long f, long t)
>  
>  	/* Check for and consume any regions we now overlap with. */
>  	nrg = rg;
> -	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> +	list_for_each_entry(rg, rg->link.prev, link) {
>  		if (&rg->link == head)
>  			break;
>  		if (rg->from > t)

We can call list_del(&rg->link) and kfree(rg) in this loop, so we need to get
the pointer to next entry before running code inside the loop. *_safe variants
do this job, so changing this is wrong, I think.

> @@ -261,7 +261,7 @@ out_nrg:
>  static long region_truncate(struct resv_map *resv, long end)
>  {
>  	struct list_head *head = &resv->regions;
> -	struct file_region *rg, *trg;
> +	struct file_region *rg;
>  	long chg = 0;
>  
>  	spin_lock(&resv->lock);
> @@ -280,7 +280,7 @@ static long region_truncate(struct resv_map *resv, long end)
>  	}
>  
>  	/* Drop any remaining regions. */
> -	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> +	list_for_each_entry(rg, rg->link.prev, link) {
>  		if (&rg->link == head)
>  			break;
>  		chg += rg->to - rg->from;

ditto.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
