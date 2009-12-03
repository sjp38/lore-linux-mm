Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 635356B003D
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 21:01:06 -0500 (EST)
Message-Id: <20091203020102.111394000@alcatraz.americas.sgi.com>
Date: Wed, 02 Dec 2009 20:00:52 -0600
From: Robin Holt <holt@sgi.com>
Subject: [patch 1/1] UV - XPC pass nasid instead of nid to gru_create_message_queue
References: <20091203020051.967217000@alcatraz.americas.sgi.com>
Content-Disposition: inline; filename=xpc_pass_nasid_to_gru_create_message_queue
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Currently, the UV xpc code is passing nid to the gru_create_message_queue
instead of nasid as it expects.


To: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

---

 drivers/misc/sgi-xp/xpc_uv.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)


Index: pv1000000/drivers/misc/sgi-xp/xpc_uv.c
===================================================================
--- pv1000000.orig/drivers/misc/sgi-xp/xpc_uv.c	2009-12-02 16:51:40.000000000 -0600
+++ pv1000000/drivers/misc/sgi-xp/xpc_uv.c	2009-12-02 16:58:31.000000000 -0600
@@ -206,6 +206,7 @@ xpc_create_gru_mq_uv(unsigned int mq_siz
 	enum xp_retval xp_ret;
 	int ret;
 	int nid;
+	int nasid;
 	int pg_order;
 	struct page *page;
 	struct xpc_gru_mq_uv *mq;
@@ -261,9 +262,11 @@ xpc_create_gru_mq_uv(unsigned int mq_siz
 		goto out_5;
 	}
 
+	nasid = UV_PNODE_TO_NASID(uv_cpu_to_pnode(cpu));
+
 	mmr_value = (struct uv_IO_APIC_route_entry *)&mq->mmr_value;
 	ret = gru_create_message_queue(mq->gru_mq_desc, mq->address, mq_size,
-				       nid, mmr_value->vector, mmr_value->dest);
+				     nasid, mmr_value->vector, mmr_value->dest);
 	if (ret != 0) {
 		dev_err(xpc_part, "gru_create_message_queue() returned "
 			"error=%d\n", ret);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
