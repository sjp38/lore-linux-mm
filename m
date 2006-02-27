Date: Mon, 27 Feb 2006 10:11:18 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0602270934260.3185@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Hugh Dickins wrote:

> > Or better do the rcu locking before calling page_lock_anon_vma 
> > and the unlocking after spin_unlock to have proper nesting of locks?
> 
> No, page_lock_anon_vma is all about insulating the rest of the code
> from these difficulties: I do prefer it as is.

Hmm... How about page_lock_anon_vma and page_unlock_anon_vma? This 

> That said, I had mixed feelings when the name "rcu_read_lock" was
> introduced: it's not always helpful to distinguish it from
> preempt_disable in that way.

Hmm.. It seems that the rcu implementation has been fluctuating 
somewhat in the past.

I fear that code reviewers will not realize that the freeing of the 
anon_vma is in fact delayed much longer than a superficial review of the 
page_lock_anon_vma reveals.

How about this patch:



page_unlock_anon_vma: cleanup locking and comments

page_unlock_anon_vma calls rcu_read_unlock() after a spinlock has
been obtained to delay rcu freeing past rcu_read_unlock(). Make this
rcu behavior evident by moving the rcu_read_unlock() after the
spin_unlock() and add some comments explaining why and how locking
works in page_unlock_anon_vma().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5/mm/rmap.c
===================================================================
--- linux-2.6.16-rc5.orig/mm/rmap.c	2006-02-27 10:04:15.000000000 -0800
+++ linux-2.6.16-rc5/mm/rmap.c	2006-02-27 10:10:25.000000000 -0800
@@ -196,16 +196,36 @@ static struct anon_vma *page_lock_anon_v
 	anon_mapping = (unsigned long) page->mapping;
 	if (!(anon_mapping & PAGE_MAPPING_ANON))
 		goto out;
+
+	/*
+	 * We do not remove the mapping when we unmap the vmas and the
+	 * anon_vma that may contain this page.
+	 * page->mapping is only set to NULL when the page is finally
+	 * returned to the free pool.
+	 *
+	 * Thus we can only be sure that the mapping is valid if the page
+	 * is still mapped by a process. Should the page become unmapped
+	 * after the check below then rcu locking will preserve the anon_vma
+	 * structure until page_unlock_anon_vma() is called.
+	 */
 	if (!page_mapped(page))
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
 	spin_lock(&anon_vma->lock);
+	return anon_vma;
+
 out:
 	rcu_read_unlock();
 	return anon_vma;
 }
 
+static void page_unlock_anon_vma(struct anon_vma *anon_vma)
+{
+	spin_unlock(&anon_vma);
+	rcu_read_unlock();
+}
+
 #ifdef CONFIG_MIGRATION
 /*
  * Remove an anonymous page from swap replacing the swap pte's
@@ -369,7 +389,7 @@ static int page_referenced_anon(struct p
 		if (!mapcount)
 			break;
 	}
-	spin_unlock(&anon_vma->lock);
+	page_unlock_anon_vma(anon_vma);
 	return referenced;
 }
 
@@ -746,7 +766,7 @@ static int try_to_unmap_anon(struct page
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
 	}
-	spin_unlock(&anon_vma->lock);
+	page_unlock_anon_vma(anon_vma);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
