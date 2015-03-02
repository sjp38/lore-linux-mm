Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF75F6B0071
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:55:46 -0500 (EST)
Received: by wghl18 with SMTP id l18so33546012wgh.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:55:46 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m9si18516839wia.122.2015.03.02.05.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:55:37 -0800 (PST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 4/4] cxgb4: drop __GFP_NOFAIL allocation
Date: Mon,  2 Mar 2015 14:54:43 +0100
Message-Id: <1425304483-7987-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
References: <1425304483-7987-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Vipul Pandya <vipul@chelsio.com>, netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

set_filter_wr is requesting __GFP_NOFAIL allocation although it can
return ENOMEM without any problems obviously (t4_l2t_set_switching does
that already). So the non-failing requirement is too strong without any
obvious reason. Drop __GFP_NOFAIL and reorganize the code to have the
failure paths easier.

The same applies to _c4iw_write_mem_dma_aligned which uses __GFP_NOFAIL
and then checks the return value and returns -ENOMEM on failure. This
doesn't make any sense what so ever. Either the allocation cannot fail
or it can.

del_filter_wr seems to be safe as well because the filter entry is not
marked as pending and the return value is propagated up the stack up to
c4iw_destroy_listen.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 drivers/infiniband/hw/cxgb4/mem.c               |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/mem.c b/drivers/infiniband/hw/cxgb4/mem.c
index cb43c2299ac0..81b028eaf1f5 100644
--- a/drivers/infiniband/hw/cxgb4/mem.c
+++ b/drivers/infiniband/hw/cxgb4/mem.c
@@ -73,7 +73,7 @@ static int _c4iw_write_mem_dma_aligned(struct c4iw_rdev *rdev, u32 addr,
 		c4iw_init_wr_wait(&wr_wait);
 	wr_len = roundup(sizeof(*req) + sizeof(*sgl), 16);
 
-	skb = alloc_skb(wr_len, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(wr_len, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index ccf3436024bc..f351920fc293 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1220,6 +1220,10 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
 	struct fw_filter_wr *fwr;
 	unsigned int ftid;
 
+	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
 	/* If the new filter requires loopback Destination MAC and/or VLAN
 	 * rewriting then we need to allocate a Layer 2 Table (L2T) entry for
 	 * the filter.
@@ -1227,19 +1231,21 @@ static int set_filter_wr(struct adapter *adapter, int fidx)
 	if (f->fs.newdmac || f->fs.newvlan) {
 		/* allocate L2T entry for new filter */
 		f->l2t = t4_l2t_alloc_switching(adapter->l2t);
-		if (f->l2t == NULL)
+		if (f->l2t == NULL) {
+			kfree(skb);
 			return -EAGAIN;
+		}
 		if (t4_l2t_set_switching(adapter, f->l2t, f->fs.vlan,
 					f->fs.eport, f->fs.dmac)) {
 			cxgb4_l2t_release(f->l2t);
 			f->l2t = NULL;
+			kfree(skb);
 			return -ENOMEM;
 		}
 	}
 
 	ftid = adapter->tids.ftid_base + fidx;
 
-	skb = alloc_skb(sizeof(*fwr), GFP_KERNEL | __GFP_NOFAIL);
 	fwr = (struct fw_filter_wr *)__skb_put(skb, sizeof(*fwr));
 	memset(fwr, 0, sizeof(*fwr));
 
@@ -1337,7 +1343,10 @@ static int del_filter_wr(struct adapter *adapter, int fidx)
 	len = sizeof(*fwr);
 	ftid = adapter->tids.ftid_base + fidx;
 
-	skb = alloc_skb(len, GFP_KERNEL | __GFP_NOFAIL);
+	skb = alloc_skb(len, GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
 	fwr = (struct fw_filter_wr *)__skb_put(skb, len);
 	t4_mk_filtdelwr(ftid, fwr, adapter->sge.fw_evtq.abs_id);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
