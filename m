Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id CCE796B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 15:51:21 -0500 (EST)
Date: Thu, 1 Mar 2012 12:51:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] ksm: cleanup: introduce ksm_check_mm()
Message-Id: <20120301125119.dee770f8.akpm@linux-foundation.org>
In-Reply-To: <1330594374-13497-2-git-send-email-lliubbo@gmail.com>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
	<1330594374-13497-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: hughd@google.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

On Thu, 1 Mar 2012 17:32:54 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> +static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vma,
> +		unsigned long addr)
> +{
> +	if (ksm_test_exit(mm))
> +		return 0;
> +	vma = find_vma(mm, addr);
> +	if (!vma || vma->vm_start > addr)
> +		return 0;
> +	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
> +		return 0;
> +	return 1;
> +}

Can we please think of a suitable name for this check, other than
"check"?  IOW, give the function a meaningful name which describes what
it is checking?

And it's not checking the mm, is it?  It is checking the address: to
see whether it lies within a mergeable anon vma.

So maybe

--- a/mm/ksm.c~ksm-cleanup-introduce-ksm_check_mm-fix
+++ a/mm/ksm.c
@@ -375,17 +375,17 @@ static int break_ksm(struct vm_area_stru
 	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
 }
 
-static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr)
+static bool in_mergeable_anon_vma(struct mm_struct *mm,
+				 struct vm_area_struct *vma, unsigned long addr)
 {
 	if (ksm_test_exit(mm))
-		return 0;
+		return false;
 	vma = find_vma(mm, addr);
 	if (!vma || vma->vm_start > addr)
-		return 0;
+		return false;
 	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
 static void break_cow(struct rmap_item *rmap_item)
@@ -401,7 +401,7 @@ static void break_cow(struct rmap_item *
 	put_anon_vma(rmap_item->anon_vma);
 
 	down_read(&mm->mmap_sem);
-	if (ksm_check_mm(mm, vma, addr))
+	if (in_mergeable_anon_vma(mm, vma, addr))
 		break_ksm(vma, addr);
 	up_read(&mm->mmap_sem);
 }
@@ -428,7 +428,7 @@ static struct page *get_mergeable_page(s
 	struct page *page;
 
 	down_read(&mm->mmap_sem);
-	if (!ksm_check_mm(mm, vma, addr))
+	if (!in_mergeable_anon_vma(mm, vma, addr))
 		goto out;
 
 	page = follow_page(vma, addr, FOLL_GET);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
