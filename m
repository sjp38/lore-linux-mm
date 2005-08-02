Message-ID: <42EF66D7.5040001@yahoo.com.au>
Date: Tue, 02 Aug 2005 22:28:07 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
References: <OF3BCB86B7.69087CF8-ON42257051.003DCC6C-42257051.00420E16@de.ibm.com> <Pine.LNX.4.61.0508021309470.3005@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508021309470.3005@goblin.wat.veritas.com>
Content-Type: multipart/mixed;
 boundary="------------070804070606000105020806"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070804070606000105020806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hugh Dickins wrote:
> On Tue, 2 Aug 2005, Martin Schwidefsky wrote:

>>With the additional !pte_write(pte) check (and if I haven't overlooked
>>something which is not unlikely) s390 should work fine even without the
>>software-dirty bit hack.
> 
> 
> I agree the pte_write check ought to go back in next to the pte_dirty
> check, and that will leave s390 handling most uses of get_user_pages
> correctly, but still failing to handle the peculiar case of strace
> modifying a page to which the user does not currently have write access
> (e.g. setting a breakpoint in readonly text).
> 

Oh, here is the patch I sent Linus and forgot to CC
everyone else.

-- 
SUSE Labs, Novell Inc.


--------------070804070606000105020806
Content-Type: text/plain;
 name="mm-opt-gup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-opt-gup.patch"

Allow __follow_page to succeed when encountering a clean, writeable
pte. Requires reintroduction of the direct page dirtying. Means
get_user_pages doesn't have to drop the page_table_lock and enter
the page fault handler for every clean, writeable pte it encounters
(when being called for write).

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -811,15 +811,18 @@ static struct page *__follow_page(struct
 	pte = *ptep;
 	pte_unmap(ptep);
 	if (pte_present(pte)) {
-		if (write && !pte_dirty(pte))
+		if (write && !pte_write(pte) && !pte_dirty(pte))
 			goto out;
 		if (read && !pte_read(pte))
 			goto out;
 		pfn = pte_pfn(pte);
 		if (pfn_valid(pfn)) {
 			page = pfn_to_page(pfn);
-			if (accessed)
+			if (accessed) {
+				if (write && !pte_dirty(pte)&& !PageDirty(page))
+					set_page_dirty(page);
 				mark_page_accessed(page);
+			}
 			return page;
 		}
 	}

--------------070804070606000105020806--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
