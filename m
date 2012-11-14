Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 24AA36B0081
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 04:15:22 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id i14so119685dad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 01:15:21 -0800 (PST)
Date: Wed, 14 Nov 2012 01:15:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/4] mm, oom: ensure sysrq+f always passes valid zonelist
Message-ID: <alpine.DEB.2.00.1211140111190.32125@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

With hotpluggable and memoryless nodes, it's possible that node 0 will
not be online, so use the first online node's zonelist rather than
hardcoding node 0 to pass a zonelist with all zones to the oom killer.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 drivers/tty/sysrq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -346,7 +346,8 @@ static struct sysrq_key_op sysrq_term_op = {
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0, NULL, true);
+	out_of_memory(node_zonelist(first_online_node, GFP_KERNEL), GFP_KERNEL,
+		      0, NULL, true);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
