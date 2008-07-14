Date: Mon, 14 Jul 2008 17:11:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2][-mm][resend] res_counter limit change support ebusy
Message-Id: <20080714171154.e1cc9943.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Add an interface to set limit. This is necessary to memory resource controller
because it shrinks usage at set limit.

(*) Other controller may not need this interface to shrink usage because
    shrinking is not necessary or impossible.

This is an enhancement.
named as res_counter-limit-change-ebusy.patch

Changelog:
  - fixed white space bug.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Acked-by: Pavel Emelyanov <xemul@openvz.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/res_counter.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: linux-2.6.26-rc8-mm1/include/linux/res_counter.h
===================================================================
--- linux-2.6.26-rc8-mm1.orig/include/linux/res_counter.h
+++ linux-2.6.26-rc8-mm1/include/linux/res_counter.h
@@ -176,4 +176,19 @@ static inline bool res_counter_can_add(s
 	return ret;
 }
 
+static inline int res_counter_set_limit(struct res_counter *cnt,
+	unsigned long long limit)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage < limit) {
+		cnt->limit = limit;
+		ret = 0;
+	}
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
