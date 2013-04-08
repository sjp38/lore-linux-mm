Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 7613C6B0044
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 15:39:13 -0400 (EDT)
Date: Mon, 8 Apr 2013 12:39:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v8 2/3] mm: replace hardcoded 3% with
 admin_reserve_pages knob
Message-Id: <20130408123911.6f1101fd988bcc680eb37c46@linux-foundation.org>
In-Reply-To: <20130408190510.GB2321@localhost.localdomain>
References: <20130408190510.GB2321@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

On Mon, 8 Apr 2013 15:05:10 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:

> Add an admin_reserve_kbytes knob to allow admins to change the
> hardcoded memory reserve to something other than 3%, which
> may be multiple gigabytes on large memory systems. Only about
> 8MB is necessary to enable recovery in the default mode, and
> only a few hundred MB are required even when overcommit is
> disabled.

And the only change that v8 made was to revert earlier fixes, so I'll
skip this version as well.

--- a/include/linux/mm.h~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob-v8
+++ a/include/linux/mm.h
@@ -45,7 +45,6 @@ extern int sysctl_legacy_va_layout;
 #include <asm/processor.h>
 
 extern unsigned long sysctl_user_reserve_kbytes;
-extern unsigned long sysctl_admin_reserve_kbytes;
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
--- a/kernel/sysctl.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob-v8
+++ a/kernel/sysctl.c
@@ -97,6 +97,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_admin_reserve_kbytes;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
--- a/mm/mmap.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob-v8
+++ a/mm/mmap.c
@@ -168,7 +168,7 @@ int __vm_enough_memory(struct mm_struct
 		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
+			free -= sysctl_admin_reserve_kbytes  >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
--- a/mm/nommu.c~mm-replace-hardcoded-3%-with-admin_reserve_pages-knob-v8
+++ a/mm/nommu.c
@@ -1932,7 +1932,7 @@ int __vm_enough_memory(struct mm_struct
 		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
+			free -= sysctl_admin_reserve_kbytes  >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
