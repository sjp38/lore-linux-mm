Date: Tue, 17 Jun 2008 12:33:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/2] memcg: res counter set limit
Message-Id: <20080617123319.51e1f09d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080617123144.ce5a74fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Helper function of res_counter for reducing usage in subsys(memcg).

Changelog xxx -> v5.
 - new file.

Background:
 In v3, I was asked to implement generic ones to res_counter.
 In v4. I was asked not to implement generic ones because memcg is only
 controller which can reduce usage by the kernel. Okay, maybe make sense.
 In this version, adds only necessary helpers to res_counter in 
 not-invasive manner.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/res_counter.h |    7 +++++++
 kernel/res_counter.c        |   24 ++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

Index: mm-2.6.26-rc5-mm3/include/linux/res_counter.h
===================================================================
--- mm-2.6.26-rc5-mm3.orig/include/linux/res_counter.h
+++ mm-2.6.26-rc5-mm3/include/linux/res_counter.h
@@ -136,6 +136,12 @@ static inline bool res_counter_check_und
 	return ret;
 }
 
+/*
+ * set new limit to the val. if usage > val, returns -EBUSY.
+ * returns 0 at success.
+ */
+int res_counter_set_limit(struct res_counter *cnt, unsigned long long limit);
+
 static inline void res_counter_reset_max(struct res_counter *cnt)
 {
 	unsigned long flags;
@@ -153,4 +159,5 @@ static inline void res_counter_reset_fai
 	cnt->failcnt = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
+
 #endif
Index: mm-2.6.26-rc5-mm3/kernel/res_counter.c
===================================================================
--- mm-2.6.26-rc5-mm3.orig/kernel/res_counter.c
+++ mm-2.6.26-rc5-mm3/kernel/res_counter.c
@@ -143,3 +143,27 @@ out_free:
 out:
 	return ret;
 }
+
+
+/**
+ * res_counter_set_limit - set limit of res_counter.
+ * @cnt: the res_counter
+ * @limit: the new limit
+ *
+ * Note that res_coutner_write() allows the same kind of operation.
+ * But this returns -EBUSY when new limit < usage. If you want strict control
+ * of limit, please use this.
+ */
+int res_counter_set_limit(struct res_counter *cnt, unsigned long long limit)
+{
+	unsigned long flags;
+	int ret = -EBUSY;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if (cnt->usage <= limit) {
+		cnt->limit = limit;
+		ret = 0;
+	}
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
