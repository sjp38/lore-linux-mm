Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 36A0E6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 05:33:03 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1552257pad.14
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 02:33:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.182])
        by mx.google.com with SMTP id hb3si9324753pac.7.2013.11.18.02.32.55
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 02:33:00 -0800 (PST)
Date: Mon, 18 Nov 2013 10:32:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [v3][PATCH 2/2] mm: thp: give transparent hugepage code a
 separate copy_page
Message-ID: <20131118103247.GF26002@suse.de>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131115225553.B0E9DFFB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Nov 15, 2013 at 02:55:53PM -0800, Dave Hansen wrote:
> 
> Changes from v2:
>  * 
> Changes from v1:
>  * removed explicit might_sleep() in favor of the one that we
>    get from the cond_resched();
> 
> --
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Right now, the migration code in migrate_page_copy() uses
> copy_huge_page() for hugetlbfs and thp pages:
> 
>        if (PageHuge(page) || PageTransHuge(page))
>                 copy_huge_page(newpage, page);
> 
> So, yay for code reuse.  But:
> 
> void copy_huge_page(struct page *dst, struct page *src)
> {
>         struct hstate *h = page_hstate(src);
> 
> and a non-hugetlbfs page has no page_hstate().  This works 99% of
> the time because page_hstate() determines the hstate from the
> page order alone.  Since the page order of a THP page matches the
> default hugetlbfs page order, it works.
> 
> But, if you change the default huge page size on the boot
> command-line (say default_hugepagesz=1G), then we might not even
> *have* a 2MB hstate so page_hstate() returns null and
> copy_huge_page() oopses pretty fast since copy_huge_page()
> dereferences the hstate:
> 
> void copy_huge_page(struct page *dst, struct page *src)
> {
>         struct hstate *h = page_hstate(src);
>         if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> ...
> 
> Mel noticed that the migration code is really the only user of
> these functions.  This moves all the copy code over to migrate.c
> and makes copy_huge_page() work for THP by checking for it
> explicitly.
> 
> I believe the bug was introduced in b32967ff101:
> Author: Mel Gorman <mgorman@suse.de>
> Date:   Mon Nov 19 12:35:47 2012 +0000
> mm: numa: Add THP migration for the NUMA working set scanning fault case.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
