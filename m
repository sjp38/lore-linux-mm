Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7667CC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:51:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F71B2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:51:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="QNLXQwnn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F71B2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CE968E012A; Fri, 12 Jul 2019 04:51:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A5708E00DB; Fri, 12 Jul 2019 04:51:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BB798E012A; Fri, 12 Jul 2019 04:51:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2808E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:51:46 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l9so6358893qtu.12
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:51:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=gIX56E206Ygtmlz0jOLcOvzHgmUrVjC3hqqjQDtHYu4=;
        b=onXQXQXvVc+aa7Fn+6zi8kIKssvFO4px40usASvU4dtk8iAFFHxEbUNr8EqHdOl9SY
         wvwFCNDNCrngiXvumDmNSo4I1di3G2y5AKcjp14pCgLZquKUSuNykQJ9OKBDlTfBf8ZE
         eBVrkE9ePwaydgkfqNTaO1vlOuhlyCKa3dv+fCsa40CRCAzHMipUJ3NTxDOMinlaZYtB
         Rdv72DfNaTpv5RvvpGVeEiglAALdp3sbsbr9vOrOxCnQj1iJHGrzYQuHcggQWXHPPyGt
         y16nA74XfsPD5Y2xGKVqfBXV+SkW4P2nr0MHzyOux2IlwVxl6NxL5u3bOFgU6wPQMdo0
         xtQg==
X-Gm-Message-State: APjAAAV12MtYHSQGQkCisbgf5uwP2PF8k4wQe4aKrPVMx0z53mA1M1aw
	H5Nc4MX7bX/EN78MXpFoa5YvgntzH7sZ9poK6CK+TRcogUmcgkMJA/IKckUPZCHVuJMB2dhHysN
	U3/WeO5NMIfEvKsXFzMJOH0zrEqwmNHEZnX4dh/rR0UVZ7ImFy3IoIoS0LDvWrwRD5Q==
X-Received: by 2002:ac8:7404:: with SMTP id p4mr5431387qtq.181.1562921506081;
        Fri, 12 Jul 2019 01:51:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLpnPU7tG+I2Qfa+zViE6a8RdYEVo0KYQvUSFcU8UsA1XCeSvzoluVYdUC06zpjR2SSBAf
X-Received: by 2002:ac8:7404:: with SMTP id p4mr5431374qtq.181.1562921505609;
        Fri, 12 Jul 2019 01:51:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562921505; cv=none;
        d=google.com; s=arc-20160816;
        b=wrxnZbTmdCLmeNO1rJPwHfT1CR2Ihf8TJsJszdHb3XvltOv3Hkiqo9LUuUKnK9Xu4i
         pYTaBjfv7jBh8nWEOPzHLpS5dHvbCGVWvImsUoQ5KQTFEHAYBfAQZwIJGlfLSIWaWwDL
         KQy4681ODi64FFfvy8c8QuYXvhwIJdaMns39bq/KzwBxwiSCKKb2B5nP6BFyuvHBsVhO
         zUFHPkXWxPpAcenFftTC+9bLih/UHpk3iTJJSpIvTjSUeAEM0sCUCltJUddmjAtOYC2H
         Cr01uA2u+mPSu0+oCV5ofYiNQLjzbTzStI6OhUAwyh9HAOMtbzu2oaaOIykgnduvkFRj
         dTig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=gIX56E206Ygtmlz0jOLcOvzHgmUrVjC3hqqjQDtHYu4=;
        b=LePjsSnw88w/REuX8MNy6uc7AVcRRkhWO68PxOCMAU+Pt4hi6Q1MWf2swksusQGXTN
         yd4pHo3uDvGuDZpAkz8YitsLWXb5T5NQg1BYJh3yhRU9t0SpMSTv2eFo6M0kSAypWImm
         WSPDWE8R15POKtUFg0Dp/wBn9DoBhK0A+Pc1banuvOoMI6uRVQ1XQc+SEa4GVpqFtzJG
         mnMm2pC0ZNGjOui6oQyo9YWZ+C+GgDLD/uB4EFGEgDFMshKLYPTiFRxtuwQjqqC/ypWF
         WJEsluQ4BS33bYfJR417MFdKRCJmkxo8CJuj5RjA6DOCi+q7d7eapGFEGMrfcgVqMm+m
         XVRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=QNLXQwnn;
       spf=pass (google.com: domain of prvs=089b491e4=karahmed@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=089b491e4=karahmed@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id o25si4532388qkk.39.2019.07.12.01.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 01:51:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=089b491e4=karahmed@amazon.com designates 207.171.184.29 as permitted sender) client-ip=207.171.184.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=QNLXQwnn;
       spf=pass (google.com: domain of prvs=089b491e4=karahmed@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=089b491e4=karahmed@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1562921505; x=1594457505;
  h=from:to:cc:subject:date:message-id;
  bh=gIX56E206Ygtmlz0jOLcOvzHgmUrVjC3hqqjQDtHYu4=;
  b=QNLXQwnnBQ/Uu5DrpfAyAnmd2gH6k1oFMuExj9cLVIcKpKRsT9kFvZYT
   pydDs+QpftBphSSpny/PTnImvKDMujNVefu+fjIJIO40enJs7CK8+deS8
   JnuwioAhqgR1bFtyZYoI5vnqhfw/A819W/AZunBNcS2CJaDcJh5/fOmz2
   E=;
X-IronPort-AV: E=Sophos;i="5.62,481,1554768000"; 
   d="scan'208";a="685113937"
Received: from sea3-co-svc-lb6-vlan2.sea.amazon.com (HELO email-inbound-relay-2b-859fe132.us-west-2.amazon.com) ([10.47.22.34])
  by smtp-border-fw-out-9102.sea19.amazon.com with ESMTP; 12 Jul 2019 08:51:43 +0000
Received: from u54e1ad5160425a4b64ea.ant.amazon.com (pdx2-ws-svc-lb17-vlan3.amazon.com [10.247.140.70])
	by email-inbound-relay-2b-859fe132.us-west-2.amazon.com (Postfix) with ESMTPS id 0FFBE222159;
	Fri, 12 Jul 2019 08:51:41 +0000 (UTC)
Received: from u54e1ad5160425a4b64ea.ant.amazon.com (localhost [127.0.0.1])
	by u54e1ad5160425a4b64ea.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x6C8pb32024010;
	Fri, 12 Jul 2019 10:51:38 +0200
Received: (from karahmed@localhost)
	by u54e1ad5160425a4b64ea.ant.amazon.com (8.15.2/8.15.2/Submit) id x6C8pZ4Q024001;
	Fri, 12 Jul 2019 10:51:35 +0200
From: KarimAllah Ahmed <karahmed@amazon.de>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: KarimAllah Ahmed <karahmed@amazon.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
        Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
        Logan Gunthorpe <logang@deltatee.com>
Subject: [PATCH] mm: sparse: Skip no-map regions in memblocks_present
Date: Fri, 12 Jul 2019 10:51:31 +0200
Message-Id: <1562921491-23899-1-git-send-email-karahmed@amazon.de>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000033, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Do not mark regions that are marked with nomap to be present, otherwise
these memblock cause unnecessarily allocation of metadata.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Baoquan He <bhe@redhat.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: KarimAllah Ahmed <karahmed@amazon.de>
---
 mm/sparse.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/sparse.c b/mm/sparse.c
index fd13166..33810b6 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -256,6 +256,10 @@ void __init memblocks_present(void)
 	struct memblock_region *reg;
 
 	for_each_memblock(memory, reg) {
+
+		if (memblock_is_nomap(reg))
+			continue;
+
 		memory_present(memblock_get_region_node(reg),
 			       memblock_region_memory_base_pfn(reg),
 			       memblock_region_memory_end_pfn(reg));
-- 
2.7.4

