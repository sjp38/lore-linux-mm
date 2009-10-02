Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 88C6E6B005C
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 04:31:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n928fFwv023600
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Oct 2009 17:41:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF0E345DE6C
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:41:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B161E45DE6A
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:41:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C2A631DB8046
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:41:13 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E538E38003
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 17:41:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] cgroup: fix strstrip() abuse
In-Reply-To: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
References: <20091002173635.5F6C.A69D9226@jp.fujitsu.com>
Message-Id: <20091002173955.5F72.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  2 Oct 2009 17:41:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

cgroup_write_X64() and cgroup_write_string() ignore the return
value of strstrip().
it makes small inconsistent behavior.

example: 
=========================
 # cd /mnt/cgroup/hoge
 # cat memory.swappiness
 60
 # echo "59 " > memory.swappiness
 # cat memory.swappiness
 59
 # echo " 58" > memory.swappiness
 bash: echo: write error: Invalid argument


This patch fixes it.

Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 kernel/cgroup.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

Index: b/kernel/cgroup.c
===================================================================
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1710,14 +1710,13 @@ static ssize_t cgroup_write_X64(struct c
 		return -EFAULT;
 
 	buffer[nbytes] = 0;     /* nul-terminate */
-	strstrip(buffer);
 	if (cft->write_u64) {
-		u64 val = simple_strtoull(buffer, &end, 0);
+		u64 val = simple_strtoull(strstrip(buffer), &end, 0);
 		if (*end)
 			return -EINVAL;
 		retval = cft->write_u64(cgrp, cft, val);
 	} else {
-		s64 val = simple_strtoll(buffer, &end, 0);
+		s64 val = simple_strtoll(strstrip(buffer), &end, 0);
 		if (*end)
 			return -EINVAL;
 		retval = cft->write_s64(cgrp, cft, val);
@@ -1753,8 +1752,7 @@ static ssize_t cgroup_write_string(struc
 	}
 
 	buffer[nbytes] = 0;     /* nul-terminate */
-	strstrip(buffer);
-	retval = cft->write_string(cgrp, cft, buffer);
+	retval = cft->write_string(cgrp, cft, strstrip(buffer));
 	if (!retval)
 		retval = nbytes;
 out:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
