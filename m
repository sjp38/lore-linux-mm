Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A2A646B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 16:38:05 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so17316263pac.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 13:38:05 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id a5si19835849pas.5.2015.12.01.13.38.04
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 13:38:05 -0800 (PST)
Date: Tue, 1 Dec 2015 23:38:01 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: mm: BUG in __munlock_pagevec
Message-ID: <20151201213801.GA138207@black.fi.intel.com>
References: <565C5C38.3040705@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565C5C38.3040705@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 30, 2015 at 09:24:56AM -0500, Sasha Levin wrote:
> Hi all,
> 
> I've hit the following while fuzzing with trinity on the latest -next kernel:
> 
> 
> [  850.305385] page:ffffea001a5a0f00 count:0 mapcount:1 mapping:dead000000000400 index:0x1ffffffffff
> [  850.306773] flags: 0x2fffff80000000()
> [  850.307175] page dumped because: VM_BUG_ON_PAGE(1 && PageTail(page))
> [  850.308027] page_owner info is not active (free page?)

Could you check this completely untested patch:

diff --git a/mm/mlock.c b/mm/mlock.c
index af421d8bd6da..9197b6721a1e 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -393,6 +393,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
 		if (!page || page_zone_id(page) != zoneid)
 			break;
 
+		/*
+		 * Do not use pagevec for PTE-mapped THP,
+		 * munlock_vma_pages_range() will handle them.
+		 */
+		if (PageTransCompound(page))
+			break;
+
 		get_page(page);
 		/*
 		 * Increase the address that will be returned *before* the
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
