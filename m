Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1706B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 15:28:25 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id c71so3538818ywa.11
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 12:28:25 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [167.114.142.138])
        by mx.google.com with ESMTPS id u9si5374606qkl.157.2018.04.12.12.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 12:28:24 -0700 (PDT)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: [RFC PATCH for 4.18 11/23] mm: Provide is_vma_noncached
Date: Thu, 12 Apr 2018 15:27:48 -0400
Message-Id: <20180412192800.15708-12-mathieu.desnoyers@efficios.com>
In-Reply-To: <20180412192800.15708-1-mathieu.desnoyers@efficios.com>
References: <20180412192800.15708-1-mathieu.desnoyers@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Boqun Feng <boqun.feng@gmail.com>, Andy Lutomirski <luto@amacapital.net>, Dave Watson <davejwatson@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Paul Turner <pjt@google.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Andrew Hunter <ahh@google.com>, Andi Kleen <andi@firstfloor.org>, Chris Lameter <cl@linux.com>, Ben Maurer <bmaurer@fb.com>, Steven Rostedt <rostedt@goodmis.org>, Josh Triplett <josh@joshtriplett.org>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-mm@kvack.org

Provide is_vma_noncached() static inline to allow generic code to
check whether the given vma consists of noncached memory.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
CC: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
CC: Peter Zijlstra <peterz@infradead.org>
CC: Paul Turner <pjt@google.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Andrew Hunter <ahh@google.com>
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
index ad06d42adb1a..1f93a061a43b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2425,6 +2425,30 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
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
