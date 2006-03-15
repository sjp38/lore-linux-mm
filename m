Date: Tue, 14 Mar 2006 19:53:22 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration: Fail with error if swap not setup
In-Reply-To: <20060314192443.0d121e73.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603141949290.24395@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603141903150.24199@schroedinger.engr.sgi.com>
 <20060314192443.0d121e73.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 14 Mar 2006, Andrew Morton wrote:

> >  		lru_add_drain_all();
> > +	}
> >  
> 
> Whereas this appears to be racy...

Migration just makes the best effort. Page that are moved off the LRU 
after the draining end up on the failed migration list and will not be 
migrated.

Sorry about the blank. New patch with more explanations?



page migration: Fail with error if swap not setup

Currently the migration of anonymous pages will silently fail if no
swap is setup. This patch makes page migration functions to check
for available swap and fail with -ENODEV if no swap space is available.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/mempolicy.c	2006-03-14 16:31:15.000000000 -0800
+++ linux-2.6.16-rc6/mm/mempolicy.c	2006-03-14 19:52:25.000000000 -0800
@@ -330,9 +330,19 @@ check_range(struct mm_struct *mm, unsign
 	int err;
 	struct vm_area_struct *first, *vma, *prev;
 
-	/* Clear the LRU lists so pages can be isolated */
-	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
+	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
+		/* Must have swap device for migration */
+		if (nr_swap_pages <= 0)
+			return ERR_PTR(-ENODEV);
+
+		/*
+		 * Clear the LRU lists so pages can be isolated.
+		 * Note that pages may be moved off the LRU after we have
+		 * drained them. Those pages will fail to migrate like other
+		 * pages that may be busy.
+		 */
 		lru_add_drain_all();
+	}
 
 	first = find_vma(mm, start);
 	if (!first)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
