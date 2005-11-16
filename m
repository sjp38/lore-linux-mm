Date: Wed, 16 Nov 2005 10:54:04 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 2/2] Fold numa_maps into mempolicy.c
In-Reply-To: <200511160936.04721.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511161048530.15919@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
 <Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
 <20051115231051.5437e25b.pj@sgi.com> <200511160936.04721.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Nov 2005, Andi Kleen wrote:

> > Except for /proc output, is there any call to get_vma_policy made on any
> > task other than current?
> 
> In the original version there wasn't any. I still think it's a mistake
> to allow it for /proc, unfortunately the patch went in.

We could make the function local to mempolicy.c if we fold the numa_maps 
interface into mempolicy.c. That would prevent outside uses of this and so 
prevent additional outside uses.

But then Paul was looking for such a use?

f.e. 

Index: linux-2.6.14-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.14-mm2.orig/mm/mempolicy.c	2005-11-15 14:28:32.000000000 -0800
+++ linux-2.6.14-mm2/mm/mempolicy.c	2005-11-16 10:53:01.000000000 -0800
@@ -928,7 +928,7 @@ asmlinkage long compat_sys_mbind(compat_
 #endif
 
 /* Return effective policy for a VMA */
-struct mempolicy *
+static struct mempolicy *
 get_vma_policy(struct task_struct *task, struct vm_area_struct *vma, unsigned long addr)
 {
 	struct mempolicy *pol = task->mempolicy;
Index: linux-2.6.14-mm2/include/linux/mempolicy.h
===================================================================
--- linux-2.6.14-mm2.orig/include/linux/mempolicy.h	2005-11-16 10:43:41.000000000 -0800
+++ linux-2.6.14-mm2/include/linux/mempolicy.h	2005-11-16 10:52:40.000000000 -0800
@@ -142,9 +142,6 @@ void mpol_free_shared_policy(struct shar
 struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
-struct mempolicy *get_vma_policy(struct task_struct *task,
-			struct vm_area_struct *vma, unsigned long addr);
-
 extern void numa_default_policy(void);
 extern void numa_policy_init(void);
 extern void numa_policy_rebind(const nodemask_t *old, const nodemask_t *new);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
