Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 831266B0269
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 05:59:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v184-v6so20333644qkh.23
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 02:59:34 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [2607:5300:60:7898::beef])
        by mx.google.com with ESMTPS id k18-v6si311183qtj.22.2018.11.01.02.59.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 02:59:33 -0700 (PDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: [RFC PATCH for 4.21 05/16] mm: Provide is_vma_noncached
Date: Thu,  1 Nov 2018 10:58:33 +0100
Message-Id: <20181101095844.24462-6-mathieu.desnoyers@efficios.com>
In-Reply-To: <20181101095844.24462-1-mathieu.desnoyers@efficios.com>
References: <20181101095844.24462-1-mathieu.desnoyers@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Boqun Feng <boqun.feng@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@amacapital.net>, Dave Watson <davejwatson@fb.com>, Paul Turner <pjt@google.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andi Kleen <andi@firstfloor.org>, Chris Lameter <cl@linux.com>, Ben Maurer <bmaurer@fb.com>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Joel Fernandes <joelaf@google.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Provide is_vma_noncached() static inline to allow generic code to
check whether the given vma consists of noncached memory.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
CC: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Paul Turner <pjt@google.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Andi Kleen <andi@firstfloor.org>
CC: Dave Watson <davejwatson@fb.com>
CC: Chris Lameter <cl@linux.com>
CC: Ingo Molnar <mingo@redhat.com>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Ben Maurer <bmaurer@fb.com>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Josh Triplett <josh@joshtriplett.org>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Russell King <linux@arm.linux.org.uk>
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
CC: Michael Kerrisk <mtk.manpages@gmail.com>
CC: Boqun Feng <boqun.feng@gmail.com>
CC: linux-mm@kvack.org
---
 include/linux/mm.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0416a7204be3..18acf4f339f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2551,6 +2551,30 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 	return follow_page_mask(vma, address, foll_flags, &unused_page_mask);
 }
 
+static inline bool pgprot_same(pgprot_t a, pgprot_t b)
+{
+	return pgprot_val(a) == pgprot_val(b);
+}
+
+#ifdef pgprot_noncached
+static inline bool is_vma_noncached(struct vm_area_struct *vma)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+
+	/* Check whether architecture implements noncached pages. */
+	if (pgprot_same(pgprot_noncached(PAGE_KERNEL), PAGE_KERNEL))
+		return false;
+	if (!pgprot_same(pgprot, pgprot_noncached(pgprot)))
+		return false;
+	return true;
+}
+#else
+static inline bool is_vma_noncached(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 #define FOLL_WRITE	0x01	/* check pte is writable */
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
-- 
2.11.0
