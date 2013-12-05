Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7406B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 08:35:40 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so11203791eae.19
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 05:35:39 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id w6si10838469eeg.237.2013.12.05.05.35.39
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 05:35:39 -0800 (PST)
Date: Thu, 5 Dec 2013 13:35:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/15] mm: thp: give transparent hugepage code a separate
 copy_page
Message-ID: <20131205133536.GH11295@suse.de>
References: <1386060721-3794-1-git-send-email-mgorman@suse.de>
 <1386060721-3794-4-git-send-email-mgorman@suse.de>
 <20131204165918.GA13191@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131204165918.GA13191@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 04, 2013 at 10:59:18AM -0600, Alex Thorlton wrote:
> > -void copy_huge_page(struct page *dst, struct page *src)
> > -{
> > -	int i;
> > -	struct hstate *h = page_hstate(src);
> > -
> > -	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> 
> With CONFIG_HUGETLB_PAGE=n, the kernel fails to build, throwing this
> error:
> 
> mm/migrate.c: In function ???copy_huge_page???:
> mm/migrate.c:473: error: implicit declaration of function ???page_hstate???
> 
> I got it to build by sticking the following into hugetlb.h:
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 4694afc..fd76912 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -403,6 +403,7 @@ struct hstate {};
>  #define hstate_sizelog(s) NULL
>  #define hstate_vma(v) NULL
>  #define hstate_inode(i) NULL
> +#define page_hstate(p) NULL
>  #define huge_page_size(h) PAGE_SIZE
>  #define huge_page_mask(h) PAGE_MASK
>  #define vma_kernel_pagesize(v) PAGE_SIZE
> 
> I figure that the #define I stuck in isn't actually solving the real
> problem, but it got things working again.
> 

It's based on an upstream patch so I'll check if the problem is there as
well and backport accordingly. This patch to unblock yourself is fine
for now.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
