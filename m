Date: Tue, 5 Oct 2004 13:46:27 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: [PATCH] mhp: transfer dirty tag at radix_tree_replace 
Message-ID: <20041005164627.GB3462@logos.cnet>
References: <20041001234200.GA4635@logos.cnet> <20041002.183015.41630389.taka@valinux.co.jp> <20041002183349.GA7986@logos.cnet> <20041003.131338.41636688.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041003.131338.41636688.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Oct 03, 2004 at 01:13:38PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > > > Cool. I'll take a closer look at the relevant parts of memory hotplug patches 
> > > > this weekend, hopefully. See if I can help with testing of these patches too.
> > > 
> > > Any comments are very welcome.
> > 
> > 
> > I have a few comments about the code:
> > 
> > 1) 
> > I'm pretty sure you should transfer the radix tree tag at radix_tree_replace().
> > If for example you transfer a dirty tagged page to another zone, an mpage_writepages()
> > will miss it (because it uses pagevec_lookup_tag(PAGECACHE_DIRTY_TAG)). 
> > 
> > Should be quite trivial to do (save tags before deleting and set to new entry, 
> > all in radix_tree_replace).
> > 
> > My implementation also contained the same bug.
> 
> Yes, it's one of the issues to do. The tag should be transferred in
> radix_tree_replace() as you pointed out. The current implementation
> sets the tag in set_page_dirty(newpage).

OK, guys, can you test this please?

This transfer the dirty radix tree tag at radix_tree_replace, avoiding 
a potential miss on tag-lookup.  We could also copy all bits representing 
the valid tags for this node in the radix tree. 

But this uses the available interfaces from radix-lib.c. In case 
a new tag gets added, radix_tree_replace() will have to know about it.

Pretty straightforward.

I still need to figure out how to use Iwamoto's patch to add/remove 
zone's on the fly (for testing the migration process).

diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/include/linux/radix-tree.h linux-2.6.9-rc2-mm4/include/linux/radix-tree.h
--- linux-2.6.9-rc2-mm4.mhp.orig/include/linux/radix-tree.h	2004-10-05 15:09:39.198873072 -0300
+++ linux-2.6.9-rc2-mm4/include/linux/radix-tree.h	2004-10-05 15:23:42.441680680 -0300
@@ -68,9 +68,17 @@
 radix_tree_replace(struct radix_tree_root *root,
 				unsigned long index, void *item)
 {
+	int dirty;
+
+	dirty = radix_tree_tag_get(root, index, PAGECACHE_TAG_DIRTY);
+
 	if (radix_tree_delete(root, index) == NULL)
 		return -1;
 	radix_tree_insert(root, index, item);
+
+	if (dirty)
+		radix_tree_tag_set(root, index, PAGECACHE_TAG_DIRTY);
+
 	return 0;
 }
 
diff -Nur linux-2.6.9-rc2-mm4.mhp.orig/lib/radix-tree.c linux-2.6.9-rc2-mm4/lib/radix-tree.c
--- linux-2.6.9-rc2-mm4.mhp.orig/lib/radix-tree.c	2004-10-05 15:09:29.442356288 -0300
+++ linux-2.6.9-rc2-mm4/lib/radix-tree.c	2004-10-05 15:24:16.961432880 -0300
@@ -443,7 +443,6 @@
 }
 EXPORT_SYMBOL(radix_tree_tag_clear);
 
-#ifndef __KERNEL__	/* Only the test harness uses this at present */
 /**
  *	radix_tree_tag_get - get a tag on a radix tree node
  *	@root:		radix tree root
@@ -495,7 +494,6 @@
 	}
 }
 EXPORT_SYMBOL(radix_tree_tag_get);
-#endif
 
 static unsigned int
 __lookup(struct radix_tree_root *root, void **results, unsigned long index,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
