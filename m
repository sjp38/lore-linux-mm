Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id D381E6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 17:26:00 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so54468152pdb.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 14:26:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ee5si38397921pac.139.2015.03.18.14.25.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 14:25:59 -0700 (PDT)
Date: Wed, 18 Mar 2015 14:25:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 1/4] hugetlbfs: add minimum size tracking fields to
 subpool structure
Message-Id: <20150318142558.d2958fbb7f8b083c00c40c0d@linux-foundation.org>
In-Reply-To: <1ef964ec5febb254dbee28604481c6768e018268.1426549010.git.mike.kravetz@oracle.com>
References: <cover.1426549010.git.mike.kravetz@oracle.com>
	<1ef964ec5febb254dbee28604481c6768e018268.1426549010.git.mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 16 Mar 2015 16:53:26 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Add a field to the subpool structure to indicate the minimimum
> number of huge pages to always be used by this subpool.  This
> minimum count includes allocated pages as well as reserved pages.
> If the minimum number of pages for the subpool have not been
> allocated, pages are reserved up to this minimum.  An additional
> field (rsv_hpages) is used to track the number of pages reserved
> to meet this minimum size.  The hstate pointer in the subpool
> is convenient to have when reserving and unreserving the pages.
> 
> ...
>
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -23,6 +23,8 @@ struct hugepage_subpool {
>  	spinlock_t lock;
>  	long count;
>  	long max_hpages, used_hpages;
> +	struct hstate *hstate;
> +	long min_hpages, rsv_hpages;
>  };

Let's leave room for the descriptive comments which aren't there.

--- a/include/linux/hugetlb.h~hugetlbfs-add-minimum-size-tracking-fields-to-subpool-structure-fix
+++ a/include/linux/hugetlb.h
@@ -22,9 +22,11 @@ struct mmu_gather;
 struct hugepage_subpool {
 	spinlock_t lock;
 	long count;
-	long max_hpages, used_hpages;
+	long max_hpagesl
+	long used_hpages;
 	struct hstate *hstate;
-	long min_hpages, rsv_hpages;
+	long min_hpages;
+	long rsv_hpages;
 };
 
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -85,6 +85,9 @@ struct hugepage_subpool *hugepage_new_subpool(long nr_blocks)
>  	spool->count = 1;
>  	spool->max_hpages = nr_blocks;
>  	spool->used_hpages = 0;
> +	spool->hstate = NULL;
> +	spool->min_hpages = 0;
> +	spool->rsv_hpages = 0;

Four strikes and you're out!

--- a/mm/hugetlb.c~hugetlbfs-add-minimum-size-tracking-fields-to-subpool-structure-fix
+++ a/mm/hugetlb.c
@@ -77,17 +77,13 @@ struct hugepage_subpool *hugepage_new_su
 {
 	struct hugepage_subpool *spool;
 
-	spool = kmalloc(sizeof(*spool), GFP_KERNEL);
+	spool = kzalloc(sizeof(*spool), GFP_KERNEL);
 	if (!spool)
 		return NULL;
 
 	spin_lock_init(&spool->lock);
 	spool->count = 1;
 	spool->max_hpages = nr_blocks;
-	spool->used_hpages = 0;
-	spool->hstate = NULL;
-	spool->min_hpages = 0;
-	spool->rsv_hpages = 0;
 
 	return spool;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
