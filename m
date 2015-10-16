Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2767982F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 15:51:54 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so72662428obb.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 12:51:53 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0080.outbound.protection.outlook.com. [157.56.112.80])
        by mx.google.com with ESMTPS id t136si11183714oif.23.2015.10.16.12.51.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 16 Oct 2015 12:51:53 -0700 (PDT)
From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH] vmstat_update: ensure work remains on the same core
Date: Fri, 16 Oct 2015 15:51:33 -0400
Message-ID: <1445025093-32639-1-git-send-email-cmetcalf@ezchip.com>
In-Reply-To: <CA+55aFyzsMYcRX3V5CEWB4Zb-9BuRGCjib3DMXuX5y9nBWiZ1w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Chris Metcalf <cmetcalf@ezchip.com>

By using schedule_delayed_work(), we are preferring the local
core for the work, but not requiring it.  In my task
isolation experiments, I saw a nohz_full core's vmstat_update
end up running on a housekeeping core, and when the two works
ran back-to-back, we triggered the VM_BUG_ON() at the
end of the function.

Switch to using schedule_delayed_work_on(smp_processor_id(), ...).

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
This change that I made a few days ago in my local tree is
particularly amusing given that the thread I am appending this
email to ("workqueue fixes for v4.3-rc5") also fixes the symptoms
of the bug I saw, but I wasn't aware of it until just now.  And it
took a while for me to track it down!  I think this is probably a
"belt and suspenders" kind of issue where it makes sense to fix it
on both sides of the API, however.

 mm/vmstat.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index cf7d324f16e2..5c6bd7e5db07 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1369,7 +1369,8 @@ static void vmstat_update(struct work_struct *w)
 		 * to occur in the future. Keep on running the
 		 * update worker thread.
 		 */
-		schedule_delayed_work(this_cpu_ptr(&vmstat_work),
+		schedule_delayed_work_on(smp_processor_id(),
+			this_cpu_ptr(&vmstat_work),
 			round_jiffies_relative(sysctl_stat_interval));
 	else {
 		/*
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
