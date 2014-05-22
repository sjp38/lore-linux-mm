Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD0E6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 20:32:26 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so1888536pdj.20
        for <linux-mm@kvack.org>; Wed, 21 May 2014 17:32:26 -0700 (PDT)
Received: from mail-pb0-x22a.google.com (mail-pb0-x22a.google.com [2607:f8b0:400e:c01::22a])
        by mx.google.com with ESMTPS id al9si8297161pbd.15.2014.05.21.17.32.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 May 2014 17:32:26 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so1937806pbc.1
        for <linux-mm@kvack.org>; Wed, 21 May 2014 17:32:25 -0700 (PDT)
Message-ID: <1400718740.32269.7.camel@cyc>
Subject: [PATCH v3] Distirbute the clear operation of mces_seen to Per-CPU
 rather than only monarch CPU
From: Chen Yucong <slaoub@gmail.com>
Date: Thu, 22 May 2014 08:32:20 +0800
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

mces_seen is a Per-CPU variable which should only be accessed by Per-CPU as possible. So the
clear operation of mces_seen should also be local to Per-CPU rather than monarch CPU.

Meanwhile, there is also a potential risk that mces_seen will not be be cleared if a timeout
occurs in mce_end for monarch CPU. As a result, the stale value of mces_seen will reappear
on the next mce.

Based on the above reasons, this patch distribute the clear operation of mces_seen to Per-CPU
rather than only monarch CPU.

* From v1
 * Add Reviewed-by: Andi Kleen
 * Put the clear operation of mces_seen before the MCG_STATUS write.

* From v2
 * Fix some misspelling in the patch message. 

Reviewed-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 arch/x86/kernel/cpu/mcheck/mce.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 68317c8..966a5f5 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -785,13 +785,6 @@ static void mce_reign(void)
 	 */
 	if (global_worst <= MCE_KEEP_SEVERITY && mca_cfg.tolerant < 3)
 		mce_panic("Machine check from unknown source", NULL, NULL);
-
-	/*
-	 * Now clear all the mces_seen so that they don't reappear on
-	 * the next mce.
-	 */
-	for_each_possible_cpu(cpu)
-		memset(&per_cpu(mces_seen, cpu), 0, sizeof(struct mce));
 }
 
 static atomic_t global_nwo;
@@ -1137,9 +1130,6 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 		}
 	}
 
-	/* mce_clear_state will clear *final, save locally for use later */
-	m = *final;
-
 	if (!no_way_out)
 		mce_clear_state(toclear);
 
@@ -1161,7 +1151,7 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 			mce_panic("Fatal machine check on current CPU", &m, msg);
 		if (worst == MCE_AR_SEVERITY) {
 			/* schedule action before return to userland */
-			mce_save_info(m.addr, m.mcgstatus & MCG_STATUS_RIPV);
+			mce_save_info(final->addr, final->mcgstatus & MCG_STATUS_RIPV);
 			set_thread_flag(TIF_MCE_NOTIFY);
 		} else if (kill_it) {
 			force_sig(SIGBUS, current);
@@ -1170,6 +1160,12 @@ void do_machine_check(struct pt_regs *regs, long error_code)
 
 	if (worst > 0)
 		mce_report_event(regs);
+
+	/*
+	 * Now clear the mces_seen of current CPU -*final - so that it does not
+	 * reappear on the next mce.
+	 */
+	memset(final, 0, sizeof(struct mce));
 	mce_wrmsrl(MSR_IA32_MCG_STATUS, 0);
 out:
 	atomic_dec(&mce_entry);
-- 
1.7.10.4




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
