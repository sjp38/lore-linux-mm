Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id A68EE6B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 02:53:27 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so104727808wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 23:53:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z132si2867510wme.43.2016.02.01.23.53.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 23:53:26 -0800 (PST)
Message-ID: <1454399605.11183.8.camel@suse.de>
Subject: [PATCH 3/2] mm, vmstat: cancel pending work of the cpu_stat_off CPU
From: Mike Galbraith <mgalbraith@suse.de>
Date: Tue, 02 Feb 2016 08:53:25 +0100
In-Reply-To: <1454001466-27398-2-git-send-email-mhocko@kernel.org>
References: <1454001466-27398-1-git-send-email-mhocko@kernel.org>
	 <1454001466-27398-2-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, Mike Galbraith <mgalbraith@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Cancel pending work of the cpu_stat_off CPU.

Signed-off-by: Mike Galbraith <mgalbraith@suse.de>
---
 mm/vmstat.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1486,25 +1486,25 @@ static void vmstat_shepherd(struct work_
 
 	get_online_cpus();
 	/* Check processors whose vmstat worker threads have been disabled */
-	for_each_cpu(cpu, cpu_stat_off)
+	for_each_cpu(cpu, cpu_stat_off) {
+		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
+
 		if (need_update(cpu)) {
 			if (cpumask_test_and_clear_cpu(cpu, cpu_stat_off))
-				queue_delayed_work_on(cpu, vmstat_wq,
-					&per_cpu(vmstat_work, cpu), 0);
+				queue_delayed_work_on(cpu, vmstat_wq, dw, 0);
 		} else {
 			/*
 			 * Cancel the work if quiet_vmstat has put this
 			 * cpu on cpu_stat_off because the work item might
 			 * be still scheduled
 			 */
-			cancel_delayed_work(this_cpu_ptr(&vmstat_work));
+			cancel_delayed_work(dw);
 		}
-
+	}
 	put_online_cpus();
 
 	schedule_delayed_work(&shepherd,
 		round_jiffies_relative(sysctl_stat_interval));
-
 }
 
 static void __init start_shepherd_timer(void)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
