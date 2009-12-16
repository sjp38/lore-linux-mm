Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7495F6B0047
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:04:45 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG34gnM024517
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:04:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A1E9545DE4E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:04:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 784CD45DE4C
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:04:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F8EA1DB803A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:04:42 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C2031DB8038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:04:42 +0900 (JST)
Date: Wed, 16 Dec 2009 12:01:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 1/11] mm accessor for replacing mmap_sem
Message-Id: <20091216120134.0221457e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch implements mm accessor, functions for get/release mm->mmap_sem.
For doing some work related to mmap_sem (relaxing it or count events etc..),
bare access to mm->mmap_sem is the first obstacle.

This patch is for removing direct access to mm->mmap_sem.
(For debugging, renaming mm->mmap_sem is better. But considering bisection,
 this patch leave it as it is. The last patch of this series will rename it.)

Following patches will replace direct access to mmap_sem to use these
accessors.

Based on Christoph Lameter's original work.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_accessor.h |   68 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_types.h    |    3 +
 2 files changed, 71 insertions(+)

Index: mmotm-mm-accessor/include/linux/mm_accessor.h
===================================================================
--- /dev/null
+++ mmotm-mm-accessor/include/linux/mm_accessor.h
@@ -0,0 +1,68 @@
+#ifndef __LINUX_MM_ACCESSOR_H
+#define __LINUX_MM_ACCESSOR_H
+
+static inline void mm_read_lock(struct mm_struct *mm)
+{
+	down_read(&mm->mmap_sem);
+}
+
+static inline int mm_read_trylock(struct mm_struct *mm)
+{
+	return down_read_trylock(&mm->mmap_sem);
+}
+
+static inline void mm_read_unlock(struct mm_struct *mm)
+{
+	up_read(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock(struct mm_struct *mm)
+{
+	down_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_unlock(struct mm_struct *mm)
+{
+	up_write(&mm->mmap_sem);
+}
+
+static inline int mm_write_trylock(struct mm_struct *mm)
+{
+	return down_write_trylock(&mm->mmap_sem);
+}
+
+static inline int mm_is_locked(struct mm_struct *mm)
+{
+	return rwsem_is_locked(&mm->mmap_sem);
+}
+
+static inline void mm_write_to_read_lock(struct mm_struct *mm)
+{
+	downgrade_write(&mm->mmap_sem);
+}
+
+static inline void mm_write_lock_nested(struct mm_struct *mm, int x)
+{
+	down_write_nested(&mm->mmap_sem, x);
+}
+
+static inline void mm_lock_init(struct mm_struct *mm)
+{
+	init_rwsem(&mm->mmap_sem);
+}
+
+static inline void mm_lock_prefetch(struct mm_struct *mm)
+{
+	prefetchw(&mm->mmap_sem);
+}
+
+static inline void mm_nest_spin_lock(spinlock_t *s, struct mm_struct *mm)
+{
+	spin_lock_nest_lock(s, &mm->mmap_sem);
+}
+
+static inline void mm_read_might_lock(struct mm_struct *mm)
+{
+	might_lock_read(&mm->mmap_sem);
+}
+#endif
Index: mmotm-mm-accessor/include/linux/mm_types.h
===================================================================
--- mmotm-mm-accessor.orig/include/linux/mm_types.h
+++ mmotm-mm-accessor/include/linux/mm_types.h
@@ -292,4 +292,7 @@ struct mm_struct {
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
 #define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
 
+/* Functions for accessing mm_struct */
+#include <linux/mm_accessor.h>
+
 #endif /* _LINUX_MM_TYPES_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
