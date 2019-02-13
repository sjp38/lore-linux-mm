Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AF09C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9702222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9702222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BF4D8E0015; Wed, 13 Feb 2019 18:05:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 149828E0012; Wed, 13 Feb 2019 18:05:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E91228E0015; Wed, 13 Feb 2019 18:05:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A48748E0012
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:37 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id j32so2798903pgm.5
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=l3yeQFEizEpi0KVSD3VUQmgbsse5wvqRawVmk4JZNRIQMd0dcTb88eYniZRxbuQHnL
         1utSVw16L8X87l0BfjMfw61dt1LHKtB4nmerkskZQUOLCSZE2MTGj3zMGUGu1ByJTS7J
         XXhoSEE8An68RFosVd30EgUqTxozGtE5rLNX7IgYGdUIQf5A5ayekGumuUcZEkoHsqhK
         SJGVDs/ZejVBJiLV1xdrVJwcXIgfGUA15l1hwx3kl8IcwYM5jYEAf4ZqWpSUNDjhh+zE
         lFg390BMcVMobJjgHYEtnYoL8fy2Ut4/oZr/esIzpK54DxpA4ibMbUNbHouwafw1+eTM
         HPXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZjT/+nzTGn6gjWROZdbCjFsgAO9CWOfl7MmNn1OrO38SzetgHi
	r9AC7ZEly4tjwL2wDSyAn0unJG80adKohT4WHzU7ytkhKJWpsezJbfMP01VkVuc8tNystxYugUp
	0fZgI1UFvWaSwSQnFmGtQXr/quQ9Q1AIR8oTulF+/mr83QEQg6oTK5tK2XwaJ6qBYIg==
X-Received: by 2002:a63:535c:: with SMTP id t28mr641207pgl.128.1550099137372;
        Wed, 13 Feb 2019 15:05:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJAnj/twuVqstYauodB/67DR+pzsookn9ZMpcIVbn69mOzwaBXFLvIxueaM37clW890ScU
X-Received: by 2002:a63:535c:: with SMTP id t28mr641159pgl.128.1550099136775;
        Wed, 13 Feb 2019 15:05:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099136; cv=none;
        d=google.com; s=arc-20160816;
        b=PartS+TRrYoY7+H8AchZRYr23S0rVU2wRToXlDAMJ9hR9S/SvNqXcIVS4faqa9lS6A
         a8otAno78LL0Hks+vQaKTtL8Bkzs5/aFpCXt3OaWZvbTZEeCcxKMXM8j8N+W4GhSWs7y
         lIJR1nsleVivRAl85jbogsJ9Ssfkl1UaBzNz1sfeAOGTSgZdASG3zDB+2s0mr4EFip0w
         Z8/J00Tblj2GN7qtTOXkZnczTqwnuI2BfMW+yrGMm5fQ9PNZwLGbbgbb+vwRNcZpVgxG
         xxbikiDawmGrRGLdUxvxRS1jRdsgILY5egjaPwGpD57wePumOxi+zgyO2rMgPc4FgvmQ
         egpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z2oLMpEtZJkOWhiVxDwCbgAywRjmrernHVpSPAUXgTY=;
        b=ohd5wC4fgT00INUs6tO63N6gdeYA1Dt2p4m9rUFL//WfkWC+6IVItxJ1APOLj4FZn/
         arT19X/CrQ6B+yJLJzeihyrZzhjWMTC4GebCv2mut7kKMiLbkF0MspQapDEHp7oP8nlL
         5V9qbJhNiYkeQoM/F2OJvLE9VbNIg03kHLXTt1fDa/byMx6haND2MDMdoAcN0MFZhNoa
         tuYk5RMkTJ90PJ+UjYCJn4qnXHuVXtH57X/eH2QnQ9+s0cLCt6pC3vxMP7kxdtppd3xd
         iDx+nRd1Zv72imr5yFz1R2OT/Szw7PAlI1UPLRtx2qBfdmgdvd38BMyodxZ0ZeBRwFtp
         oRIw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f9si574863pgh.435.2019.02.13.15.05.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:36 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:36 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415659"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:34 -0800
From: ira.weiny@intel.com
To: linux-mips@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
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
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	rds-devel@oss.oracle.com
Cc: Ira Weiny <ira.weiny@intel.com>,
	John Hubbard <jhubbard@nvidia.com>,
	David Hildenbrand <david@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Joerg Roedel <joro@8bytes.org>,
	Wu Hao <hao.wu@intel.com>,
	Alan Tull <atull@kernel.org>,
	Moritz Fischer <mdf@kernel.org>,
	David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Christian Benvenuti <benve@cisco.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Alexandre Bounine <alex.bou9@gmail.com>,
	=?UTF-8?q?Kai=20M=C3=A4kisara?= <Kai.Makisara@kolumbus.fi>,
	"James E.J. Bottomley" <jejb@linux.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	Rob Springer <rspringer@google.com>,
	Todd Poynor <toddpoynor@google.com>,
	Ben Chan <benchan@chromium.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Martin Brandenburg <martin@omnibond.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH V2 7/7] IB/mthca: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Wed, 13 Feb 2019 15:04:55 -0800
Message-Id: <20190213230455.5605-8-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213230455.5605-1-ira.weiny@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190213230455.5605-1-ira.weiny@intel.com>
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

