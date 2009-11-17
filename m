Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 89DEF6B0062
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:17:13 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH7HBhD012643
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 16:17:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A41D45DE52
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E3E145DE3E
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 09FE71DB803F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:11 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AE0DC1DB8040
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 16:17:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/7] dm: use __GFP_HIGH instead PF_MEMALLOC
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-Id: <20091117161616.3DD7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 16:17:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Alasdair G Kergon <agk@redhat.com>, dm-devel@redhat.com
List-ID: <linux-mm.kvack.org>

Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
memory, anyone must not prevent it. Otherwise the system cause
mysterious hang-up and/or OOM Killer invokation.

Cc: Alasdair G Kergon <agk@redhat.com>
Cc: dm-devel@redhat.com
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/md/dm-ioctl.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
index a679429..4d24b0a 100644
--- a/drivers/md/dm-ioctl.c
+++ b/drivers/md/dm-ioctl.c
@@ -1396,7 +1396,13 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl **param)
 	if (tmp.data_size < (sizeof(tmp) - sizeof(tmp.data)))
 		return -EINVAL;
 
-	dmi = vmalloc(tmp.data_size);
+
+	/*
+	 * We use __vmalloc(__GFP_HIGH) instead vmalloc() because trying to
+	 * avoid low memory issues when a device is suspended.
+	 */
+	dmi = __vmalloc(tmp.data_size, GFP_KERNEL | __GFP_HIGHMEM | __GFP_HIGH,
+			PAGE_KERNEL);
 	if (!dmi)
 		return -ENOMEM;
 
@@ -1473,20 +1479,10 @@ static int ctl_ioctl(uint command, struct dm_ioctl __user *user)
 		DMWARN("dm_ctl_ioctl: unknown command 0x%x", command);
 		return -ENOTTY;
 	}
-
-	/*
-	 * Trying to avoid low memory issues when a device is
-	 * suspended.
-	 */
-	current->flags |= PF_MEMALLOC;
-
 	/*
 	 * Copy the parameters into kernel space.
 	 */
 	r = copy_params(user, &param);
-
-	current->flags &= ~PF_MEMALLOC;
-
 	if (r)
 		return r;
 
-- 
1.6.2.5



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
