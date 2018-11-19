Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9B66B1CA7
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 16:54:35 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id w7-v6so24593239plp.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:54:35 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id o11si40652866pgd.234.2018.11.19.13.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 13:54:34 -0800 (PST)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v6 24/26] mm/mmap: Add Shadow stack pages to memory accounting
Date: Mon, 19 Nov 2018 13:48:07 -0800
Message-Id: <20181119214809.6086-25-yu-cheng.yu@intel.com>
In-Reply-To: <20181119214809.6086-1-yu-cheng.yu@intel.com>
References: <20181119214809.6086-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Add shadow stack pages to memory accounting.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/mmap.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/mmap.c b/mm/mmap.c
index 30836512ca79..9560d69fa08c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1701,6 +1701,9 @@ static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 	if (file && is_file_hugepages(file))
 		return 0;
 
+	if (arch_copy_pte_mapping(vm_flags))
+		return 1;
+
 	return (vm_flags & (VM_NORESERVE | VM_SHARED | VM_WRITE)) == VM_WRITE;
 }
 
@@ -3319,6 +3322,8 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->stack_vm += npages;
 	else if (is_data_mapping(flags))
 		mm->data_vm += npages;
+	else if (arch_copy_pte_mapping(flags))
+		mm->data_vm += npages;
 }
 
 static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
-- 
2.17.1
