Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EBE3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3702E21773
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3702E21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57B596B0269; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 529E16B026D; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F6326B026B; Thu, 28 Mar 2019 12:45:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7BD46B0266
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 42so6880061pld.8
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JKkXpu5ulRZoEmRVgcQcnG4wvwa0D58bSOxaQyyNmz4=;
        b=j1nIIJBubb7L7Dr5qeorCCpfU14q/KAuGcteWHC89Vsr3PTPvqKX7mJoGRgcZGmEyw
         nOE89BscD2Bbct84WmXTuTieN0tphuW2FIootLQvGV74Mh/3jeHXDsEWry4Dc31ScHhN
         Bg6aTbqNlufMTLRpruouAHDUMfnOFeC7dT96G6cvmBhDqSqMogBAtYHs81wirMVuovS2
         pF5czphPMotYVNC6kMlBKbAT/PFrCXMLAx0fpjFrk9v8LdmmVexVlKk77mCLk3SiXUM5
         i6y+qm0USNmGZ8AjyFfew6+5er0LdjAshEkqmqdJTEZR6E0NR2T5myyIN1dfuRo6kin6
         +oUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXzIebegW7sfEGv7ZWNpa+FBcESne1zIr6Dy1sv17A6SCBNI+CZ
	yr34QIFVKemb2Lzh8MHABSFwqgUGAY9tzVRgtoqj5uDpjDrUmq7FGhpJr6y3J3YJtqxj+EFFmtV
	Ixj2fXap5LqkwR4a0hi75dyQdZURHBdKlMxFvd3LoFchBbILff0DCxG+C6gTXvFFsNQ==
X-Received: by 2002:a17:902:b609:: with SMTP id b9mr43877381pls.134.1553791540640;
        Thu, 28 Mar 2019 09:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrkec96cWIhNp8ym/Xxh2ICy0O8UVrgqG7ZszfSHW3WuiAtf2E1iY5/8DvTavXMbrTEi0W
X-Received: by 2002:a17:902:b609:: with SMTP id b9mr43877330pls.134.1553791539902;
        Thu, 28 Mar 2019 09:45:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791539; cv=none;
        d=google.com; s=arc-20160816;
        b=yUaKTEG6IxaHi/riNEvixLmxd4pCiyOXINs+kJMETF3oa1XYMDXG/b86pyQaV0Fg7Z
         ORFOxvIutwoWww5FLqGjADBBojR+XBWIUbgOs+8om8VLPwov0ibU2zUYNyh5i87EEWje
         ahV2Apz8MZ5/bvfMuV8QbHjcygmxAn72WyWvtAwWVAWwXGJW5FudZXwh28kpoOJ1iG6T
         +TU60MeE2aswCxK4yqJR6FW90ho470cuGaNsp+mCtJSwhdQ2FYIPyqla3kCsq0fvqGJn
         uJfl7SjRFKldrwFMcaWn4Rx3RRxhRsOVCRGu94FrJvOa3PEJ8FFYnhyIx1ygGNpZszjD
         jfEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=JKkXpu5ulRZoEmRVgcQcnG4wvwa0D58bSOxaQyyNmz4=;
        b=j2H6V/TbnmnmuoRdRIylgZgdwPi3vi2zhY9fqeVckNiXNsT3Ltkwq8kZNDGmXEs8wh
         /UGPXFv549n8ClDrzoVK1NWRlXiUZg3jxkkp50CHzfvq5dcv1bZy+p2cq+mxiloITR2R
         BiPkxX0lmP90/4gMIdaz9VOicJpTdn0ygCnZGR6fXpo/zUj77CzocUqTV3dXyvMTkMdX
         5guPNwbXmyk2J1VuxRLLN8GSBr9Lkl5P0mC7KCtjwdBc/LGuBOuHK8+dhpa/30Ovyvdw
         9Yj/qCU/nXEMUOdV1ZsRFrLxHAowGQQlItfuqn6GARQcBCzdyxoUbH0uYRTAF4mz6a0w
         /FlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:37 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460210"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:38 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Rich Felker <dalias@libc.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Ralf Baechle <ralf@linux-mips.org>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Thu, 28 Mar 2019 01:44:20 -0700
Message-Id: <20190328084422.29911-6-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328084422.29911-1-ira.weiny@intel.com>
References: <20190328084422.29911-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
FS DAX pages being mapped.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2
	Per Dan Williams: set FOLL_LONGTERM on declaration line

 drivers/infiniband/hw/hfi1/user_pages.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 78ccacaf97d0..02eee8eff1db 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -104,9 +104,9 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 			    bool writable, struct page **pages)
 {
 	int ret;
+	unsigned int gup_flags = FOLL_LONGTERM | (writable ? FOLL_WRITE : 0);
 
-	ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
-				  pages);
+	ret = get_user_pages_fast(vaddr, npages, gup_flags, pages);
 	if (ret < 0)
 		return ret;
 
-- 
2.20.1

