Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F02C6B0289
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e2-v6so3592695pgq.4
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:34 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:33 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 07/10] mm: Prevent mprotect from changing shadow stack
Date: Thu,  7 Jun 2018 07:38:04 -0700
Message-Id: <20180607143807.3611-8-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
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
2.15.1
