Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86033C43612
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D022206B7
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 11:09:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D022206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCEBA8E006E; Tue,  8 Jan 2019 06:09:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8A3B8E0038; Tue,  8 Jan 2019 06:09:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6F248E006E; Tue,  8 Jan 2019 06:09:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED708E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:09:57 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id z10so1476207edz.15
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:09:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=1e1MmHEozGCgkovm/IfknBU1K3QSJEw5Ou5BtIqrsFk=;
        b=sxJJSFUoQISY/SgjprJXBZybSlpG7M1vXUTkf1+dfhb5flLeiPlFfs+A2jmX2ceVPR
         0eOErluvYMzjcUDSjPsviiSge1ndYem/9fdgEe0wJish2ACY9MGH+/Ra3bBdODXe6/g2
         kU95+2Mn6mGhVpqKsVZDQve7MtdNa84FQwCjxhe67S2bqEQIEP7EoRVAvVw/G9exu8VP
         VF11l2wI3WvPAXucamrSwXDBz20u8ct9igs2xQapBBrT3X7op5O7GYFbsDS4Hx2VFxKd
         HNxIU3xtDEoT2b6Hlq1gdKQjd05VSX0aYfMvoWbJ0OfVp4DPSZ0lCFDE9fISVUCklFSN
         kZRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: AJcUukfHpjRf//C02xQZYIdXk+9SjhX6exfHvBMph0SyVsigNWhIEK8u
	/K1ZRQqcn05thbdIJ+sEmmaR6D5mayvXRInmYT37Lz6b4jDU2TJ9jsyyrWGNgi33LbX9rLRkesx
	6pwWlvusFVt1Kn5VKscmGEkp+COBAOouDbpZFf9/si7eIb23zyml+etUzcQjGMsBXqw==
X-Received: by 2002:a50:92e7:: with SMTP id l36mr1651207eda.182.1546945796793;
        Tue, 08 Jan 2019 03:09:56 -0800 (PST)
X-Google-Smtp-Source: ALg8bN625VB625G/3Ja+ZY23HeJOMIaa8/QqbuX8wAWSscAvkydZ5FG5GoLqtvTe24VpOslR9fRJ
X-Received: by 2002:a50:92e7:: with SMTP id l36mr1651138eda.182.1546945795462;
        Tue, 08 Jan 2019 03:09:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546945795; cv=none;
        d=google.com; s=arc-20160816;
        b=XUhk1nGpTxixget+XYcXZY4l4c9/iqSuAfBuKoe4YjUsEnUusGs7qaC0PTGUo6QFk3
         ZJfvPCXtgbKpU3FxYXwNiX5R1cXuXxElVADs5OVGXPb3yEaLU96hGIR+VWgR5wQxqlk8
         UYs6644Is3gZHzJXevIwnD5VF28plrwcg714MvUSmxWnlvU+Eq+08M1dsZc2zhEzY7o0
         t1wGBEvk32SRbttLF1AXGVJMeT5eTVJtFjk+DB/qSnVxzMIsmRrPJOb486fwLVo4tOk/
         5eYnsyQsh2CijnlSthFSehUoqHYdtr82/+Crvu39XVJ1SYVNanUnjuDo9ERrlBsfwXOz
         EWXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=1e1MmHEozGCgkovm/IfknBU1K3QSJEw5Ou5BtIqrsFk=;
        b=0aDe3zlDiuPRoMxZQNI+I/xGmswwoYMfAgIPgiQS1VrX9pSOoA19npAsdBBxxk0W6D
         /ZeZmQlSkEprPIGV4fFTOdbJAACQjgsldR3Ig6lXYA8WC3YJTlldJdAPDxKxi343Ts7r
         QYzqjAtcvyvvQbx41Xbz4MP3UECC7zfD2hpymcWvUo+STeOzQHYLJdAE7NHVBrBpgR1G
         NYh5vKJt3JSVUTrPrMzDQQgLFZguKM5uJ3BOXDeaekAu1WT7f2ZzXicRy6TZxfRjFeir
         yQA3z3qZR/rB6mSIi+gMaK0l6yECPVZdEIngJ/F3v6ju1HRlnBVEeb+rvMLqOrmRCbk2
         KzaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14si673014edw.282.2019.01.08.03.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:09:55 -0800 (PST)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A5EFAAE6E;
	Tue,  8 Jan 2019 11:09:54 +0000 (UTC)
From: Roman Penyaev <rpenyaev@suse.de>
To: 
Cc: Roman Penyaev <rpenyaev@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Michal Hocko <mhocko@suse.com>,
	"David S . Miller" <davem@davemloft.net>,
	Peter Zijlstra <peterz@infradead.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 1/1] mm/vmalloc: Make vmalloc_32_user() align base kernel virtual address to SHMLBA
Date: Tue,  8 Jan 2019 12:09:44 +0100
Message-Id: <20190108110944.23591-1-rpenyaev@suse.de>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190108110944.RntzrwX0lDRtaya4qDXrNC98tFsnug9czEzp4D5MtLc@z>

This patch repeats the original one from David S. Miller:

  2dca6999eed5 ("mm, perf_event: Make vmalloc_user() align base kernel virtual address to SHMLBA")

but for missed vmalloc_32_user() case, which also requires correct
alignment of virtual address on kernel side to avoid D-caches
aliases.  A bit of copy-paste from original patch to recover in
memory of what is all about:

  When a vmalloc'd area is mmap'd into userspace, some kind of
  co-ordination is necessary for this to work on platforms with cpu
  D-caches which can have aliases.

  Otherwise kernel side writes won't be seen properly in userspace
  and vice versa.

  If the kernel side mapping and the user side one have the same
  alignment, modulo SHMLBA, this can work as long as VM_SHARED is
  shared of VMA and for all current users this is true.  VM_SHARED
  will force SHMLBA alignment of the user side mmap on platforms with
  D-cache aliasing matters.

  David S. Miller

Signed-off-by: Roman Penyaev <rpenyaev@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/vmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 50b17c745149..e83961767dc1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1971,7 +1971,7 @@ EXPORT_SYMBOL(vmalloc_32);
  */
 void *vmalloc_32_user(unsigned long size)
 {
-	return __vmalloc_node_range(size, 1,  VMALLOC_START, VMALLOC_END,
+	return __vmalloc_node_range(size, SHMLBA,  VMALLOC_START, VMALLOC_END,
 				    GFP_VMALLOC32 | __GFP_ZERO, PAGE_KERNEL,
 				    VM_USERMAP, NUMA_NO_NODE,
 				    __builtin_return_address(0));
-- 
2.19.1

