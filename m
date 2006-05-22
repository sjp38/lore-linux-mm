Date: Mon, 22 May 2006 13:29:05 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: tracking dirty pages patches
Message-Id: <20060522132905.6e1a711c.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: a.p.zijlstra@chello.nl, torvalds@osdl.org, dhowells@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> Belated observations on your "tracking dirty pages" patches.

Thanks, Hugh.

> page_wrprotect is a nice use of rmap, but I see a couple of problems.
> One is in the lock ordering (there's info on mm lock ordering at the
> top of filemap.c, but I find the list at the top of rmap.c easier).
> 
> set_page_dirty has always (awkwardly) been liable to be called from
> very low in the hierarchy; whereas you're assuming clear_page_dirty
> is called from much higher up.  And in most cases there's no problem
> (please cross-check to confirm that); but try_to_free_buffers in fs/
> buffer.c calls it while holding mapping->private_lock - page_wrprotect
> called from test_clear_page_dirty then violates the order.
> 
> If we're lucky and that is indeed the only violation, maybe Andrew
> can recommend a change to try_to_free_buffers to avoid it: I have
> no appreciation of the issues at that end myself.

I had troubles with that as well - tree_lock is a very "inner" lock.  So I
moved test_clear_page_dirty()'s call to page_wrprotect() to be outside
tree_lock.

But I don't think you were referring to that - I am unable to evaluate your
expression "the order".

The running of page_wrprotect_file() inside private_lock is a worry, yes. 
We can move the clear_page_dirty() call in try_to_free_buffers() to be
outside private_lock.

But I don't know which particular ranking violation you've identified.

> ...
>
> (Why does follow_pages set_page_dirty at all?  I _think_ it's in case
> the get_user_pages caller forgets to set_page_dirty when releasing.
> But that's not how we usually write kernel code, to hide mistakes most
> of the time,

Yes, that would be bad.

> and your mods may change the balance there.  Andrew will
> remember better whether that set_page_dirty has stronger justification.)

It was added by the below, which nobody was terribly happy with at the
time.  (Took me 5-10 minutes to hunt this down.  Insert rote comment about
comments).




Date: Mon, 19 Jan 2004 18:43:46 +0000
From: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: bk-commits-head@vger.kernel.org
Subject: [PATCH] s390: endless loop in follow_page.


ChangeSet 1.1490.3.215, 2004/01/19 10:43:46-08:00, akpm@osdl.org

	[PATCH] s390: endless loop in follow_page.
	
	From: Martin Schwidefsky <schwidefsky@de.ibm.com>
	
	Fix endless loop in get_user_pages() on s390.  It happens only on s/390
	because pte_dirty always returns 0.  For all other architectures this is an
	optimization.
	
	In the case of "write && !pte_dirty(pte)" follow_page() returns NULL.  On all
	architectures except s390 handle_pte_fault() will then create a pte with
	pte_dirty(pte)==1 because write_access==1.  In the following, second call to
	follow_page() all is fine.  With the physical dirty bit patch pte_dirty() is
	always 0 for s/390 because the dirty bit doesn't live in the pte.


# This patch includes the following deltas:
#	           ChangeSet	1.1490.3.214 -> 1.1490.3.215
#	         mm/memory.c	1.145   -> 1.146  
#

 memory.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)


diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	Mon Jan 19 15:47:24 2004
+++ b/mm/memory.c	Mon Jan 19 15:47:24 2004
@@ -651,14 +651,19 @@
 	pte = *ptep;
 	pte_unmap(ptep);
 	if (pte_present(pte)) {
-		if (!write || (pte_write(pte) && pte_dirty(pte))) {
-			pfn = pte_pfn(pte);
-			if (pfn_valid(pfn)) {
-				struct page *page = pfn_to_page(pfn);
-
-				mark_page_accessed(page);
-				return page;
-			}
+		if (write && !pte_write(pte))
+			goto out;
+		if (write && !pte_dirty(pte)) {
+			struct page *page = pte_page(pte);
+			if (!PageDirty(page))
+				set_page_dirty(page);
+		}
+		pfn = pte_pfn(pte);
+		if (pfn_valid(pfn)) {
+			struct page *page = pfn_to_page(pfn);
+			
+			mark_page_accessed(page);
+			return page;
 		}
 	}
 
-
To unsubscribe from this list: send the line "unsubscribe bk-commits-head" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
