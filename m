Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 308316B0036
	for <linux-mm@kvack.org>; Sat,  2 Aug 2014 09:11:13 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so7106236pdj.30
        for <linux-mm@kvack.org>; Sat, 02 Aug 2014 06:11:12 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0237.outbound.protection.outlook.com. [207.46.163.237])
        by mx.google.com with ESMTPS id gl10si13014993pbd.139.2014.08.02.06.11.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 02 Aug 2014 06:11:12 -0700 (PDT)
From: Oded Gabbay <oded.gabbay@amd.com>
Subject: [PATCH] mmu_notifier: add call_srcu and sync function for listener to delay call and sync
Date: Sat, 2 Aug 2014 16:10:51 +0300
Message-ID: <1406985051-19620-1-git-send-email-oded.gabbay@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>, John.Bridgman@amd.com, Joerg Roedel <joro@8bytes.org>, hpa@zytor.com, mgorman@suse.de, aarcange@redhat.com, airlied@gmail.com, Alexander.Deucher@amd.com, Oded Gabbay <oded.gabbay@amd.com>

From: Peter Zijlstra <peterz@infradead.org>

When kernel device drivers or subsystems want to bind their lifespan to t=
he
lifespan of the mm_struct, they usually use one of the following methods:

1. Manually calling a function in the interested kernel module. The funct=
ion
call needs to be placed in mmput. This method was rejected by several ker=
nel
maintainers.

2. Registering to the mmu notifier release mechanism.

The problem with the latter approach is that the mmu_notifier_release cal=
lback
is called from__mmu_notifier_release (called from exit_mmap). That functi=
on
iterates over the list of mmu notifiers and don't expect the release call=
back
function to remove itself from the list. Therefore, the callback function=
 in
the kernel module can't release the mmu_notifier_object, which is actuall=
y the
kernel module's object itself. As a result, the destruction of the kernel
module's object must to be done in a delayed fashion.

This patch adds support for this delayed callback, by adding a new
mmu_notifier_call_srcu function that receives a function ptr and calls th=
at
function with call_srcu. In that function, the kernel module releases its
object. To use mmu_notifier_call_srcu, the calling module needs to call b=
efore
that a new function called mmu_notifier_unregister_no_release that as its=
 name
implies, unregisters a notifier without calling its notifier release call=
back.

This patch also adds a function that will call barrier_srcu so those kern=
el
modules can sync with mmu_notifier.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
Signed-off-by: Oded Gabbay <oded.gabbay@amd.com>
---
 include/linux/mmu_notifier.h |  6 ++++++
 mm/mmu_notifier.c            | 40 ++++++++++++++++++++++++++++++++++++++=
+-
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..2728869 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -170,6 +170,8 @@ extern int __mmu_notifier_register(struct mmu_notifie=
r *mn,
 				   struct mm_struct *mm);
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
+extern void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
+					       struct mm_struct *mm);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
@@ -288,6 +290,10 @@ static inline void mmu_notifier_mm_destroy(struct mm=
_struct *mm)
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })
=20
+extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
+				   void (*func)(struct rcu_head *rcu));
+extern void mmu_notifier_synchronize(void);
+
 #else /* CONFIG_MMU_NOTIFIER */
=20
 static inline void mmu_notifier_release(struct mm_struct *mm)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 41cefdf..950813b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -23,6 +23,25 @@
 static struct srcu_struct srcu;
=20
 /*
+ * This function allows mmu_notifier::release callback to delay a call t=
o
+ * a function that will free appropriate resources. The function must be
+ * quick and must not block.
+ */
+void mmu_notifier_call_srcu(struct rcu_head *rcu,
+			    void (*func)(struct rcu_head *rcu))
+{
+	call_srcu(&srcu, rcu, func);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
+
+void mmu_notifier_synchronize(void)
+{
+	/* Wait for any running method to finish. */
+	srcu_barrier(&srcu);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
+
+/*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
  * runs with mm_users =3D=3D 0. Other tasks may still invoke mmu notifie=
rs
@@ -53,7 +72,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-	srcu_read_unlock(&srcu, id);
=20
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -69,6 +87,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		hlist_del_init_rcu(&mn->hlist);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);
+	srcu_read_unlock(&srcu, id);
=20
 	/*
 	 * synchronize_srcu here prevents mmu_notifier_release from returning t=
o
@@ -325,6 +344,25 @@ void mmu_notifier_unregister(struct mmu_notifier *mn=
, struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
=20
+/*
+ * Same as mmu_notifier_unregister but no callback and no srcu synchroni=
zation.
+ */
+void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
+					struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	/*
+	 * Can not use list_del_rcu() since __mmu_notifier_release
+	 * can delete it before we hold the lock.
+	 */
+	hlist_del_init_rcu(&mn->hlist);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	BUG_ON(atomic_read(&mm->mm_count) <=3D 0);
+	mmdrop(mm);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
+
 static int __init mmu_notifier_init(void)
 {
 	return init_srcu_struct(&srcu);
--=20
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
