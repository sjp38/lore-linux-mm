Date: Tue, 26 Apr 2005 23:28:44 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: rlimit_as-checking-fix.patch
Message-Id: <20050426232844.44e8b5fb.akpm@osdl.org>
In-Reply-To: <20050427062330.GN493@shell0.pdx.osdl.net>
References: <20050425195556.092d0579.akpm@osdl.org>
	<20050427062330.GN493@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wright <chrisw@osdl.org>
Cc: hugh@veritas.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chris Wright <chrisw@osdl.org> wrote:
>
> > +int may_expand_vm(struct mm_struct *mm, unsigned long nbytes)
>  > +{
>  > +	unsigned long cur = current->mm->total_vm;	/* pages */
> 
>  I guess you meant simply mm->total_vm not current->mm->total_vm?

Yes.  Sigh.

diff -puN mm/mmap.c~rlimit_as-checking-fix mm/mmap.c
--- 25/mm/mmap.c~rlimit_as-checking-fix	2005-04-26 22:40:12.316426776 -0700
+++ 25-akpm/mm/mmap.c	2005-04-26 23:27:26.549557848 -0700
@@ -1009,8 +1009,7 @@ munmap_back:
 	}
 
 	/* Check against address space limit. */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
 	if (accountable && (!(flags & MAP_NORESERVE) ||
@@ -1421,7 +1420,7 @@ static int acct_stack_growth(struct vm_a
 	struct rlimit *rlim = current->signal->rlim;
 
 	/* address space limit tests */
-	if (mm->total_vm + grow > rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT)
+	if (!may_expand_vm(mm, grow))
 		return -ENOMEM;
 
 	/* Stack limit test */
@@ -1848,8 +1847,7 @@ unsigned long do_brk(unsigned long addr,
 	}
 
 	/* Check against address space limits *after* clearing old maps... */
-	if ((mm->total_vm << PAGE_SHIFT) + len
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
 	if (mm->map_count > sysctl_max_map_count)
@@ -2019,3 +2017,19 @@ struct vm_area_struct *copy_vma(struct v
 	}
 	return new_vma;
 }
+
+/*
+ * Return true if the calling process may expand its vm space by the passed
+ * number of pages
+ */
+int may_expand_vm(struct mm_struct *mm, unsigned long npages)
+{
+	unsigned long cur = mm->total_vm;	/* pages */
+	unsigned long lim;
+
+	lim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
+
+	if (cur + npages > lim)
+		return 0;
+	return 1;
+}
diff -puN mm/mremap.c~rlimit_as-checking-fix mm/mremap.c
--- 25/mm/mremap.c~rlimit_as-checking-fix	2005-04-26 22:40:12.318426472 -0700
+++ 25-akpm/mm/mremap.c	2005-04-26 22:52:30.489207456 -0700
@@ -347,10 +347,10 @@ unsigned long do_mremap(unsigned long ad
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
 			goto out;
 	}
-	ret = -ENOMEM;
-	if ((current->mm->total_vm << PAGE_SHIFT) + (new_len - old_len)
-	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
+	if (!may_expand_vm(current->mm, (new_len - old_len) >> PAGE_SHIFT)) {
+		ret = -ENOMEM;
 		goto out;
+	}
 
 	if (vma->vm_flags & VM_ACCOUNT) {
 		charged = (new_len - old_len) >> PAGE_SHIFT;
diff -puN include/linux/mm.h~rlimit_as-checking-fix include/linux/mm.h
--- 25/include/linux/mm.h~rlimit_as-checking-fix	2005-04-26 22:40:12.000000000 -0700
+++ 25-akpm/include/linux/mm.h	2005-04-26 22:52:34.000000000 -0700
@@ -761,6 +761,7 @@ extern void __vma_link_rb(struct mm_stru
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
 	unsigned long addr, unsigned long len, pgoff_t pgoff);
 extern void exit_mmap(struct mm_struct *);
+extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
