Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0631E6B026B
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:31:16 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t10-v6so14866976pfh.0
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:31:15 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 31-v6si17386340plz.217.2018.07.10.15.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:14 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 15/27] mm/mprotect: Prevent mprotect from changing shadow stack
Date: Tue, 10 Jul 2018 15:26:27 -0700
Message-Id: <20180710222639.8241-16-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mprotect.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 625608bc8962..128dcb880c12 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -446,6 +446,15 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	error = -ENOMEM;
 	if (!vma)
 		goto out;
+
+	/*
+	 * Do not allow changing shadow stack memory.
+	 */
+	if (vma->vm_flags & VM_SHSTK) {
+		error = -EINVAL;
+		goto out;
+	}
+
 	prev = vma->vm_prev;
 	if (unlikely(grows & PROT_GROWSDOWN)) {
 		if (vma->vm_start >= end)
-- 
2.17.1
