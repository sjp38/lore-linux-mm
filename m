Date: Tue, 13 Feb 2007 14:49:09 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
Message-Id: <20070213144909.70943de2.randy.dunlap@oracle.com>
In-Reply-To: <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
	<20070212150802.f240e94f.akpm@linux-foundation.org>
	<45D12715.4070408@yahoo.com.au>
	<20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
	<Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > > oops.  CONFIG_SWAP=n,  I assume?
> 
> Sorry for being so slow to respond on this.  Yes, I'm inclined to
> your ifdeffery fix - one can go cleverer, but I'd say it's the
> appropriate fix now.
> 
> But, please change your "present = 0;" to "present = 1;" -
> if CONFIG_SWAP isn't on, it has to be a migration entry,
> which always counts as present.
> 
> > 
> > BUT:  what is <present> used for in that loop?  or is it used?
> 
> Well spotted!  Something has gone missing: there needs to be a
> 			vec[i] = present;
> at the bottom of that loop.


From: Randy Dunlap <randy.dunlap@oracle.com>

Don't check for pte swap entries when CONFIG_SWAP=n.
And save 'present' in the vec array.

mm/built-in.o: In function `sys_mincore':
(.text+0xe584): undefined reference to `swapper_space'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/mincore.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-2.6.20-git9.orig/mm/mincore.c
+++ linux-2.6.20-git9/mm/mincore.c
@@ -111,6 +111,7 @@ static long do_mincore(unsigned long add
 			present = mincore_page(vma->vm_file->f_mapping, pgoff);
 
 		} else { /* pte is a swap entry */
+#ifdef CONFIG_SWAP
 			swp_entry_t entry = pte_to_swp_entry(pte);
 			if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
@@ -119,7 +120,11 @@ static long do_mincore(unsigned long add
 				pgoff = entry.val;
 				present = mincore_page(&swapper_space, pgoff);
 			}
+#else
+			present = 1;
+#endif
 		}
+		vec[i] = present;
 	}
 	pte_unmap_unlock(ptep-1, ptl);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
