Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8F888E001C
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:10:26 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z18-v6so6712210pfe.19
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:10:26 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z3-v6si26822954pgh.557.2018.09.21.08.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:10:25 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 25/27] mm/mmap: Prevent Shadow Stack VMA merges
Date: Fri, 21 Sep 2018 08:03:49 -0700
Message-Id: <20180921150351.20898-26-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Function returns could unwind stacks beyond its allocated area.
We do not merge shadow stack areas.

This and VMA guards prevent shadow stack underflow.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mmap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index de2d0faa1c61..fa581ced3f56 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1123,6 +1123,12 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 	if (vm_flags & VM_SPECIAL)
 		return NULL;
 
+	/*
+	 * Do not merge shadow stack areas.
+	 */
+	if (vm_flags & VM_SHSTK)
+		return NULL;
+
 	if (prev)
 		next = prev->vm_next;
 	else
-- 
2.17.1
