Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E53B76B025E
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:53:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p11-v6so2687123wrd.20
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:53:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e127sor213337wmg.5.2018.04.18.11.53.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 11:53:25 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 4/6] mm, arm64: untag user addresses in mm/gup.c
Date: Wed, 18 Apr 2018 20:53:13 +0200
Message-Id: <0db34d04fa16be162336106e3b4a94f3dacc0af4.1524077494.git.andreyknvl@google.com>
In-Reply-To: <cover.1524077494.git.andreyknvl@google.com>
References: <cover.1524077494.git.andreyknvl@google.com>
In-Reply-To: <cover.1524077494.git.andreyknvl@google.com>
References: <cover.1524077494.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

mm/gup.c provides a kernel interface that accepts user addresses and
manipulates user pages directly (for example get_user_pages, that is used
by the futex syscall). Here we also need to handle the case of tagged user
pointers.

Untag addresses passed to this interface.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/gup.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index 76af4cfeaf68..fb375de7d40d 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -386,6 +386,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
+	address = untagged_addr(address);
+
 	*page_mask = 0;
 
 	/* make this handle hugepd */
@@ -647,6 +649,8 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	if (!nr_pages)
 		return 0;
 
+	start = untagged_addr(start);
+
 	VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));
 
 	/*
@@ -801,6 +805,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 	struct vm_area_struct *vma;
 	int ret, major = 0;
 
+	address = untagged_addr(address);
+
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 
@@ -854,6 +860,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 	long ret, pages_done;
 	bool lock_dropped;
 
+	start = untagged_addr(start);
+
 	if (locked) {
 		/* if VM_FAULT_RETRY can be returned, vmas become invalid */
 		BUG_ON(vmas);
@@ -1751,6 +1759,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long flags;
 	int nr = 0;
 
+	start = untagged_addr(start);
+
 	start &= PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
@@ -1803,6 +1813,8 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
+	start = untagged_addr(start);
+
 	start &= PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
-- 
2.17.0.484.g0c8726318c-goog
