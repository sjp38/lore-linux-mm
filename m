Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B4AC282E2
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 517DB20833
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 01:44:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Lx4n3eeQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 517DB20833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B0A56B0006; Sat, 20 Apr 2019 21:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 960B86B0007; Sat, 20 Apr 2019 21:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DC526B0008; Sat, 20 Apr 2019 21:44:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 582CE6B0006
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 21:44:35 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id b1so8345677qtk.11
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 18:44:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=KNYiHrLaIyWG9Z/8JFZQ3PiWCe04q+IC0EmwvEm+ySMP4R/CjEKrDVBM7HNg4/8QUV
         TLn0pWE1gKS3knWVqcWC816vvX7ONk6NTPs2lhiBc85jkpXecLsgO8RFHqgD299VWi58
         tMTty6ZAF3hLnLzwgmMQ18L8mNJRqV37FgF3xuSJy8j38ZGzpZR2+6LwY09lMoNoBX/c
         tG+iZielFA1irwzQewE8Ow9RT6MFL3gvPqirn7wHzg5/kmI7te9OvxBl0kRZVapTqIVp
         QqOc4IdyL+bzQZHa8M6NNfOA1gfPcK5cXGd1chcbGP8H42dfhvWXJqq4cZ+ysO7pWDc2
         UHlA==
X-Gm-Message-State: APjAAAWFOGWUmGKbDwy0prnlRMfzl4OInoM83eGz4UNBrAxMm8nPJevO
	qW+GbQMcaiyKw2yXX0BV1BsFuK3U7ZvvkfZp1MN7cR/tvP320bfYtK7aKJyoj1JILdZXtmBLOaJ
	whED1WFZHiTXWUD0w0scN/OjRkbrKjegs9U4u936BkfKNnFAMnCzEnWw3MuLd49kGaw==
X-Received: by 2002:a0c:8738:: with SMTP id 53mr10151513qvh.210.1555811075147;
        Sat, 20 Apr 2019 18:44:35 -0700 (PDT)
X-Received: by 2002:a0c:8738:: with SMTP id 53mr10151481qvh.210.1555811074261;
        Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555811074; cv=none;
        d=google.com; s=arc-20160816;
        b=DFppvLYU6mgraWZp1Ua3d6H+d/zUObnCqau9azASFziOMKUZysHPdl/TSHKSezVdox
         EprWWErizQrhQX30XieuDbPL2l4y/2mzzXfNLxfkpe8KQJXS3B9zJXwa4ounbuH7GBsv
         5mOi7EUvC+ewFUCllrV+BRTZmgv3ip6M0icErotLkBpbVxk4Zmnib2X7K8fAiVf/LTMJ
         nG2M+8Ig6j1mL4F54hZwjQB+4FsbJvQz/d37N5puGbiVgvJSUKTpNLrfUmJrlBfnH/ro
         3/ZMgAYjuM8rKXu4Uox6aNcGf5bjfpmI0DPRgPGZ6eK+KSuFbbc+n5nX13DWAV+9FFBt
         IoOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=iFORQ5WVWEH/l33M49OZ6DTGHbUZmyB1/BragLy4VtBscvMKNkhL3+5PbtB1O4HcCh
         oqgDXnKdlaoMBR80T0TrH9nNDqumBK/urSGbeEOr23T3cICkTt22q+6vl7QWQ87lz4ZI
         yZPJK7ao/MOkGKFJGRs2Qmz+x4CteaoHnpvx5r59dEy+duvqAEIaPJBo9PHwNYNnfgBS
         Gq9LFijO5O4Rps8/rVzAP7WSoh8h28dxA+4Ic8t9wF83+SLdWf5moSbvuOO5L/qTkGmK
         F/ZzHO5VgEBQqfdwQ76yrf/0bGnrSAKYJqWILaQibXRXeje1p6ESzeKihaA/F7VzkTxs
         p/JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Lx4n3eeQ;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor7941451qvd.19.2019.04.20.18.44.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Lx4n3eeQ;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=Lx4n3eeQsd3DKBZFt1X+n0tHyvdxX9eMXlbGkCZXa5jPDl+R+bxvhnePCzuiVFH+jk
         di+Mp6Mfiv5tBZu3YjQsIuC9JNhQV5AoV/J9rAuT1n2Pzo9ukHrKDSQHkIHF92Mqzxql
         YvxHUk9CCjLHPwU2JfPC6Jb4K3eYzQaEOCweZDDMP3zNxsjvacM4Si4fbi0xJj8A+ZHM
         HRrrp8lKjP5UFpftK/lphzl+xQk7hG0nsmdRNOw9TAxyhOTDr3q5eE7aOoZRIevE2SJ1
         IyWD1DfUU79PI1VB99cVVKjDHJ6TbNTIQlFTSgKgHQNPdqcPC2df8BsTeVhpEsSjlzIL
         cz1g==
X-Google-Smtp-Source: APXvYqyGwfhqvlrszPLC8qN9m2XQDrZ+wKGZWzLF7GM7scRLtBDlMXL92I0fVQaBdczXZtyMg5jLVQ==
X-Received: by 2002:ad4:430c:: with SMTP id c12mr10017920qvs.109.1555811074063;
        Sat, 20 Apr 2019 18:44:34 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u1sm1385218qtj.50.2019.04.20.18.44.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 18:44:33 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com
Subject: [v2 1/2] device-dax: fix memory and resource leak if hotplug fails
Date: Sat, 20 Apr 2019 21:44:28 -0400
Message-Id: <20190421014429.31206-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190421014429.31206-1-pasha.tatashin@soleen.com>
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When add_memory() function fails, the resource and the memory should be
freed.

Fixes: c221c0b0308f ("device-dax: "Hotplug" persistent memory for use like normal RAM")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 drivers/dax/kmem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index a02318c6d28a..4c0131857133 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -66,8 +66,11 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->name = dev_name(dev);
 
 	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
-	if (rc)
+	if (rc) {
+		release_resource(new_res);
+		kfree(new_res);
 		return rc;
+	}
 
 	return 0;
 }
-- 
2.21.0

