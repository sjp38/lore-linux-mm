Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA00C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:07:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B25EC20844
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:07:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B25EC20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2380F8E000B; Mon,  8 Jul 2019 04:07:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E9C58E0002; Mon,  8 Jul 2019 04:07:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08A1C8E000B; Mon,  8 Jul 2019 04:07:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id D630B8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 04:07:55 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id b4so8824908otf.15
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 01:07:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=uxQk6Zb9OszzDMAmkPuJ162HT84qhe6b/nzq9F5f04U=;
        b=rmqTKjM/ZkTwv6x9veZMRoz+sjDyiJfPkYGQ9r7x641eulPcn2/zCI90QgoPPPAksK
         lKEo8+Lt5aoIEKRTVAxwYmiDXkjvpeaiO+QymfqEIJFhnFqXMs3NNEEJUCvnt2A7sMVU
         Qi2P+BVEOlkbQAc5iPKv6sy4ZlTYljrWv69m3nmSlghsAk+H95O97EnmPLVxJOQj5mAV
         T+3QS6VtIog/iDxC4SPk71ri6LHTRddxlSmLKXtKTd+NEQLZbZtnlMpSMfpIDzHW0buk
         jVFh65LpUG9aoDmEILzL7MZNSb+HI4XuIocFDC+HJ9biGC3VSdt2eSZJpnbzpW9TtlA6
         uydQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAUI76PN+yNFq2ReBQQIYLmW4B41S93auGyODSJhLn1nXSch2wxp
	0uUJqvOk5agn7ePP8tngqdhsR8933cXDOA5lnUdSyve9n951V83pCUFacuU63xKQ1Hfs0oihd1n
	8PnHCneYsnaDV3OtR23asSayAvqNjwyNIByeZN9maaTSjAa7j4cmnyrsNPoZ5cOb7zA==
X-Received: by 2002:a9d:5615:: with SMTP id e21mr1559682oti.152.1562573275527;
        Mon, 08 Jul 2019 01:07:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHGqlIfo6vNlP+UcJgPAnhS8oLTiejUXlwTSYvpLXSKuJ4MM5OO7BgfanEEZC91HJoFgCu
X-Received: by 2002:a9d:5615:: with SMTP id e21mr1559631oti.152.1562573274755;
        Mon, 08 Jul 2019 01:07:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562573274; cv=none;
        d=google.com; s=arc-20160816;
        b=bYAqE/C0sI/yU15q+nKP5egYSji09CWriAtPV3fOjeqLOTsKJbsPJl8yPZOq75ecmu
         pTxq3RjTIPYVdJ1WrfVk8q1uWjPaBKS99hNfelUldYsYhy8cWRXKOPeISo/jKK/pEoWQ
         Ji/FfmoDb4l72LMtBMwD6D0wzS9DCSiVOwmL/IfTGNrQIYmm/B8kkAiFTzyZavF8jvDP
         clJ56Ci//U6pWjNugfOWZHhvsV56couyx9s2eSv6sfSOel11GVzMkiT1Sg6LB8lXBCrR
         YWb6nN99ae+fu+ui6nq8lZ3Sx3y7v+YQpqc/4AdArKVVEX5ZbFPGp8/s4rewYhjL1bHK
         B5Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=uxQk6Zb9OszzDMAmkPuJ162HT84qhe6b/nzq9F5f04U=;
        b=mLfDp7To6z8YbWBcIkfapd6w9d/u5HxDFsHm9RicJn3v226kYzje0n+AJ9ZX20uGfa
         63opibZpuwMme6EdkYMzB8EE2WYftswbjgWrTzLxtUMQPBQMGq0RGo3H4heNhUQZe4kA
         IDxVyq7IbQfjPnYnbGutiBU0mFMMGS1aC202qQavAFRp/yD5qikatZb6pg5rLzgK2LL2
         kBGGc2Wd5T8ILeXZG5HlI70WzKw8RtQb5HMOoVINWczrF8gKGqMLcO2DsL9bNkwxgFn+
         AsVPpTK9Cr8CmHELAQ4XaxiTsUzdOvOC8KD8qaWLeNI0cBqLfSR17oRtD1LPj+iP4Qrg
         SYGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id e1si5593701otq.243.2019.07.08.01.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 01:07:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 284F1FEF5DB1A49B8B75;
	Mon,  8 Jul 2019 16:07:49 +0800 (CST)
Received: from linux-ibm.site (10.175.102.37) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.439.0; Mon, 8 Jul 2019 16:07:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
To: <akpm@linux-foundation.org>, <anshuman.khandual@arm.com>,
	<mhocko@suse.com>
CC: <mst@redhat.com>, <linux-mm@kvack.org>
Subject: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
Date: Mon, 8 Jul 2019 16:05:41 +0800
Message-ID: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
X-Mailer: git-send-email 1.7.12.4
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.175.102.37]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As the mman manual says, mmap should return fails when we assign
the flags to MAP_SHARED | MAP_PRIVATE.

But In fact, We run the code successfully and unexpected.
It is because MAP_SHARED_VALIDATE is introduced and equal to
MAP_SHARED | MAP_PRIVATE.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 include/uapi/linux/mman.h                          | 2 +-
 tools/include/uapi/asm-generic/mman-common-tools.h | 2 +-
 tools/include/uapi/linux/mman.h                    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/mman.h b/include/uapi/linux/mman.h
index fc1a64c..1d3098e 100644
--- a/include/uapi/linux/mman.h
+++ b/include/uapi/linux/mman.h
@@ -14,7 +14,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
-#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
+#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
 
 /*
  * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
diff --git a/tools/include/uapi/asm-generic/mman-common-tools.h b/tools/include/uapi/asm-generic/mman-common-tools.h
index af7d0d3..4fc44d2 100644
--- a/tools/include/uapi/asm-generic/mman-common-tools.h
+++ b/tools/include/uapi/asm-generic/mman-common-tools.h
@@ -18,6 +18,6 @@
 #ifndef MAP_SHARED
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
-#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
+#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
 #endif
 #endif // __ASM_GENERIC_MMAN_COMMON_TOOLS_ONLY_H
diff --git a/tools/include/uapi/linux/mman.h b/tools/include/uapi/linux/mman.h
index fc1a64c..1d3098e 100644
--- a/tools/include/uapi/linux/mman.h
+++ b/tools/include/uapi/linux/mman.h
@@ -14,7 +14,7 @@
 
 #define MAP_SHARED	0x01		/* Share changes */
 #define MAP_PRIVATE	0x02		/* Changes are private */
-#define MAP_SHARED_VALIDATE 0x03	/* share + validate extension flags */
+#define MAP_SHARED_VALIDATE 0x04	/* share + validate extension flags */
 
 /*
  * Huge page size encoding when MAP_HUGETLB is specified, and a huge page
-- 
1.7.12.4

