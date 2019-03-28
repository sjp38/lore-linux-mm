Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DA7EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45A4621773
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 16:45:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45A4621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 63DB96B026B; Thu, 28 Mar 2019 12:45:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 614F86B026D; Thu, 28 Mar 2019 12:45:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DDC56B026F; Thu, 28 Mar 2019 12:45:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4BB6B026B
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 12:45:42 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b10so6880092plb.17
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:45:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+BgvtgrzaQIyXctzoLTuFCxc8wQUSypC73YNI2rckV0=;
        b=s+JeekGVL6+q/4rpEHsqG8UTvV+2BbK46lO377fTeY2ud7nWoH/Hu71ucK/QK1NOAD
         l16oMOgG+X5NujqoF52ezZhqRwfPSvIyqP4/2zzhII/FRcOVmom988z9lGn5kCqtLr5t
         mZUebZ7HWOL29yloj8NO5RwkxDbRHTzAepnfFC3opL15CHsOHBmS+NHk38OpkuvH1RWs
         c7TXvzk6O3qoE6Gp1vFjChnTmnEFgtodyDSUu69J06B9ZBPIkJfUolTJId5kUbFf9p+W
         /Sz1xVm0uXLSNOKfGbskMdrVxxkul9Orjo/wX4FEPJZKwOl7l1+JUBd/H0Y2SRNcwAG0
         bH0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUs5/L5X1CtznCxdliB4z4Vf48XBozrwHwcVvWnYbGDL3CJJ0fC
	iI5GaxgvlszPnX64Ltv0e49678i1b4OiS0+AB7AubPLVDdKgBwh2j1QEY17cItgnHgQbI7hlUUK
	OvFImnZhkTeQOTNSjaygRKPy4QXBBRiebVNPJY8l6fw6GfkYLYeLH/JgFx86311LzCQ==
X-Received: by 2002:a17:902:b286:: with SMTP id u6mr5576032plr.310.1553791541738;
        Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLT8klvJAUnKYRHd7nGTAOZebE8tLIUWYWMm9aPe8BBraLGiBkJtncmGktO+kPx4Zf9jgv
X-Received: by 2002:a17:902:b286:: with SMTP id u6mr5575982plr.310.1553791541058;
        Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553791541; cv=none;
        d=google.com; s=arc-20160816;
        b=IT4oc/EVigyIlcObD9hlw8O3f/BrXH/dbOVLqgQb6UKHSAsxYtSYUirBJ16dEeV6Z5
         1VIqAdYhODL+fg22OLaGS3bKb010oKBw4e+Pnuwj3/SQp9Ull9RUjRT3FoYRXSodkT0n
         +akmLuywfhmcJ33su2BX4+Dbb4Kh1Sl+JUYzxISmZnVLGSP9vABghZs0a3D+EE4mOZho
         Xy4xJPrLPy8e2P5xpwXNu0Q5zLHqx4RAbPb0ycKrdyrk8SkYIHYnoUTMnbCCmmEsaaDD
         XKTADltaxlX4z6KmVfs/rtkwB6Jq3/Jhnva3I5mZp9drM2iuy1PhbjxVdVU1gPeLSxsp
         SzyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+BgvtgrzaQIyXctzoLTuFCxc8wQUSypC73YNI2rckV0=;
        b=QM1cEpXxXzRfedQKvtz3zctigJro6Cz04SmG120KefAi0Up/2VFREHV4FGNAeMeZYV
         pno1leu2vLShXsQHQ4xdENqkrya4ZOA1Wr5K0+HJLiA1Dth88/V1GbTcAfCFsX1C2afx
         gO071lpOdaSFx8PH3B2oXXyUfD4TVBp6x+tD9CKSjVpbllW5Zs7UzHQY5QxSVlmJNx5d
         YbP/i1aa3tL+YvcTwkgb6dwTwoTjR7rB/p+Dp/PXGmdDAjPFjGiq0r7oH3nKEMGM+EWd
         1gDMD9NuwFiLMLjEnga1tCeI/OtH4Nn5Kbw1rn802vhITZGrLPJ50qlYC8s/CPPW4HBZ
         2R7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 31si22686092plb.39.2019.03.28.09.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 09:45:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 09:45:38 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,281,1549958400"; 
   d="scan'208";a="218460216"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 28 Mar 2019 09:45:39 -0700
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
	Dan Williams <dan.j.williams@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-mips@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH V3 6/7] IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Thu, 28 Mar 2019 01:44:21 -0700
Message-Id: <20190328084422.29911-7-ira.weiny@intel.com>
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

Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Signed-off-by: Ira Weiny <ira.weiny@intel.com>

---
Changes from V2:
	added reviewed-by

 drivers/infiniband/hw/qib/qib_user_sdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/qib/qib_user_sdma.c b/drivers/infiniband/hw/qib/qib_user_sdma.c
index 31c523b2a9f5..b53cc0240e02 100644
--- a/drivers/infiniband/hw/qib/qib_user_sdma.c
+++ b/drivers/infiniband/hw/qib/qib_user_sdma.c
@@ -673,7 +673,7 @@ static int qib_user_sdma_pin_pages(const struct qib_devdata *dd,
 		else
 			j = npages;
 
-		ret = get_user_pages_fast(addr, j, 0, pages);
+		ret = get_user_pages_fast(addr, j, FOLL_LONGTERM, pages);
 		if (ret != j) {
 			i = 0;
 			j = ret;
-- 
2.20.1

