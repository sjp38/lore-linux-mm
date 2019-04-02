Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5A5CC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 13:34:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7E0920883
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 13:34:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7E0920883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3610C6B0283; Tue,  2 Apr 2019 09:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30F5D6B0284; Tue,  2 Apr 2019 09:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FF8D6B0285; Tue,  2 Apr 2019 09:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA9CE6B0283
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 09:34:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id m31so5915067edm.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 06:34:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=RMLFIHHn6ZSoN0mvOloEDz0gW7wVGrtydCF6IfgZcKw=;
        b=r/XhRp6mHYydI65v/NLoX/Y4Q7/s+ch+1Tx8l+PKLKqZJITkLG/bTL6t4H53Ube1ff
         DpBzBZQG4nHt9Dy/C3hRFOG4zAkTpE3VyZTpoFkSCUA1tJHpS1csqIRrdF3PF3TxDUYi
         NwGh/QIie7Qb3wXB5BDlVJUVp+d/pKfih2aUuHkPCbh/y5aQ3P9dYkSY7VuDQ2mnwaZG
         sNNz+PV2p+ru3GfDcEcWmFnb63T/F1TRhMRquk6x0To8RfwfrRn4CuHntKVFbRM07Ff2
         pivGAFdO709loLGiv0bq/E3oucz6bgAPY7wgRwxq5r4t02IllKAeCMYhrgiq4hirMYoh
         GDnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW+bB622Sy6WnQAyh8M4XiHfjUNNqxMFL5e5oTHySwPzecV1rrk
	UtpNKtKgc8GofsJnDAnxEdqwsbCE5uxm7JBWwNy0i59fb4r0ydOuF+cQE2yrxPiF3kEyVnI+tg0
	u+8K845A6YXqMS5yX1EYK5ferp2bODpq10QSJRtSbiSPeWGxeGIMafzMykwwUO5efBQ==
X-Received: by 2002:a17:906:c2d0:: with SMTP id ch16mr26130982ejb.197.1554212075363;
        Tue, 02 Apr 2019 06:34:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCKEqzAdQW3k+vBXwy8j4mxAz3TS+qtq1h775i0KqZBah5zyqWmwKp2VKwU1p2scWWeUc7
X-Received: by 2002:a17:906:c2d0:: with SMTP id ch16mr26130912ejb.197.1554212074133;
        Tue, 02 Apr 2019 06:34:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554212074; cv=none;
        d=google.com; s=arc-20160816;
        b=l2fi3INO0Pv7moEWyp3+ojvYMNP/Zh2EYvO6X7LQqpjr0xFHPu35bZBEo157Qcq5ij
         cSu9YMn6TqRoM8SeHU+Bb0s/+MkaN3+u2KvYMROMcqCoNC5hwt9z5xc2KzoeNhQ5GerI
         eEqZTqtJzZNwst8OH7mihBoBTzz06L2B5rXuf+MPpTbE0sb0YzFCyh7cQ2uUT3c7UKmH
         UkPwBQh17aw8rB86iUfztwRsjBypXJgNW6edO1YAWzRENXSuTujPjV2PErd7iYqFecxk
         LITboWJ8yvHypWUtqyZAYV8xTKceDu5UrZsxmz1Xvrd3SoAXyo8DCyNSGxrs9kK88JeD
         /pOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=RMLFIHHn6ZSoN0mvOloEDz0gW7wVGrtydCF6IfgZcKw=;
        b=MnTmHjGxIQHT4MFhlJ/BxTSh0o4jO3/jdXHvDcZuUtVGqE/8kBV77vBB7W863DbHQy
         Na2lt1cfJ27FBfDvdG7NzDs2V/5p/p9O1jzjOuAjN5rBEZ4PJfsBgLJPFRRyb7geI56e
         owGRHBWRRnfzBzotOupTWmAOoI7UG014L/hd4cl1I6EmZYBQ9BjQYqEaj7kJrtjae+fM
         bc+vZqFmarssVg5sriewsF0XGolOG5TkZv/Wn7c9BjZnA7aizbwuObybbcQ/UNvnwA8m
         3pZR+g6vxmLiScp2OvYhBX/xqdTClLt/0AkrA6Wm69EX4S/iczFf1CsuTSkrFdfMJpgr
         iaHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id p1si362680ejd.73.2019.04.02.06.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 06:34:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Tue, 02 Apr 2019 15:34:33 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Tue, 02 Apr 2019 14:34:21 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mike.kravetz@oracle.com,
	n-horiguchi@ah.jp.nec.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
Date: Tue,  2 Apr 2019 15:34:15 +0200
Message-Id: <20190402133415.21983-1-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
first determining whether it should be allocated in the stack or dinamically
depending on NODES_SHIFT.
Right now, it goes the dynamic path whenever the nodemask_t is above 32
bytes.

Although we could bump it to a reasonable value, the largest a nodemask_t
can get is 128 bytes, so since __nr_hugepages_store_common is called from
a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.

This reduces some code churn and complexity.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/hugetlb.c | 36 +++++++++++-------------------------
 1 file changed, 11 insertions(+), 25 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index f79ae4e42159..9cb2f91af897 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2447,44 +2447,30 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 					   unsigned long count, size_t len)
 {
 	int err;
-	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
+	nodemask_t nodes_allowed, *n_mask;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
-		err = -EINVAL;
-		goto out;
-	}
+	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
+		return -EINVAL;
 
 	if (nid == NUMA_NO_NODE) {
 		/*
 		 * global hstate attribute
 		 */
 		if (!(obey_mempolicy &&
-				init_nodemask_of_mempolicy(nodes_allowed))) {
-			NODEMASK_FREE(nodes_allowed);
-			nodes_allowed = &node_states[N_MEMORY];
-		}
-	} else if (nodes_allowed) {
+				init_nodemask_of_mempolicy(&nodes_allowed)))
+			n_mask = &node_states[N_MEMORY];
+		else
+			n_mask = &nodes_allowed;
+	} else {
 		/*
 		 * Node specific request.  count adjustment happens in
 		 * set_max_huge_pages() after acquiring hugetlb_lock.
 		 */
-		init_nodemask_of_node(nodes_allowed, nid);
-	} else {
-		/*
-		 * Node specific request, but we could not allocate the few
-		 * words required for a node mask.  We are unlikely to hit
-		 * this condition.  Since we can not pass down the appropriate
-		 * node mask, just return ENOMEM.
-		 */
-		err = -ENOMEM;
-		goto out;
+		init_nodemask_of_node(&nodes_allowed, nid);
+		n_mask = &nodes_allowed;
 	}
 
-	err = set_max_huge_pages(h, count, nid, nodes_allowed);
-
-out:
-	if (nodes_allowed != &node_states[N_MEMORY])
-		NODEMASK_FREE(nodes_allowed);
+	err = set_max_huge_pages(h, count, nid, n_mask);
 
 	return err ? err : len;
 }
-- 
2.13.7

