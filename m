Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4EA8E0019
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:10:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 191-v6so5738536pgb.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:10:26 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z3-v6si26822954pgh.557.2018.09.21.08.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:10:25 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 23/27] mm/map: Add Shadow stack pages to memory accounting
Date: Fri, 21 Sep 2018 08:03:47 -0700
Message-Id: <20180921150351.20898-24-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add shadow stack pages to memory accounting.
Also check if the system has enough memory before enabling CET.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu.intel.com>
---
 mm/mmap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 5f2b2b184c60..de2d0faa1c61 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1671,6 +1671,9 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	if (file && is_file_hugepages(file))
 		return 0;
 
+	if (arch_copy_pte_mapping(vm_flags))
+		return 1;
+
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
@@ -3261,6 +3264,8 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->stack_vm += npages;
 	else if (is_data_mapping(flags))
 		mm->data_vm += npages;
+	else if (arch_copy_pte_mapping(flags))
+		mm->data_vm += npages;
 }
 
 static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
-- 
2.17.1
