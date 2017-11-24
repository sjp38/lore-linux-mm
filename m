Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 213616B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 01:35:19 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w73so65318wmw.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 22:35:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10sor2756207wml.0.2017.11.23.22.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 22:35:17 -0800 (PST)
Date: Fri, 24 Nov 2017 07:35:14 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
Message-ID: <20171124063514.36xlqnh5seszy4nu@gmail.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <c55957c0-cf1a-eb8d-c37a-c2b69ada2312@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c55957c0-cf1a-eb8d-c37a-c2b69ada2312@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> I've updated these a bit since yesterday with some minor fixes:
>  * Fixed KASLR compile bug
>  * Fixed ds.c compile problem
>  * Changed ulong to pteval_t to fix 32-bit compile problem
>  * Stop mapping cpu_current_top_of_stack (never used until after CR3 switch)
> 
> Rather than re-spamming everyone, the resulting branch is here:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/daveh/x86-kaiser.git/log/?h=kaiser-414-tipwip-20171123
> 
> If anyone wants to be re-spammed, just say the word.

So the pteval_t changes break the build on most non-x86 architectures (alpha, arm, 
arm64, etc.), because most of them don't have an asm/pgtable_types.h file.

pteval_t is an x86-ism.

So I left out the changes below.

Thanks,

	Ingo

diff --git a/arch/x86/include/asm/kaiser.h b/arch/x86/include/asm/kaiser.h
index 35f12a8a7071..2198855f7de9 100644
--- a/arch/x86/include/asm/kaiser.h
+++ b/arch/x86/include/asm/kaiser.h
@@ -18,6 +18,8 @@
 #ifndef __ASSEMBLY__
 
 #ifdef CONFIG_KAISER
+#include <asm/pgtable_types.h>
+
 /**
  *  kaiser_add_mapping - map a kernel range into the user page tables
  *  @addr: the start address of the range
@@ -31,7 +33,7 @@
  *  table.
  */
 extern int kaiser_add_mapping(unsigned long addr, unsigned long size,
-			      unsigned long flags);
+			      pteval_t flags);
 
 /**
  *  kaiser_add_mapping_cpu_entry - map the cpu entry area
diff --git a/arch/x86/mm/kaiser.c b/arch/x86/mm/kaiser.c
index 1eb27b410556..58cae2924724 100644
--- a/arch/x86/mm/kaiser.c
+++ b/arch/x86/mm/kaiser.c
@@ -431,7 +431,7 @@ void __init kaiser_init(void)
 }
 
 int kaiser_add_mapping(unsigned long addr, unsigned long size,
-		       unsigned long flags)
+		       pteval_t flags)
 {
 	return kaiser_add_user_map((const void *)addr, size, flags);
 }
diff --git a/include/linux/kaiser.h b/include/linux/kaiser.h
index 83d465599646..f662013515a1 100644
--- a/include/linux/kaiser.h
+++ b/include/linux/kaiser.h
@@ -4,7 +4,11 @@
 #ifdef CONFIG_KAISER
 #include <asm/kaiser.h>
 #else
+
 #ifndef __ASSEMBLY__
+
+#include <asm/pgtable_types.h>
+
 /*
  * These stubs are used whenever CONFIG_KAISER is off, which
  * includes architectures that support KAISER, but have it
@@ -20,7 +24,7 @@ static inline void kaiser_remove_mapping(unsigned long start, unsigned long size
 }
 
 static inline int kaiser_add_mapping(unsigned long addr, unsigned long size,
-				     unsigned long flags)
+				     pteval_t flags)
 {
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
