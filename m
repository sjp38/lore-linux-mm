Date: Mon, 16 Feb 2004 22:00:31 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mremap NULL pointer dereference fix
Message-Id: <20040216220031.16a2c0c7.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0402162144510.30742@home.osdl.org>
References: <Pine.SOL.4.44.0402162331580.20215-100000@blue.engin.umich.edu>
	<Pine.LNX.4.58.0402162127220.30742@home.osdl.org>
	<Pine.LNX.4.58.0402162144510.30742@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: vrajesh@umich.edu, linux-kernel@vger.kernel.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds <torvalds@osdl.org> wrote:
>
> Hmm.. Looking a bit more at it, does this alternate patch work? It's 
>  _slightly_ less ugly, and it also removes the nonsensical TLB invalidate 
>  instead of moving it around together with the comment that says that it 
>  shouldn't exist.
> 
>  The TLB is (properly) invalidated by "copy_one_pte()" if the mapping 
>  actually changes.
> 
>  Did I miss anything?

This saves a goto.   It works, but I wasn't able to trigger
the oops without it either.


diff -puN mm/mremap.c~mremap-oops-fix mm/mremap.c
--- 25/mm/mremap.c~mremap-oops-fix	2004-02-16 20:53:25.000000000 -0800
+++ 25-akpm/mm/mremap.c	2004-02-16 21:00:05.000000000 -0800
@@ -135,15 +135,17 @@ move_one_page(struct vm_area_struct *vma
 		dst = alloc_one_pte_map(mm, new_addr);
 		if (src == NULL)
 			src = get_one_pte_map_nested(mm, old_addr);
-		error = copy_one_pte(vma, old_addr, src, dst, &pte_chain);
-		pte_unmap_nested(src);
-		pte_unmap(dst);
-	} else
 		/*
-		 * Why do we need this flush ? If there is no pte for
-		 * old_addr, then there must not be a pte for it as well.
+		 * Since alloc_one_pte_map can drop and re-acquire
+		 * page_table_lock, we should re-check the src entry...
 		 */
-		flush_tlb_page(vma, old_addr);
+		if (src) {
+			error = copy_one_pte(vma, old_addr, src,
+						dst, &pte_chain);
+			pte_unmap_nested(src);
+		}
+		pte_unmap(dst);
+	}
 	spin_unlock(&mm->page_table_lock);
 	pte_chain_free(pte_chain);
 out:

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
