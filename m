Date: Sun, 1 Jun 2003 14:34:39 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: 2.5.70-bk4+: oops by mc -v /proc/bus/pci/00/00.0
Message-ID: <20030601143439.O626@nightmaster.csn.tu-chemnitz.de>
References: <20030531165523.GA18067@steel.home> <20030531195414.10c957b7.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030531195414.10c957b7.akpm@digeo.com>; from akpm@digeo.com on Sat, May 31, 2003 at 07:54:14PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Sat, May 31, 2003 at 07:54:14PM -0700, Andrew Morton wrote:
> It's pretty lame.  Really we need a proper vma constructor
> somewhere.

you mean sth. like this? (Just initialized the members, that I had useful
defaults for.)

--- linux-2.5.70/kernel/fork.c	Sun Jun  1 13:08:54 2003
+++ linux-2.5.70/kernel/fork.c	Sun Jun  1 14:26:19 2003
@@ -1147,6 +1147,35 @@
 /* SLAB cache for mm_struct structures (tsk->mm) */
 kmem_cache_t *mm_cachep;
 
+/* SLAB constructor for vm_area_struct objects */
+static void init_vm_area_struct(void *at, kmem_cache_t * dummy, 
+		unsigned long flags) 
+{
+	        struct vm_area_struct *t = at;
+
+		if (SLAB_CTOR_CONSTRUCTOR != 
+			(flags & (SLAB_CTOR_CONSTRUCTOR | SLAB_CTOR_VERIFY) ))
+			return;
+
+		/* these are NOT initialized, because they must be intialized
+		 * by the caller of kmem_cache_alloc():
+
+			t->vm_mm
+			t->vm_start
+			t->vm_end
+			t->vm_page_prot
+			t->vm_flags
+			t->vm_rb
+
+		*/
+		t->vm_next = NULL;
+		INIT_LIST_HEAD(&t->shared);
+		t->vm_ops = NULL;
+		t->vm_pgoff = 0; /* FIXME: maybe ~0UL is better here? */
+		t->vm_file = NULL;
+		t->private_data = NULL;
+}
+
 void __init proc_caches_init(void)
 {
 	sighand_cachep = kmem_cache_create("sighand_cache",
@@ -1175,7 +1204,7 @@
  
 	vm_area_cachep = kmem_cache_create("vm_area_struct",
 			sizeof(struct vm_area_struct), 0,
-			0, NULL, NULL);
+			0, init_vm_area_struct, NULL);
 	if(!vm_area_cachep)
 		panic("vma_init: Cannot alloc vm_area_struct SLAB cache");
 

Regards

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
