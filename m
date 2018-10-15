Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0146E6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 18:52:52 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6-v6so15728563pge.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 15:52:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n25-v6si11794091pfh.207.2018.10.15.15.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 15:52:50 -0700 (PDT)
Date: Mon, 15 Oct 2018 15:52:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm: thp: relocate flush_cache_range() in
 migrate_misplaced_transhuge_page()
Message-Id: <20181015155249.9df91c1f4bd1d593c2879b07@linux-foundation.org>
In-Reply-To: <20181015202311.7209-1-aarcange@redhat.com>
References: <20181013002430.698-4-aarcange@redhat.com>
	<20181015202311.7209-1-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, 15 Oct 2018 16:23:11 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:

> There should be no cache left by the time we overwrite the old
> transhuge pmd with the new one. It's already too late to flush through
> the virtual address because we already copied the page data to the new
> physical address.
> 
> So flush the cache before the data copy.
> 
> Also delete the "end" variable to shutoff a "unused variable" warning
> on x86 where flush_cache_range() is a noop.

migrate_misplaced_transhuge_page() has changed a bit.  This is how I
figure the patch should be.  Please check:

--- a/mm/migrate.c~mm-thp-relocate-flush_cache_range-in-migrate_misplaced_transhuge_page
+++ a/mm/migrate.c
@@ -1999,6 +1999,8 @@ int migrate_misplaced_transhuge_page(str
 	/* anon mapping, we can simply copy page->mapping to the new page: */
 	new_page->mapping = page->mapping;
 	new_page->index = page->index;
+	/* flush the cache before copying using the kernel virtual address */
+	flush_cache_range(vma, mmun_start, mmun_end);
 	migrate_page_copy(new_page, page);
 	WARN_ON(PageLRU(new_page));
 
@@ -2037,7 +2039,6 @@ int migrate_misplaced_transhuge_page(str
 	 * The SetPageUptodate on the new page and page_add_new_anon_rmap
 	 * guarantee the copy is visible before the pagetable update.
 	 */
-	flush_cache_range(vma, mmun_start, mmun_end);
 	page_add_anon_rmap(new_page, vma, mmun_start, true);
 	pmdp_huge_clear_flush_notify(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
_
