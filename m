Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 298906B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:57:34 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so5359840wjc.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:57:34 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p127si7265296wmp.101.2016.11.24.01.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 01:57:32 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAO9sOA7018842
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:57:31 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26wt6udh6n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:57:31 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 19:57:28 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BD8E72CE8046
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:57:25 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAO9vPxA4063526
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:57:25 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAO9vPX0024639
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:57:25 +1100
Subject: Re: [PATCH 4/5] mm: migrate: Add copy_page_mt into migrate_pages.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-5-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 15:27:17 +0530
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-5-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <5836B97D.2090903@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/22/2016 09:55 PM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>
> 
> An option is added to move_pages() syscall to use multi-threaded
> page migration.
> 


> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> ---
>  include/linux/migrate_mode.h   |  1 +
>  include/uapi/linux/mempolicy.h |  2 ++
>  mm/migrate.c                   | 27 +++++++++++++++++++--------
>  3 files changed, 22 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index 0e2deb8..c711e2a 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -11,6 +11,7 @@ enum migrate_mode {
>  	MIGRATE_ASYNC		= 1<<0,
>  	MIGRATE_SYNC_LIGHT	= 1<<1,
>  	MIGRATE_SYNC		= 1<<2,
> +	MIGRATE_MT			= 1<<3,

MIGRATE_MTHREAD should be better.

>  };
> 
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
> index 9cd8b21..5d42dc6 100644
> --- a/include/uapi/linux/mempolicy.h
> +++ b/include/uapi/linux/mempolicy.h
> @@ -54,6 +54,8 @@ enum mpol_rebind_step {
>  #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
>  #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
> 
> +#define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine */
> +

s/MPOL_MF_MOVE_MT/MPOL_MF_MOVE_MTHREAD/

>  #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
>  			 MPOL_MF_MOVE     | 	\
>  			 MPOL_MF_MOVE_ALL)
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4a4cf48..244ece6 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -634,6 +634,7 @@ static void copy_huge_page(struct page *dst, struct page *src,
>  {
>  	int i;
>  	int nr_pages;
> +	int rc = -EFAULT;
> 
>  	if (PageHuge(src)) {
>  		/* hugetlbfs page */
> @@ -650,10 +651,14 @@ static void copy_huge_page(struct page *dst, struct page *src,
>  		nr_pages = hpage_nr_pages(src);
>  	}
> 
> -	for (i = 0; i < nr_pages; i++) {
> -		cond_resched();
> -		copy_highpage(dst + i, src + i);
> -	}
> +	if (mode & MIGRATE_MT)
> +		rc = copy_page_mt(dst, src, nr_pages);
> +
> +	if (rc)
> +		for (i = 0; i < nr_pages; i++) {
> +			cond_resched();
> +			copy_highpage(dst + i, src + i);
> +		}
>  }

So this is the case where MIGRATE_MT is mentioned or when it fails.
A small documentation above the code block should be good.

> 
>  /*
> @@ -1461,11 +1466,16 @@ static struct page *new_page_node(struct page *p, unsigned long private,
>   */
>  static int do_move_page_to_node_array(struct mm_struct *mm,
>  				      struct page_to_node *pm,
> -				      int migrate_all)
> +				      int migrate_all,
> +					  int migrate_use_mt)
>  {
>  	int err;
>  	struct page_to_node *pp;
>  	LIST_HEAD(pagelist);
> +	enum migrate_mode mode = MIGRATE_SYNC;
> +
> +	if (migrate_use_mt)
> +		mode |= MIGRATE_MT;
> 
>  	down_read(&mm->mmap_sem);
> 
> @@ -1542,7 +1552,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  	err = 0;
>  	if (!list_empty(&pagelist)) {
>  		err = migrate_pages(&pagelist, new_page_node, NULL,
> -				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
> +				(unsigned long)pm, mode, MR_SYSCALL);
>  		if (err)
>  			putback_movable_pages(&pagelist);
>  	}
> @@ -1619,7 +1629,8 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> 
>  		/* Migrate this chunk */
>  		err = do_move_page_to_node_array(mm, pm,
> -						 flags & MPOL_MF_MOVE_ALL);
> +						 flags & MPOL_MF_MOVE_ALL,
> +						 flags & MPOL_MF_MOVE_MT);
>  		if (err < 0)
>  			goto out_pm;
> 
> @@ -1726,7 +1737,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
>  	nodemask_t task_nodes;
> 
>  	/* Check flags */
> -	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
> +	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
>  		return -EINVAL;

Wondering if do_move_pages_to_node_array() is the only place which
needs to be changed to accommodate this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
