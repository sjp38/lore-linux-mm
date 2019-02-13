Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A73BC10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4374F222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:05:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4374F222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFDBA8E0014; Wed, 13 Feb 2019 18:05:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0D268E0012; Wed, 13 Feb 2019 18:05:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 920978E0014; Wed, 13 Feb 2019 18:05:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 419BE8E0012
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:05:35 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b15so3118661pfi.6
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:05:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=eUEDoXp7LuzfEpS3aB0Wtq29HJxvYdRfDpG3cr95iv6XYHYkZ9hIpPGmrXYmD8KyXN
         uX2dU8+fbCDynels9vm8JaL3uJw8pizsm73gnlC9gLL3fAOyfy6gABtW3DnsWorjXV7k
         BZz4OvvDj/11ac4K4Xulq4jqLI/e/nondB3UR43zRRv8L5+isPcz+hdb7q2uDvljN+Zy
         7J0/x58URern7oJBrln/J4aqHLZP04z0H/axj2bS2AsUo+WU5JGJFV9P4Jv+gL7XQUGl
         0K63HeB2PO3xjUlpCNSXux35pyLPfHzEUAWTtwtzGceDWe3d93f1siUpPhc+CXY8Nk7W
         z/pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuabaC29DvhJUUnVuFw/DTzKjkliqYGd4YATDk9+/cVwFitk2uUN
	6TacFDt2a1pdQc7vBP4yBdSTabHEHUPWRRiJhWN32U0UbaxW+viaSdg/Etf6LbKEEF6RaJrz5C5
	w1gsDE2fCq8wNRKxfvIM/Ff1oiaGqeog8Ty2Or2DR77adgZgOfPLJQwVHOJnYXk9fig==
X-Received: by 2002:a63:9a09:: with SMTP id o9mr614868pge.94.1550099134943;
        Wed, 13 Feb 2019 15:05:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6TsQWsU2GqtBM4w5BVv9Ng1qWErGUgVWjso8kKaS8a0yCzUOoqcGP4McP8Rc//9mi168Z
X-Received: by 2002:a63:9a09:: with SMTP id o9mr614818pge.94.1550099134204;
        Wed, 13 Feb 2019 15:05:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099134; cv=none;
        d=google.com; s=arc-20160816;
        b=rhS4aoeP5FqgaWNJMdWfeHokGJ9Jok4SQedA+GZYN2r8zaUxfJ5raayJCsr0faseJ7
         aTCXpTRBucQ3Bor7BbVHhEL/xFu51jwTCrgU04g9Q1rv7isgIsdQuTkyYJvBdcVz2hBb
         VIYBMpXEVgizoMjYIru80cobdJKsjsUPu/BbVs5xEXu5fW+wnoZFYey6VWvve90MZWxn
         2wmMa/LJ1iWLvfj9bg9qO09iz2h7q6xx3Vtx2m7upI7n80NnolMn5G3IuE4i4XpmikGh
         /aID/xLC5aROsezpcEbg3a+0NFb2x60W/V+3hZdV2QGdqRb2r1Jd2bQkdrtmN/6gyO6t
         b1/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=sm9KVq84oiiAYMg20zXiSmThnRl3AUZlX5Q/b9OCMQkGmc2BKApYzfnzIGXKsdPoiq
         HhRF+7h5hBA/TPdLEZuy+y5V1ZyEiM0E3JLn4GZCzBldxuNpgPr1NEjnYLdeLKiqvtZG
         b1rhrYRSF1qWZQcRXhHFWRijeYhJS+fpyYGAPSqBDtegnxp/qEpiOoDNROC+KWpDhUac
         lo2FWpYF9R2EVV0X69F80gpA7JQtqfg9LnJSz590kM89hiKXTN9cqPq6xKEyCc2jou1u
         txn9++FJvxjf7oZktSkElFJuIDSmhWK93+LYxrRcJ7ZOMDlzBw76Qni9WFf0rqPOI2Wr
         GJLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f9si574863pgh.435.2019.02.13.15.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 15:05:34 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 15:05:33 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="138415653"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga001.jf.intel.com with ESMTP; 13 Feb 2019 15:05:31 -0800
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
Subject: [PATCH V2 6/7] IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Wed, 13 Feb 2019 15:04:54 -0800
Message-Id: <20190213230455.5605-7-ira.weiny@intel.com>
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

