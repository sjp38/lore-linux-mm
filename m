Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AC4486B0083
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 14:18:44 -0500 (EST)
Date: Wed, 10 Mar 2010 13:18:42 -0600
From: Robin Holt <holt@sgi.com>
Subject: mm/ksm.c seems to be doing an unneeded _notify.
Message-ID: <20100310191842.GL5677@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Chris Wright <chrisw@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While reviewing ksm.c, I noticed that ksm.c does:

        if (pte_write(*ptep)) {
                pte_t entry;

                swapped = PageSwapCache(page);
                flush_cache_page(vma, addr, page_to_pfn(page));
                /*
                 * Ok this is tricky, when get_user_pages_fast() run it doesnt
                 * take any lock, therefore the check that we are going to make
                 * with the pagecount against the mapcount is racey and
                 * O_DIRECT can happen right after the check.
                 * So we clear the pte and flush the tlb before the check
                 * this assure us that no O_DIRECT can happen after the check
                 * or in the middle of the check.
                 */
                entry = ptep_clear_flush(vma, addr, ptep);
                /*
                 * Check that no O_DIRECT or similar I/O is in progress on the
                 * page 
                 */
                if (page_mapcount(page) + 1 + swapped != page_count(page)) {
                        set_pte_at_notify(mm, addr, ptep, entry);
                        goto out_unlock;
                }
                entry = pte_wrprotect(entry);
                set_pte_at_notify(mm, addr, ptep, entry);


I would think the error case (where the page has an elevated page_count)
should not be using set_pte_at_notify.  In that event, you are simply
restoring the previous value.  Have I missed something or is this an
extraneous _notify?

Thanks,
Robin Holt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
