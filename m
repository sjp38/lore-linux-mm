Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id 44E55828DF
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:17:59 -0500 (EST)
Received: by mail-lb0-f179.google.com with SMTP id bc4so27274190lbc.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:59 -0800 (PST)
Received: from mail-lf0-f67.google.com (mail-lf0-f67.google.com. [209.85.215.67])
        by mx.google.com with ESMTPS id te7si6005596lbb.166.2016.01.28.09.17.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 09:17:56 -0800 (PST)
Received: by mail-lf0-f67.google.com with SMTP id z62so2438214lfd.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 09:17:56 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] vmstat: make vmstat_update deferrable
Date: Thu, 28 Jan 2016 18:17:46 +0100
Message-Id: <1454001466-27398-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
References: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, Mike Galbraith <mgalbraith@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

0eb77e988032 ("vmstat: make vmstat_updater deferrable again and shut
down on idle") made vmstat_shepherd deferrable. vmstat_update itself
is still useing standard timer which might interrupt idle task. This
is possible because "mm, vmstat: make quiet_vmstat lighter" removed
cancel_delayed_work from the quiet_vmstat. Change vmstat_work to
use DEFERRABLE_WORK to prevent from pointless wakeups from the idle
context.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index eb30bf45bd55..69537d2be6f6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1512,7 +1512,7 @@ static void __init start_shepherd_timer(void)
 	int cpu;
 
 	for_each_possible_cpu(cpu)
-		INIT_DELAYED_WORK(per_cpu_ptr(&vmstat_work, cpu),
+		INIT_DEFERRABLE_WORK(per_cpu_ptr(&vmstat_work, cpu),
 			vmstat_update);
 
 	if (!alloc_cpumask_var(&cpu_stat_off, GFP_KERNEL))
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
