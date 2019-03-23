Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD9FCC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7327D218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7327D218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B756B000C; Sat, 23 Mar 2019 00:45:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 208976B000D; Sat, 23 Mar 2019 00:45:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A8476B000E; Sat, 23 Mar 2019 00:45:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB4B66B000C
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f12so3981609pgs.2
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=3MssjOYGLVJvWySvWCRwamZGM4wpNkW74+k4V2c5XL8=;
        b=IP8a/JKT0I3F+5ydwJiTSNfps4mjpBmPS6GPlr2Thb1Q7T8gh7lPkYC0oeUNheCEsj
         UHajAPNPoetJ3mV5yhXd7zKfioR0HcU+ovX+zk8iOnwdnk/by8jOnYC5O1A9SBcjvrja
         6qEeCj0eneJFcyRug0tpm8Dn+BE5GjbcjUk6b2/NVfcNtsdfvZYMthlFq8vYZuBiapmm
         oYm2iLFhDCRvQjVpMFwjHLYmF8wZo32hXe3m3eVAMurlOwhZlh0eDb1h8Uxf8sCs7uCU
         XdKFX6VYyPbPPqsjw6/Efm8SWiousZDDRc7RxJeT4FDq8hH68XDke97jZYA1HlMbRjWn
         K8Xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU8lEeAIg5JONOU9gxK1mxWFoHga8h7OSmV3nsbtr8oAK7Hva1s
	boq4MntXBLFF5raw5iq4SkcPfpTQs07YLOsvo3zrrNTdzh45elSMSghKwlavvAB0zN0wgvuKEzF
	q57p20LGhTIrzmneP6csnzxlolTTgPpVGQ/FcKINQTgzrz82NDpFRnMwVFILHlvcKuQ==
X-Received: by 2002:a65:4549:: with SMTP id x9mr12776135pgr.3.1553316307441;
        Fri, 22 Mar 2019 21:45:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdHLUgMWcBfTLL4LAypomLuX/j/GiLGMBEphIrEfeweIWdvPZJVpVUQ8rzhm0RIksEvpFv
X-Received: by 2002:a65:4549:: with SMTP id x9mr12776076pgr.3.1553316306293;
        Fri, 22 Mar 2019 21:45:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316306; cv=none;
        d=google.com; s=arc-20160816;
        b=ApNagy01IGN4kAnD5Hz9a0zlvm+ThVo7OZ8z6DG4/bTvbpNYBD/W2BETdskwSyTtaL
         Q//LnOs5kBtnBZ/cmFZhz3yeK/MLhENsmVr6YK1XSlZ8HVMUtLzJLDb+qpQUflETprG1
         4k3Fi9P9hURl5KVF6szbCfMxylc4eMDp7xeB0fydpx45l3H+KOG8W5EZyeuFn7w455H7
         dYf6cNO9eNsMKUNoj2HDq/oz5lopSLMG+/p2IqtcAjDF6bkxVBNeJ4KGhqPqS+bjb7ha
         YrlShS0gg02YNZZBUyQ1QmcSlPfD0/nxJCogxCxL/s/B4TRRdsthVc4rIaHaYbBxas6h
         rnpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=3MssjOYGLVJvWySvWCRwamZGM4wpNkW74+k4V2c5XL8=;
        b=mVEw7jpZQFRwVc6dJJ64SgRew+skETDaeKGVdxR/UaLxjdAyG/DbjUEzM9RQ0M87F+
         vLyYUjErcVGHXlN3cRniBa0l2RDfEY7iMfWWNMVP1FlPaSqvLi4+Dkk+Oop8VVfSER/B
         9rg/nv2Z397eAdU1zj3P+LSHD/v82GO/o6Au8JKCcJrd9d6wfvOuqbzv1OOgSe1SXgR1
         gmCB0hrvznpVtoW2cU76MlqjRAZwR4cHAYtE3fY5vz5nS/jvdhRCfxp1hwtMMhzgR5xy
         BbdNhnw4kV2PeebR5y8+dQjDDWabwpdKo1FyTvFjvw+lAUOf1njSm/l2j59L7bv5VRQZ
         3KHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id g5si8166563pgc.122.2019.03.22.21.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R231e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07488;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:04 +0800
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
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 10/10] doc: elaborate the PMEM allocation rule
Date: Sat, 23 Mar 2019 12:44:35 +0800
Message-Id: <1553316275-21985-11-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

non-DRAM nodes are excluded from default allocation node mask, elaborate
the rules.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 Documentation/vm/numa.rst | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/Documentation/vm/numa.rst b/Documentation/vm/numa.rst
index 185d8a5..8c2fd5c 100644
--- a/Documentation/vm/numa.rst
+++ b/Documentation/vm/numa.rst
@@ -133,7 +133,7 @@ a subsystem allocates per CPU memory resources, for example.
 
 A typical model for making such an allocation is to obtain the node id of the
 node to which the "current CPU" is attached using one of the kernel's
-numa_node_id() or CPU_to_node() functions and then request memory from only
+numa_node_id() or cpu_to_node() functions and then request memory from only
 the node id returned.  When such an allocation fails, the requesting subsystem
 may revert to its own fallback path.  The slab kernel memory allocator is an
 example of this.  Or, the subsystem may choose to disable or not to enable
@@ -148,3 +148,8 @@ architectures transparently, kernel subsystems can use the numa_mem_id()
 or cpu_to_mem() function to locate the "local memory node" for the calling or
 specified CPU.  Again, this is the same node from which default, local page
 allocations will be attempted.
+
+If the architecture supports non-regular DRAM nodes, i.e. NVDIMM on x86, the
+non-DRAM nodes are hidden from default mode, IOWs the default allocation
+would not end up on non-DRAM nodes, unless thoes nodes are specified
+explicity by mempolicy. [see Documentation/vm/numa_memory_policy.txt.]
-- 
1.8.3.1

