Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E73136B028F
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:41:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j25-v6so3547146pfi.9
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:41:36 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i74-v6si8716254pgc.188.2018.06.07.07.41.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:41:35 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 10/10] mm: Prevent munmap and remap_file_pages of shadow stack
Date: Thu,  7 Jun 2018 07:38:07 -0700
Message-Id: <20180607143807.3611-11-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143807.3611-1-yu-cheng.yu@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mmap.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index fc41c0543d7f..e7d1fcb7ec58 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2810,6 +2810,16 @@ EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	struct vm_area_struct *vma;
+
+	/* Do not munmap shadow stack */
+	down_read(&current->mm->mmap_sem);
+	vma = find_vma(current->mm, addr);
+	if (vma && (vma->vm_flags & VM_SHSTK)) {
+		up_read(&current->mm->mmap_sem);
+		return -EINVAL;
+	}
+	up_read(&current->mm->mmap_sem);
 	profile_munmap(addr);
 	return vm_munmap(addr, len);
 }
@@ -2851,6 +2861,9 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	if (!vma || !(vma->vm_flags & VM_SHARED))
 		goto out;
 
+	if (vma->vm_flags & VM_SHSTK)
+		goto out;
+
 	if (start < vma->vm_start)
 		goto out;
 
-- 
2.15.1
