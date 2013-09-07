Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 8DE456B0033
	for <linux-mm@kvack.org>; Sat,  7 Sep 2013 01:59:43 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so4063861pbb.34
        for <linux-mm@kvack.org>; Fri, 06 Sep 2013 22:59:42 -0700 (PDT)
Date: Fri, 6 Sep 2013 22:59:16 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] vmpressure: fix divide-by-0 in vmpressure_work_fn
Message-ID: <alpine.LNX.2.00.1309062254470.11420@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hit divide-by-0 in vmpressure_work_fn(): checking vmpr->scanned before
taking the lock is not enough, we must check scanned afterwards too.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---

 mm/vmpressure.c |    3 +++
 1 file changed, 3 insertions(+)

--- 3.11/mm/vmpressure.c	2013-09-02 13:46:10.000000000 -0700
+++ linux/mm/vmpressure.c	2013-09-06 22:43:03.596003080 -0700
@@ -187,6 +187,9 @@ static void vmpressure_work_fn(struct wo
 	vmpr->reclaimed = 0;
 	spin_unlock(&vmpr->sr_lock);
 
+	if (!scanned)
+		return;
+
 	do {
 		if (vmpressure_event(vmpr, scanned, reclaimed))
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
