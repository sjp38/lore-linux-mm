Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 604E86B004F
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 06:51:31 -0500 (EST)
Received: by iacb35 with SMTP id b35so22152597iac.14
        for <linux-mm@kvack.org>; Mon, 26 Dec 2011 03:51:30 -0800 (PST)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] swapfile: swap_info_get: Check for swap_info[type] == NULL
Date: Mon, 26 Dec 2011 17:26:39 +0530
Message-Id: <1324900599-20804-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cesar Eduardo Barros <cesarb@cesarb.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric B Munson <emunson@mgebm.net>, Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

From: Kautuk Consul <consul.kautuk@gmail.com>

If the swapfile type encoded within entry.val is corrupted in
such a way that the swap_info[type] == NULL, then the code in
swap_info_get will cause a NULL pointer exception.

Assuming that the code in swap_info_get attempts to validate the
swapfile type by checking its range, another bad_nofile check would
be to check for check whether the swap_info[type] pointer is NULL.

Adding a NULL check for swap_info[type] to be reagrded as a "bad_nofile"
error scenario.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/swapfile.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index b1cd120..7bdbe91 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -483,6 +483,8 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
 	if (type >= nr_swapfiles)
 		goto bad_nofile;
 	p = swap_info[type];
+	if (!p)
+		goto bad_nofile;
 	if (!(p->flags & SWP_USED))
 		goto bad_device;
 	offset = swp_offset(entry);
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
