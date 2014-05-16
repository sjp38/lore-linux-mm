Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id C843B6B0037
	for <linux-mm@kvack.org>; Fri, 16 May 2014 02:41:29 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so2188205pbb.33
        for <linux-mm@kvack.org>; Thu, 15 May 2014 23:41:29 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id in10si7817056pac.127.2014.05.15.23.41.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 May 2014 23:41:28 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so2160463pab.1
        for <linux-mm@kvack.org>; Thu, 15 May 2014 23:41:28 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] HWPOISON: Clear a useless global variable in do_machine_check()
Date: Fri, 16 May 2014 14:39:29 +0800
Message-Id: <1400222369-4473-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ak@linux.intel.com
Cc: fengguang.wu@intel.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, Chen Yucong <slaoub@gmail.com>

This patch is just used to remove a useless global variable mce_entry
and relative operations in do_machine_check().

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 arch/x86/include/asm/mce.h       |    2 --
 arch/x86/kernel/cpu/mcheck/mce.c |    5 -----
 2 files changed, 7 deletions(-)

diff --git a/arch/x86/include/asm/mce.h b/arch/x86/include/asm/mce.h
index 6e4ce2d..958b90f 100644
--- a/arch/x86/include/asm/mce.h
+++ b/arch/x86/include/asm/mce.h
@@ -176,8 +176,6 @@ int mce_available(struct cpuinfo_x86 *c);
 DECLARE_PER_CPU(unsigned, mce_exception_count);
 DECLARE_PER_CPU(unsigned, mce_poll_count);
 
-extern atomic_t mce_entry;
-
 typedef DECLARE_BITMAP(mce_banks_t, MAX_NR_BANKS);
 DECLARE_PER_CPU(mce_banks_t, mce_poll_banks);
 
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 68317c8..8f520a1 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -60,8 +60,6 @@ static DEFINE_MUTEX(mce_chrdev_read_mutex);
 
 #define SPINUNIT 100	/* 100ns */
 
-atomic_t mce_entry;
-
 DEFINE_PER_CPU(unsigned, mce_exception_count);
 
 struct mce_bank *mce_banks __read_mostly;
@@ -1041,8 +1039,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 	DECLARE_BITMAP(valid_banks, MAX_NR_BANKS);
 	char *msg = "Unknown";
 
-	atomic_inc(&mce_entry);
-
 	this_cpu_inc(mce_exception_count);
 
 	if (!cfg->banks)
@@ -1172,7 +1168,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 		mce_report_event(regs);
 	mce_wrmsrl(MSR_IA32_MCG_STATUS, 0);
 out:
-	atomic_dec(&mce_entry);
 	sync_core();
 }
 EXPORT_SYMBOL_GPL(do_machine_check);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
