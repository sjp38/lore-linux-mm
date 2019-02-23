Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5EA3C10F00
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 01:28:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FF47206B7
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 01:28:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FF47206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA178E0148; Fri, 22 Feb 2019 20:28:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A57DF8E0141; Fri, 22 Feb 2019 20:28:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96E498E0148; Fri, 22 Feb 2019 20:28:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68CFB8E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 20:28:17 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id x8so1884586otg.17
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:28:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=BgIk3kk2fH4m54afkdSd6UKoT9ZAFv1N+yZ5Zx2y0PA=;
        b=d/SZkvMHa5a8aFPkWHONCATlBFujJven/K+urPecxoZP750yxv4WK6CTQAsQJ020v/
         gWiU+6PYGVrZcNrmgVMB3BCPOAmkUlNFQTi4+EB6NEZs9Lmfs8gTB0rF7BMtxmkql9oK
         gfxWIlP6D27Un1ceBZ4gVxi69Y//z5kcNvZTMiTF3DxiB6oWMPvzpCOz3/fIxim/86W/
         vBi6M06f8JdiGYgzwaMrevAGE/Y+qk8cny7llWHLX48HivxNtwg1NJb+Wrr04h0VI9JD
         ifMYUZZjebU4VLAW9+UfBh+16rJgnGSkQ9nI3ss4metVLhDPuwNGn/o93QbhjqiQf7jq
         Y6fQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
X-Gm-Message-State: AHQUAubr0vtzvPVim1i3OSI910KDmZf8DJ5GyfRuvs1WDK/KGNA4XDPj
	00YQg4ge4MWMduocdccfqoR6jD5E8vqyZqNvpehK64hUO2aQJptQkHIcrb3Ti5tgLmVPGqsnsld
	kFqgkelrye1PWKLNy/z9c3T1Y1yfGKD3VvMQCY9SXI/q1/EzivwUBxcSCcQYlu/PPSQ==
X-Received: by 2002:a05:6830:1092:: with SMTP id y18mr4589881oto.125.1550885297047;
        Fri, 22 Feb 2019 17:28:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZW3OjsaGR341HRHZwRbWOanrzFFJH237o2pN2s4P4RAznhqRGFK6IJjLO+WpJuOJJFdb7R
X-Received: by 2002:a05:6830:1092:: with SMTP id y18mr4589849oto.125.1550885295995;
        Fri, 22 Feb 2019 17:28:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550885295; cv=none;
        d=google.com; s=arc-20160816;
        b=f4prVRco+fIMAYi6zCS9EUT+N4tNtJLyQcuOy+8qKJ4IebVl2/pjDmptZYUEdDh9kh
         zDSXNd8+ZHpMlMXMqVS1CmpssnQwu+COUy3wu5BvBBxrjlZs6hM5oRC0Vze7CPNCEz1I
         KX87kUPL9pVhe+aR0CEtXNGEUVmEy7SQmwcluqKJnDoEmaO+YVjKRCCPcM/s8qZ/w9r0
         s5pCaZbTRDfOetyUfaZMKSkQ2NvGXgeyHAB+0xXKMnoQ9pJ/Liis76wTKSamWng86SzY
         rvAVeNnToFbX/OmZHQGht0kjkmqPu+PlaJo8lEjTUBqB5SLT0nvp1Oaog/yAwwQhvlXh
         960A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=BgIk3kk2fH4m54afkdSd6UKoT9ZAFv1N+yZ5Zx2y0PA=;
        b=U06pBbRekJPS9On+DTeE8UDyDGM3U1LlZzzgwhklJdii49MkrKNBAz8QmtLLh8HBxq
         XdZqpD+mPq9DPzIg/ORSIwO7M5PHnrJMaWgbnCRroJUVwD7Df1I+vSxRoK/W6cZjT/7H
         kpkFiaD9cm4zynUtEPXnt+j/eCld1AYvL6YEZlxC9IEtc/8txotEewkkyiGXOvVPPSpT
         B0KHu5uru3+ukO1NEiesdaZDr+WlaHYbKko2Cu7x8S6XBpcUyYcywPtFMJUROPEAXmaD
         /LO/H7RClSz/lIB4n/n8f9KSIitrVs/1PCZBY0TIHVbXePew6unw2SCNZp4yVi1msA+2
         e4mg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id s185si1223751oia.274.2019.02.22.17.28.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 17:28:15 -0800 (PST)
Received-SPF: pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) client-ip=45.249.212.191;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jingxiangfeng@huawei.com designates 45.249.212.191 as permitted sender) smtp.mailfrom=jingxiangfeng@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 65643B54346CD7FBC138;
	Sat, 23 Feb 2019 09:28:12 +0800 (CST)
Received: from RH5885H-V3.huawei.com (10.90.53.225) by
 DGGEMS411-HUB.china.huawei.com (10.3.19.211) with Microsoft SMTP Server id
 14.3.408.0; Sat, 23 Feb 2019 09:28:04 +0800
From: Jing Xiangfeng <jingxiangfeng@huawei.com>
To: <mike.kravetz@oracle.com>, <mhocko@kernel.org>
CC: <akpm@linux-foundation.org>, <hughd@google.com>, <linux-mm@kvack.org>,
	<n-horiguchi@ah.jp.nec.com>, <aarcange@redhat.com>,
	<kirill.shutemov@linux.intel.com>, <linux-kernel@vger.kernel.org>, "Jing
 Xiangfeng" <jingxiangfeng@huawei.com>
Subject: [PATCH v4] mm/hugetlb: Fix unsigned overflow in  __nr_hugepages_store_common()
Date: Sat, 23 Feb 2019 09:32:09 +0800
Message-ID: <1550885529-125561-1-git-send-email-jingxiangfeng@huawei.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.90.53.225]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

User can change a node specific hugetlb count. i.e.
/sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
the calculated value of count is a total number of huge pages. It could
be overflow when a user entering a crazy high value. If so, the total
number of huge pages could be a small value which is not user expect.
We can simply fix it by setting count to ULONG_MAX, then it goes on. This
may be more in line with user's intention of allocating as many huge pages
as possible.

Signed-off-by: Jing Xiangfeng <jingxiangfeng@huawei.com>
---
 mm/hugetlb.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef616..6688894 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2423,7 +2423,14 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 		 * per node hstate attribute: adjust count to global,
 		 * but restrict alloc/free to the specified node.
 		 */
+		unsigned long old_count = count;
 		count += h->nr_huge_pages - h->nr_huge_pages_node[nid];
+		/*
+		 * If user specified count causes overflow, set to
+		 * largest possible value.
+		 */
+		if (count < old_count)
+			count = ULONG_MAX;
 		init_nodemask_of_node(nodes_allowed, nid);
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
-- 
2.7.4

