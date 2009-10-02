Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 16FB16B0055
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 04:29:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n928druQ022683
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Oct 2009 17:39:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DB6345DE55
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:39:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD5B45DE51
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:39:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BDB11E78003
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:39:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C6918F8005
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:39:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/3] Fix strstrip() abuse in elv_iosched_store()
In-Reply-To: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
References: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
Message-Id: <20091002173803.5F6F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  2 Oct 2009 17:39:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>


elv_iosched_store() ignore the return value of strstrip().
it makes small inconsistent behavior.

This patch fixes it.


 <before>
 ====================================
 # cd /sys/block/{blockdev}/queue

 case1:
 # echo "anticipatory" > scheduler
 # cat scheduler
 noop [anticipatory] deadline cfq

 case2:
 # echo "anticipatory " > scheduler
 # cat scheduler
 noop [anticipatory] deadline cfq

 case3:
 # echo " anticipatory" > scheduler
 bash: echo: write error: Invalid argument

 <after>
 ====================================
 # cd /sys/block/{blockdev}/queue

 case1:
 # echo "anticipatory" > scheduler
 # cat scheduler
 noop [anticipatory] deadline cfq

 case2:
 # echo "anticipatory " > scheduler
 # cat scheduler
 noop [anticipatory] deadline cfq

 case3:
 # echo " anticipatory" > scheduler
 noop [anticipatory] deadline cfq


Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Jens Axboe <jens.axboe@oracle.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 block/elevator.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: b/block/elevator.c
===================================================================
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -1059,9 +1059,7 @@ ssize_t elv_iosched_store(struct request
 		return count;
 
 	strlcpy(elevator_name, name, sizeof(elevator_name));
-	strstrip(elevator_name);
-
-	e = elevator_get(elevator_name);
+	e = elevator_get(strstrip(elevator_name));
 	if (!e) {
 		printk(KERN_ERR "elevator: type %s not found\n", elevator_name);
 		return -EINVAL;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
