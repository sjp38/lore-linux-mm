Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7590C31E53
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAA4B218A3
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 04:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAA4B218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FB708E0008; Mon, 17 Jun 2019 00:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ACDF8E0001; Mon, 17 Jun 2019 00:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4261E8E0008; Mon, 17 Jun 2019 00:38:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3C18E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:25 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j68so11092172ywj.4
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 21:38:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:mime-version
         :content-transfer-encoding:message-id;
        bh=viVbgou4JZPg2Gcg7ouiXK8ReUxwTUBO/gRr+NhOTr8=;
        b=NbSVZqaJpKWRS9eC0IMiyRFr51MTTDajEnbWQB4p3aBMawf1UwCr/gmAjyXNHsS3pe
         pO6lWE6xTTeWexk7DUxdq19PkvQDsVTIOmW37MA21YoIotOGkfXDfnrDBKdZPRv81FEs
         0HNUTNYVA6ryXdlS6uk8LbrwDBw2An79f1ga1eechZ6pzmXahWOw4FvgDHH5FPofy/3B
         YONfVpbrLoHIyuCBQsICDgzOX7qZVLEF4LZzOePKbSDtRJy7waIZYKZyXhftVXPSuhPS
         ICcRrhPbKzdCNeh2KQIKhJC0kybHabQ7P4zQn6U44Pakl29j8uyDzYKQUIZOQ4vhfKXC
         Fhdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVsodpL2nX1JzsVzrk6MdgsFL7UbauinmCWSfqcELR/XJHTgPvD
	j9B4W0b4YJaXj7dfISrhPM+mVdZkiPv60+cQwaMeV40FH9ReiI8U/aZkvpDBf+dBHUG+raVkPAP
	S6Hy9ohSLG9UWSzxSXrLkYcWnBp2CuadwbBE6KbYp1dnt6zW2gYcFFpDlT+TdlbatZw==
X-Received: by 2002:a25:4055:: with SMTP id n82mr50109105yba.351.1560746304811;
        Sun, 16 Jun 2019 21:38:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxclCXORI2bvRi+9KLbxw73ny+36ETUcOuUyrok7RHD9rBTBBLRx7bLb1nAxK87oMTFiWL
X-Received: by 2002:a25:4055:: with SMTP id n82mr50109093yba.351.1560746303962;
        Sun, 16 Jun 2019 21:38:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560746303; cv=none;
        d=google.com; s=arc-20160816;
        b=sWkYHvSbr4Gx2DERassPOg31HH6ipwAl6QBO374aJOyAgvNb6+EfUa4MuolCGsK370
         Sy2G5jKJf/bpC3dDZUbXw4EzTQ1EVn3D42fgN61aGLMtfVrgMPeLa9dcK9qV2LvwcWrT
         dAugeJciRuOg4lPHkoUV2kvwZgcz9eo00SRe3dhDGf7J1X0yooM+0Xg/TbK/zuqPXoL8
         XCiTYugFJ0/450vjcmSdjPDrGV56WZTap++XsNlhVwsizYj5qtO4YrZBkVq2Dic1AbBv
         u1EIz9/Q5k0hBrXKzQ8jZXeon2ZEnfIvSIo4j+5ch7AlNVsGGUylx+atuHjHv1w5vz4n
         2hmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:references
         :in-reply-to:date:subject:cc:to:from;
        bh=viVbgou4JZPg2Gcg7ouiXK8ReUxwTUBO/gRr+NhOTr8=;
        b=nDAzdniWhHstuogalWzAjfW8w9PnDe4zINw2vXEbFRwnwYoWQNr+ec0ojTRbHAbruT
         U7zFE8dxrEZfH6BL2EZEvlcSGcFD7mEltLXCkyDe8kFSD0zS5QYn5SVruDbvakJtlUOa
         PvCJEdwb+y5CkBuU6X3QHkWROMnTm+WxwV/txlln3ohEBlacz5Jwx0cHl6vCR1QplqGd
         224X4woWQ6st4gA8xpFVHdos/24yYd/w31h7BPaDUDqtMoY9YzV3gILGYAoCiEkF9DHL
         xsP3iN8KD2JATN1fAMcLQ11fWQEMDwnGGC2Iowea4R8oQP3ptsPlxiEJn5AA3Wv6+KgE
         Xn4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a64si3456389yba.91.2019.06.16.21.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jun 2019 21:38:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alastair@au1.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=alastair@au1.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5H4bdTp041309
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:23 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t62qyj12e-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:38:23 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Mon, 17 Jun 2019 05:38:21 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 17 Jun 2019 05:38:16 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5H4cFeg30474372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 04:38:15 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 79EEA4204C;
	Mon, 17 Jun 2019 04:38:15 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D698442041;
	Mon, 17 Jun 2019 04:38:14 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 17 Jun 2019 04:38:14 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 85D91A0208;
	Mon, 17 Jun 2019 14:38:13 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
        Qian Cai <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>,
        Mukesh Ojha <mojha@codeaurora.org>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 5/5] mm/hotplug: export try_online_node
Date: Mon, 17 Jun 2019 14:36:31 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190617043635.13201-1-alastair@au1.ibm.com>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061704-0016-0000-0000-00000289A7CE
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061704-0017-0000-0000-000032E6EEE3
Message-Id: <20190617043635.13201-6-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=778 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170042
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

If an external driver module supplies physical memory and needs to expose
the memory on a specific NUMA node, it needs to be able to call
try_online_node to allocate the data structures for the node.

The previous assertion that all callers want to online the node, and that
the provided memory address starts at 0 is no longer true, so these
parameters must alse be exposed.

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 include/linux/memory_hotplug.h |  4 ++--
 kernel/cpu.c                   |  2 +-
 mm/memory_hotplug.c            | 20 +++++++++++++++-----
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..9272e7955541 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -109,7 +109,7 @@ extern void __online_page_set_limits(struct page *page);
 extern void __online_page_increment_counters(struct page *page);
 extern void __online_page_free(struct page *page);
 
-extern int try_online_node(int nid);
+int try_online_node(int nid, u64 start, bool set_node_online);
 
 extern int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions);
@@ -274,7 +274,7 @@ static inline void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 }
 
-static inline int try_online_node(int nid)
+static inline int try_online_node(int nid, u64 start, bool set_node_online)
 {
 	return 0;
 }
diff --git a/kernel/cpu.c b/kernel/cpu.c
index 077fde6fb953..ffe5f7239a5c 100644
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1167,7 +1167,7 @@ static int do_cpu_up(unsigned int cpu, enum cpuhp_state target)
 		return -EINVAL;
 	}
 
-	err = try_online_node(cpu_to_node(cpu));
+	err = try_online_node(cpu_to_node(cpu), 0, true);
 	if (err)
 		return err;
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 382b3a0c9333..9c2784f89e60 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1004,7 +1004,7 @@ static void rollback_node_hotadd(int nid)
 
 
 /**
- * try_online_node - online a node if offlined
+ * __try_online_node - online a node if offlined
  * @nid: the node ID
  * @start: start addr of the node
  * @set_node_online: Whether we want to online the node
@@ -1039,18 +1039,28 @@ static int __try_online_node(int nid, u64 start, bool set_node_online)
 	return ret;
 }
 
-/*
- * Users of this function always want to online/register the node
+/**
+ * try_online_node - online a node if offlined
+ * @nid: the node ID
+ * @start: start addr of the node
+ * @set_node_online: Whether we want to online the node
+ * called by cpu_up() to online a node without onlined memory.
+ *
+ * Returns:
+ * 1 -> a new node has been allocated
+ * 0 -> the node is already online
+ * -ENOMEM -> the node could not be allocated
  */
-int try_online_node(int nid)
+int try_online_node(int nid, u64 start, bool set_node_online)
 {
 	int ret;
 
 	mem_hotplug_begin();
-	ret =  __try_online_node(nid, 0, true);
+	ret =  __try_online_node(nid, start, set_node_online);
 	mem_hotplug_done();
 	return ret;
 }
+EXPORT_SYMBOL_GPL(try_online_node);
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-- 
2.21.0

