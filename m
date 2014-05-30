Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id A663B6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 02:51:58 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id q58so1532892wes.11
        for <linux-mm@kvack.org>; Thu, 29 May 2014 23:51:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id yn1si6357546wjc.33.2014.05.29.23.51.56
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 23:51:57 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/3] memory-failure: Send right signal code to correct thread
Date: Fri, 30 May 2014 02:51:08 -0400
Message-Id: <1401432670-24664-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
 <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Tony Luck <tony.luck@intel.com>

When a thread in a multi-threaded application hits a machine
check because of an uncorrectable error in memory - we want to
send the SIGBUS with si.si_code = BUS_MCEERR_AR to that thread.
Currently we fail to do that if the active thread is not the
primary thread in the process. collect_procs() just finds primary
threads and this test:
	if ((flags & MF_ACTION_REQUIRED) && t == current) {
will see that the thread we found isn't the current thread
and so send a si.si_code = BUS_MCEERR_AO to the primary
(and nothing to the active thread at this time).

We can fix this by checking whether "current" shares the same
mm with the process that collect_procs() said owned the page.
If so, we send the SIGBUS to current (with code BUS_MCEERR_AR).

Reported-by: Otto Bruggeman <otto.g.bruggeman@intel.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Borislav Petkov <bp@suse.de>
Cc: Chen Gong <gong.chen@linux.jf.intel.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git mmotm-2014-05-21-16-57.orig/mm/memory-failure.c mmotm-2014-05-21-16-57/mm/memory-failure.c
index e3154d99b87f..b73098ee91e6 100644
--- mmotm-2014-05-21-16-57.orig/mm/memory-failure.c
+++ mmotm-2014-05-21-16-57/mm/memory-failure.c
@@ -204,9 +204,9 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 #endif
 	si.si_addr_lsb = page_size_order(page) + PAGE_SHIFT;
 
-	if ((flags & MF_ACTION_REQUIRED) && t == current) {
+	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
 		si.si_code = BUS_MCEERR_AR;
-		ret = force_sig_info(SIGBUS, &si, t);
+		ret = force_sig_info(SIGBUS, &si, current);
 	} else {
 		/*
 		 * Don't use force here, it's convenient if the signal
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
