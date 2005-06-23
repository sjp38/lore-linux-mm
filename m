Message-ID: <42BA65CD.6020006@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:33:33 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] 2/5: micro optimisation for mm/rmap.c
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au> <20050623072609.GA3334@holomorphy.com>
In-Reply-To: <20050623072609.GA3334@holomorphy.com>
Content-Type: multipart/mixed;
 boundary="------------000306070506030701020106"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000306070506030701020106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

William Lee Irwin III wrote:
> On Thu, Jun 23, 2005 at 05:06:35PM +1000, Nick Piggin wrote:
> 
>>+		index = (address - vma->vm_start) >> PAGE_SHIFT;
>>+		index += vma->vm_pgoff;
>>+		index >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
>>+		page->index = index;
> 
> 
> linear_page_index()
> 

Ah indeed it is, thanks. I'll queue this up as patch 2.5, then?


--------------000306070506030701020106
Content-Type: text/plain;
 name="mm-cleanup-rmap.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-cleanup-rmap.patch"

Use linear_page_index in mm/rmap.c, as noted by Bill Irwin.

Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -448,16 +448,11 @@ void page_add_anon_rmap(struct page *pag
 
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		struct anon_vma *anon_vma = vma->anon_vma;
-		pgoff_t index;
-
 		BUG_ON(!anon_vma);
 		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 		page->mapping = (struct address_space *) anon_vma;
 
-		index = (address - vma->vm_start) >> PAGE_SHIFT;
-		index += vma->vm_pgoff;
-		index >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
-		page->index = index;
+		page->index = linear_page_index(vma, address);
 
 		inc_page_state(nr_mapped);
 	}

--------------000306070506030701020106--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
