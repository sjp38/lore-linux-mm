Date: Wed, 2 Jul 2008 21:12:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm] [4/7] handle limit change
Message-Id: <20080702211210.af840889.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add an interface to set limit. This is necessary to memory resource controller
because it shrinks usage at set limit.

(*) Other controller may not need this interface to shrink usage because
    shrinking is not necessary or impossible under it.

Changelog:
  - fixed white space bug.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 include/linux/res_counter.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: test-2.6.26-rc5-mm3++/include/linux/res_counter.h
===================================================================
--- test-2.6.26-rc5-mm3++.orig/include/linux/res_counter.h
+++ test-2.6.26-rc5-mm3++/include/linux/res_counter.h
@@ -158,4 +158,19 @@ static inline void res_counter_reset_fai
 	cnt->failcnt = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
+
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
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
