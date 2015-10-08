Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1FD976B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 02:20:27 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so4015943pab.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:20:26 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com. [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id iu1si63901226pbb.24.2015.10.07.23.20.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 23:20:26 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so44867065pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 23:20:26 -0700 (PDT)
Date: Thu, 8 Oct 2015 15:21:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH -next] mm/vmacache: inline vmacache_valid_mm()
Message-ID: <20151008062115.GA876@swordfish>
References: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1444277879-22039-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (10/07/15 21:17), Davidlohr Bueso wrote:
> This function incurs in very hot paths and merely
> does a few loads for validity check. Lets inline it,
> such that we can save the function call overhead.
> 
> Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
> ---
>  mm/vmacache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/vmacache.c b/mm/vmacache.c
> index b6e3662..fd09dc9 100644
> --- a/mm/vmacache.c
> +++ b/mm/vmacache.c
> @@ -52,7 +52,7 @@ void vmacache_flush_all(struct mm_struct *mm)
>   * Also handle the case where a kernel thread has adopted this mm via use_mm().
>   * That kernel thread's vmacache is not applicable to this mm.
>   */
> -static bool vmacache_valid_mm(struct mm_struct *mm)
> +static inline bool vmacache_valid_mm(struct mm_struct *mm)
>  {
>  	return current->mm == mm && !(current->flags & PF_KTHREAD);
>  }

Seems to be inlined anyway. do you want to inline vmacache_update()?
It looks simple enough (vmacache_valid_mm() is inlined):

void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
{
	if (vmacache_valid_mm(newvma->vm_mm))
		current->vmacache[VMACACHE_HASH(addr)] = newvma;
}


After moving vmacache_update() and vmacache_valid_mm() to include/linux/vmacache.h
(both `static inline')


./scripts/bloat-o-meter vmlinux.o.old vmlinux.o
add/remove: 0/1 grow/shrink: 1/0 up/down: 22/-54 (-32)
function                                     old     new   delta
find_vma                                      97     119     +22
vmacache_update                               54       -     -54


Something like this, perhaps?

---

 include/linux/vmacache.h | 21 ++++++++++++++++++++-
 mm/vmacache.c            | 20 --------------------
 2 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/include/linux/vmacache.h b/include/linux/vmacache.h
index c3fa0fd4..0ec750b 100644
--- a/include/linux/vmacache.h
+++ b/include/linux/vmacache.h
@@ -15,8 +15,27 @@ static inline void vmacache_flush(struct task_struct *tsk)
 	memset(tsk->vmacache, 0, sizeof(tsk->vmacache));
 }
 
+/*
+ * This task may be accessing a foreign mm via (for example)
+ * get_user_pages()->find_vma().  The vmacache is task-local and this
+ * task's vmacache pertains to a different mm (ie, its own).  There is
+ * nothing we can do here.
+ *
+ * Also handle the case where a kernel thread has adopted this mm via use_mm().
+ * That kernel thread's vmacache is not applicable to this mm.
+ */
+static bool vmacache_valid_mm(struct mm_struct *mm)
+{
+	return current->mm == mm && !(current->flags & PF_KTHREAD);
+}
+
+static inline void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
+{
+	if (vmacache_valid_mm(newvma->vm_mm))
+		current->vmacache[VMACACHE_HASH(addr)] = newvma;
+}
+
 extern void vmacache_flush_all(struct mm_struct *mm);
-extern void vmacache_update(unsigned long addr, struct vm_area_struct *newvma);
 extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
 						    unsigned long addr);
 
diff --git a/mm/vmacache.c b/mm/vmacache.c
index b6e3662..14fec21 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -43,26 +43,6 @@ void vmacache_flush_all(struct mm_struct *mm)
 	rcu_read_unlock();
 }
 
-/*
- * This task may be accessing a foreign mm via (for example)
- * get_user_pages()->find_vma().  The vmacache is task-local and this
- * task's vmacache pertains to a different mm (ie, its own).  There is
- * nothing we can do here.
- *
- * Also handle the case where a kernel thread has adopted this mm via use_mm().
- * That kernel thread's vmacache is not applicable to this mm.
- */
-static bool vmacache_valid_mm(struct mm_struct *mm)
-{
-	return current->mm == mm && !(current->flags & PF_KTHREAD);
-}
-
-void vmacache_update(unsigned long addr, struct vm_area_struct *newvma)
-{
-	if (vmacache_valid_mm(newvma->vm_mm))
-		current->vmacache[VMACACHE_HASH(addr)] = newvma;
-}
-
 static bool vmacache_valid(struct mm_struct *mm)
 {
 	struct task_struct *curr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
