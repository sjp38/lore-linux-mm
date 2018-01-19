Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 314BB6B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:33:54 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id v25so1815692pfg.14
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 05:33:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e12si7969755pgq.581.2018.01.19.05.33.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Jan 2018 05:33:52 -0800 (PST)
Date: Fri, 19 Jan 2018 05:33:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Bug 198497] New: handle_mm_fault / xen_pmd_val /
 radix_tree_lookup_slot Null pointer
Message-ID: <20180119133351.GC2897@bombadil.infradead.org>
References: <bug-198497-27@https.bugzilla.kernel.org/>
 <20180118135518.639141f0b0ea8bb047ab6306@linux-foundation.org>
 <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7ba7635e-249a-9071-75bb-7874506bd2b2@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, peter@rimuhosting.com

On Thu, Jan 18, 2018 at 02:18:20PM -0800, Laura Abbott wrote:
> Fedora has been seeing similar reports
> https://bugzilla.redhat.com/show_bug.cgi?id=1531779
> 
> Multiple reporters, one in XEN, another on actual hardware

Can you chuck this patch into Fedora?  Should make it easier to see if it's
a "stuck bit" kind of a problem.

---

From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: Detect bad swap entries in lookup

If we have a stuck bit in a PTE, we can end up looking for an entry in
a NULL mapping, which oopses fairly quickly.  Print a warning to help
us debug, and return NULL which will help the machine survive a little
longer.  Although if it has a permanently stuck bit in a PTE, there's only
a 50% chance it'll surive the insertion of a real PTE into that entry.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..5a928e0191a1 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -334,8 +334,12 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 	struct page *page;
 	unsigned long ra_info;
 	int win, hits, readahead;
+	struct address_space *swapper_space = swap_address_space(entry);
+
+	if (WARN(!swapper_space, "Bad swp_entry: %lx\n", entry.val))
+		return NULL;
 
-	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	page = find_get_page(swapper_space, swp_offset(entry));
 
 	INC_CACHE_INFO(find_total);
 	if (page) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
