Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3B32C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DF0C214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DF0C214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E758D6B026A; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDA446B0010; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F4FD6B0269; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16C6C6B000D
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 134so17502410pfx.21
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=IVjtqXSKegmnI8zrG8uMqv/thcRs9XCqJSWZlOVbLFSqiJlrxYlcefkK/8ly29YtHT
         3kmnsuHFYFdDvVWwcqofUTEhbCD4eFY/shfbPGKUJycSmTvQdeC/OM2zb2Iq8qkwO2T3
         sNlrMG9K55JTtvtVr5geWwmJEklOQkpZdJ8H/5NeKzQR16+wdmNP8XbAyiOKZzt1pVcs
         LeTj/tpWARhJRCAp6eEbcItSMG3+trsRjZZ/+vgQGjRoY9SXCGUbN84oym0VRF6BTeU6
         opnZZTMDdpf+ba916uAwK5qvG4yecNjzJuoXVFwTH7TXu+ZfdVw2Wb+H0UhzOoPrUSIY
         nEbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUI5j/0z1PN8qQYXXk3HT61YIi+a8tRqMuVR1vSv419cfpcSQ8z
	ajz8TpsJidpTQGNbO+bNNXRK1/u+0sMdImEarKBI5T2h1x9TBX7iamvdRCBRhQzmdJ+h5j4xTx7
	bufUcFPqDp+gN7yNbQFykgq6arLTcko/sPvkIbrkh2HCXxwiWuZ2P0Ync2nE105bwDw==
X-Received: by 2002:a17:902:e701:: with SMTP id co1mr4478074plb.61.1552876566777;
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxGj9GTZy1pKSVGUamClwyayqeVmmJ1ttyxeRymHkt+NWuDAMnTOoOW4TX2KeawqvjPjJVn
X-Received: by 2002:a17:902:e701:: with SMTP id co1mr4478024plb.61.1552876565835;
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876565; cv=none;
        d=google.com; s=arc-20160816;
        b=nqpzrxGgGouR0tYUIA83z5Atwmgjw/ckahsVqNFfsWILEAFLweKJ1yLdIQHrpgqT1z
         W9NQ/AAdeO0w9gy7KwWIvuuAjpfw2yMABBOWiVz6+TgC+ilTNF6aWbzxGHSxRpTPNV34
         7H7r05n/YSnmPOsH0+2NNkCd9rQiP1OUyVddG+XPxzzVg3fKnS/XX+ouBGrpWbi/rxUt
         6f8jjqqbl9UFImEzmb3HVjkV6nC+3Sr9zJmr0A5ntM23/LarOEU4bK+/LU0ufji6x3NL
         Z09PfriHnWqW/LChfzx7Ee1dHUxpnu8XKSMDbO8Ugpi81NNdkbOwfVBymvVQ/1ikr+yl
         RHxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=l2yjGzVw4kVSAki3MtvAFaVfNj7pK8SwuQ1Dgvh3TyqF3d3KWCM1R54SwWlR7q9HtV
         EMmGW/q17hId5gyy7X6qjC8HliIR15S0agKJpN52mm+C2oeRd7b7Cu7Kt9bhOHip+MzU
         mh2oFmpjGj9u3iDHhY3m8JZ7CyRFYCuo7o1azPbtkNH38JxKNg2xml1vDIV1o2iq5cgL
         2tXdcl3XrTrBxcgqRBj0ScuYPVjcwLG5gt9885rYo4z4GboNrT96lGyBSy95uWSjSCN4
         lak8EIAE2OpaBjR4uiWU7sDGSOw5+3YQQdSg+73swQimvkRkULnZLTmFxUtK5CtVQg2F
         AL9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b2si2253465pgw.161.2019.03.17.19.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877424"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:04 -0700
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
Subject: [RESEND 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Sun, 17 Mar 2019 11:34:36 -0700
Message-Id: <20190317183438.2057-6-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190317183438.2057-1-ira.weiny@intel.com>
References: <20190317183438.2057-1-ira.weiny@intel.com>
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
 drivers/infiniband/hw/hfi1/user_pages.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/hfi1/user_pages.c b/drivers/infiniband/hw/hfi1/user_pages.c
index 78ccacaf97d0..6a7f9cd5a94e 100644
--- a/drivers/infiniband/hw/hfi1/user_pages.c
+++ b/drivers/infiniband/hw/hfi1/user_pages.c
@@ -104,9 +104,11 @@ int hfi1_acquire_user_pages(struct mm_struct *mm, unsigned long vaddr, size_t np
 			    bool writable, struct page **pages)
 {
 	int ret;
+	unsigned int gup_flags = writable ? FOLL_WRITE : 0;
 
-	ret = get_user_pages_fast(vaddr, npages, writable ? FOLL_WRITE : 0,
-				  pages);
+	gup_flags |= FOLL_LONGTERM;
+
+	ret = get_user_pages_fast(vaddr, npages, gup_flags, pages);
 	if (ret < 0)
 		return ret;
 
-- 
2.20.1

