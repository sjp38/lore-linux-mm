Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6DA486B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:42:05 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so520023pdj.8
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:42:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id by1si2733054pbc.250.2014.05.20.10.42.04
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 10:42:04 -0700 (PDT)
Message-Id: <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
In-Reply-To: <cover.1400607328.git.tony.luck@intel.com>
References: <cover.1400607328.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 20 May 2014 09:28:00 -0700
Subject: [PATCH 1/2] memory-failure: Send right signal code to correct thread
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

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
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 35ef28acf137..642c8434b166 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -204,9 +204,9 @@ static int kill_proc(struct task_struct *t, unsigned long addr, int trapno,
 #endif
 	si.si_addr_lsb = compound_order(compound_head(page)) + PAGE_SHIFT;
 
-	if ((flags & MF_ACTION_REQUIRED) && t == current) {
+	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
 		si.si_code = BUS_MCEERR_AR;
-		ret = force_sig_info(SIGBUS, &si, t);
+		ret = force_sig_info(SIGBUS, &si, current);
 	} else {
 		/*
 		 * Don't use force here, it's convenient if the signal
-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
