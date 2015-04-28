Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9D46B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:50:50 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so103003384igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:50:49 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id h38si19721314ioi.92.2015.04.28.15.50.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:50:49 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so103003185igb.1
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:50:49 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:50:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch resend] android, lmk: avoid setting TIF_MEMDIE if process
 has already exited
In-Reply-To: <alpine.DEB.2.10.1504021558220.15536@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1504281550290.24802@chino.kir.corp.google.com>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org> <1427264236-17249-4-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com> <20150326110532.GB18560@cmpxchg.org> <alpine.DEB.2.10.1503261231440.9410@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1504021558220.15536@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-275516743-1430261448=:24802"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@driverdev.osuosl.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-275516743-1430261448=:24802
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

TIF_MEMDIE should not be set on a process if it does not have a valid 
->mm, and this is protected by task_lock().

If TIF_MEMDIE gets set after the mm has detached, and the process fails to 
exit, then the oom killer will defer forever waiting for it to exit.

Make sure that the mm is still valid before setting TIF_MEMDIE by way of 
mark_tsk_oom_victim().

Cc: "Arve HjA,nnevAJPYg" <arve@android.com>
Cc: Riley Andrews <riandrews@android.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/staging/android/lowmemorykiller.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -156,20 +156,27 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 			     p->pid, p->comm, oom_score_adj, tasksize);
 	}
 	if (selected) {
-		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
-			     selected->pid, selected->comm,
-			     selected_oom_score_adj, selected_tasksize);
-		lowmem_deathpending_timeout = jiffies + HZ;
+		task_lock(selected);
+		if (!selected->mm) {
+			/* Already exited, cannot do mark_tsk_oom_victim() */
+			task_unlock(selected);
+			goto out;
+		}
 		/*
 		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
 		 * infrastructure. There is no real reason why the selected
 		 * task should have access to the memory reserves.
 		 */
 		mark_tsk_oom_victim(selected);
+		task_unlock(selected);
+		lowmem_print(1, "send sigkill to %d (%s), adj %hd, size %d\n",
+			     selected->pid, selected->comm,
+			     selected_oom_score_adj, selected_tasksize);
+		lowmem_deathpending_timeout = jiffies + HZ;
 		send_sig(SIGKILL, selected, 0);
 		rem += selected_tasksize;
 	}
-
+out:
 	lowmem_print(4, "lowmem_scan %lu, %x, return %lu\n",
 		     sc->nr_to_scan, sc->gfp_mask, rem);
 	rcu_read_unlock();
--531381512-275516743-1430261448=:24802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
