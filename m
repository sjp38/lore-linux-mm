Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83CA1C31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FEB720896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FEB720896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0C8A8E000A; Thu, 13 Jun 2019 19:30:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBBFC8E0002; Thu, 13 Jun 2019 19:30:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CABD68E000A; Thu, 13 Jun 2019 19:30:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA778E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:58 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p7so295417otk.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VnHuvyxfzlMLjuAluoP4Gqp8W0W7f3UstQ5jt5H3rp4=;
        b=N4vJuo+W5aGfS+1AUVk7j94QOg1MekGmPo8tbKENFeR2hOqRQyalI7bVg6bUu2FQXf
         cXmuUvrXjAJogY+2JpmQ3yD/CekH5Lg4eIncA12oOrwpoMm9TlOeGIvX1HwrnYcTv+GA
         Lw/dY/aZwHRYUJkSst5yFoCp0cS3AtkGdzeOcUhcP+xVsF2++02AUXOfi858TRd4XvI/
         xmKOixNDtO1lo6cQOB3T2aPe9KWHXbh5a6EbIeHxpPj+lWOwaY+syNb4vbxVFkL0V6+a
         A54NMoYrxmxxTmcAXglH2M90CRwvreLG8/yrQQYXYFJWcnNp9NVVvPC6J6rrMBVTfrXf
         ZW+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWnMkiSBYeewQ3kTIggmg9cH1aUgyqkEFhoh3xvIiQPKAjmW80H
	mROM7QN/ZUM/y8dHfUAUgSXKYfwXXAjXOpmSyWPQeoXst4T/jhnkS40iSLUFQ+OehFijECJyE60
	HlYVZV4eWbmWJkzA0EWSfiQW1rlQY2mI65KGhlUGfW4k5nHqQtpogn92PWzXIIRe5Cg==
X-Received: by 2002:a05:6830:1042:: with SMTP id b2mr7445992otp.345.1560468658299;
        Thu, 13 Jun 2019 16:30:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKzR6T+705AEiORIF8Bst36lXgV5ec/q74g0gXAwsin37aHK6tMX699ez/JUWt7PwjkNtV
X-Received: by 2002:a05:6830:1042:: with SMTP id b2mr7445945otp.345.1560468657583;
        Thu, 13 Jun 2019 16:30:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468657; cv=none;
        d=google.com; s=arc-20160816;
        b=nbEm+iaj7kAvxYFgrWgLqhXSxQOadUwhxkMQy2+1ajFYFEaaKLjODFPboOFiOHK3HK
         rWfinBC3kbIWE5upPVvYu6pYqq/EdfWzfBuJ8iBpHlju645RGNJDWg/QYt13/BotDcwO
         d2hEZM8zUaGm/st6JVX3BlAyWfha3/MCY47Oxtw7kejD6L9boDSjyahzu/YT7gIlc5q1
         24yGlDMDItCPclCyyK1crdvEFwsmZ3ONR1Qj8HL0tJVZF5kMcDd4AheWcGxL1h9NPAA5
         AY+8Mp0GVIfZFUvioTFvWsNl1VHJxdw2VRechMSNSdQul4+8JWE9VZ5q3Zr/sxEmlvkd
         IA5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VnHuvyxfzlMLjuAluoP4Gqp8W0W7f3UstQ5jt5H3rp4=;
        b=Y4g2fODcy1uCBHSCtpc0BKHMHdl4Ctaww+uXoI/+rZgXqjoQgXBIcEnznWkxvKH2bk
         curPbC93TSnk5dg4h6ICDb6+vGjaWtpJxPGc3+JbysPOVTjVHiFUy8RTDPl++9KbxZG6
         yboRB6H0NykowkiRKffUvTUTlRnzS/4flmkgDHIkqXvFg8Xy6Y2x4sxCxj/vdlo5b47g
         v+JoKo0BZh7EfWt+yNJPnSQQjf5aPiFnSKI4HiHn3UhSzyIg4+crxr1T8dAtwSqHIc6+
         x3UpoY+WSivLtBZTDCZ9atRYqHgPWFt3pFNiD+5vnyxv5BoqAHG2AWmaUosExgxF7InG
         qvlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id t62si501913oib.246.2019.06.13.16.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R601e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:30:00 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v3 PATCH 7/9] mm: vmscan: check if the demote target node is contended or not
Date: Fri, 14 Jun 2019 07:29:35 +0800
Message-Id: <1560468577-101178-8-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When demoting to the migration target node, the target node may have
memory pressure, then the memory pressure may cause migrate_pages()
fail.

If the failure is caused by memory pressure (i.e. returning -ENOMEM),
tag the node with PGDAT_CONTENDED.  The tag would be cleared once the
target node is balanced again.

Check if the target node is PGDAT_CONTENDED or not, if it is just skip
demotion.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/linux/mmzone.h |  3 +++
 mm/vmscan.c            | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 70394ca..d4e05c5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -573,6 +573,9 @@ enum pgdat_flags {
 					 * many pages under writeback
 					 */
 	PGDAT_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
+	PGDAT_CONTENDED,		/* the node has not enough free memory
+					 * available
+					 */
 };
 
 enum zone_flags {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fb931ded..9ec55d7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1126,6 +1126,21 @@ static inline struct page *alloc_demote_page(struct page *page,
 }
 #endif
 
+static inline bool is_migration_target_contended(int nid)
+{
+	int node;
+	nodemask_t used_mask;
+
+
+	nodes_clear(used_mask);
+	node = find_next_best_node(nid, &used_mask, true);
+
+	if (test_bit(PGDAT_CONTENDED, &NODE_DATA(node)->flags))
+		return true;
+
+	return false;
+}
+
 static inline bool is_demote_ok(int nid, struct scan_control *sc)
 {
 	/* Just do demotion with migrate mode of node reclaim */
@@ -1144,6 +1159,10 @@ static inline bool is_demote_ok(int nid, struct scan_control *sc)
 	if (!has_migration_target_node_online())
 		return false;
 
+	/* Check if the demote target node is contended or not */
+	if (is_migration_target_contended(nid))
+		return false;
+
 	return true;
 }
 
@@ -1564,6 +1583,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		nr_reclaimed += nr_succeeded;
 
 		if (err) {
+			if (err == -ENOMEM)
+				set_bit(PGDAT_CONTENDED,
+					&NODE_DATA(target_nid)->flags);
+
 			putback_movable_pages(&demote_pages);
 
 			list_splice(&ret_pages, &demote_pages);
@@ -2597,6 +2620,19 @@ static void shrink_node_memcg(struct pglist_data *pgdat, struct mem_cgroup *memc
 		 * scan target and the percentage scanning already complete
 		 */
 		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
+
+		/*
+		 * The shrink_page_list() may find the demote target node is
+		 * contended, if so it doesn't make sense to scan anonymous
+		 * LRU again.
+		 *
+		 * Need check if swap is available or not too since demotion
+		 * may happen on swapless system.
+		 */
+		if (!is_demote_ok(pgdat->node_id, sc) &&
+		    (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0))
+			lru = LRU_FILE;
+
 		nr_scanned = targets[lru] - nr[lru];
 		nr[lru] = targets[lru] * (100 - percentage) / 100;
 		nr[lru] -= min(nr[lru], nr_scanned);
@@ -3447,6 +3483,7 @@ static void clear_pgdat_congested(pg_data_t *pgdat)
 	clear_bit(PGDAT_CONGESTED, &pgdat->flags);
 	clear_bit(PGDAT_DIRTY, &pgdat->flags);
 	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
+	clear_bit(PGDAT_CONTENDED, &pgdat->flags);
 }
 
 /*
-- 
1.8.3.1

