Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0CFEC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 761752147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 761752147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561FC8E0008; Wed, 20 Feb 2019 00:30:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 471458E0007; Wed, 20 Feb 2019 00:30:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F4148E0008; Wed, 20 Feb 2019 00:30:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFB338E0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id o24so7553433pgh.5
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=ViZMNNz+clERA4heB5gRoqjx+YV0GHBCAvQc/7ACv/tQ8ooNuyxopSFkPTpzQhs7gl
         rSDA1dAL0gVy5P+YzSVINfheRmxGV/ZOEHVtTXPiqCqOx8VYC5laF/3sg6N5IBmClkD1
         I0jIGQMCvnA5j9ctKeXdz0gQv6MgOygM0l1CiOTMzBgp0WrAoS6PPUga1gm8Ct4jIJ/Y
         PaHWA4Wd/2jCDr/gEEGplifW9+ggVYOrg5kHnNVRGfUQR4Jn3ye5W4tyfXNiOVTaaZmx
         AeglvVUunS9rnFgdVZ7r9MgCtxPLshnNuoq8HJ8j+/Ds/Q6ptf3BtldvXux+RUlFiley
         Pl6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ7JU5qVDA4z5ltRlRCYDUmHQIvJDtdjVKRFVy07IjsyOxfZnNP
	+lOWUfhIpdmZ35d45LzrF/a187bpKGi4n4fvl8w/QrYTNfaXmmDjhW5FEuIHaMH4cFFij6hVsib
	BawXLqhMdyPNYVWsVn20OFmp/1VAVWXQYyL63MliPo3czMPPPOpetDHLbFyFdDl1apA==
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr11454489plb.221.1550640652428;
        Tue, 19 Feb 2019 21:30:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9vCjxx9sKQJ2r5QDns70lacXWiNnLqzX4UWVw+ZtP+7Pl3+j0QWPbKXqHYOQLKpbxNv/B
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr11454439plb.221.1550640651716;
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640651; cv=none;
        d=google.com; s=arc-20160816;
        b=RdWl84hVXr31bCWyugnulyyudBMlWY87GAzqZb2rMdB5eQ4mOMIqlSUtQQr7fdzK0A
         CphhMSR4ETgPh86cIh4Vyh6UswXIHSVECfwsR4ORfN2cUJzia3aNH7s5n7m5UsdHWXGx
         gj68uLJ7vRdZCnIyzQ/oGPLj+ELVZu6x6/As9fUQoW/GKEDbYEYnF5WmMSaNtCsgdW23
         /Ce4MBRUA+bLQ1ol0uAkBsDM8l/7uXUxXmbyte0+ybMyvSEE7UTtWuRn/9Ve8auvKnt7
         ClgkuS4mDCj0AgbKOJWZzgfSHIijSDkpx7fTPwXPlJF14PgQpmSbuYFbpnshfhRnWFzx
         ZeFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=XCiIncj/7iaW5etd7ErnO2mOyNNzaxOZ2rP67yTOBUDQCB2ZOQ1tPGI9R5Y0CDguN9
         p9gMhdJpfxtb1spReJEn9LywlJHS0fjuq2ncjmUGuUESt8yQxH1Ue170JmxfVpK6sSQW
         zan1dskTN172XdD4RfWHz3FxX2uJThEopQ/xrJspOEIfhmo8gkO40TH7ZdecgoU6Z8VM
         96miRGi+jz0CACVqpK+XJE36eRHa7Fd7THsbkNhb1ZHJ0shKLhtUFneA+sR4oOj7dUfr
         /te7aKeg8i8r+ogGyt8Z+HEXJms2rv2DYyfO3yKzTtBIlIHOTVC0kGsfGSsMyQC515H0
         /IEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e17si17976549pgd.109.2019.02.19.21.30.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Feb 2019 21:30:51 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,388,1544515200"; 
   d="scan'208";a="144924922"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 19 Feb 2019 21:30:51 -0800
From: ira.weiny@intel.com
To: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>
Cc: Ira Weiny <ira.weiny@intel.com>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-fpga@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	devel@driverdev.osuosl.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	devel@lists.orangefs.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Subject: [RESEND PATCH 7/7] IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Tue, 19 Feb 2019 21:30:40 -0800
Message-Id: <20190220053040.10831-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190220053040.10831-1-ira.weiny@intel.com>
References: <20190220053040.10831-1-ira.weiny@intel.com>
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
 drivers/infiniband/hw/mthca/mthca_memfree.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 112d2f38e0de..8ff0e90d7564 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,8 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
+	ret = get_user_pages_fast(uaddr & PAGE_MASK, 1,
+				  FOLL_WRITE | FOLL_LONGTERM, pages);
 	if (ret < 0)
 		goto out;
 
-- 
2.20.1

