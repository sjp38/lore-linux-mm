Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 176DBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D14212183F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D14212183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8628E0004; Wed, 20 Feb 2019 00:30:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 031158E000A; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9B068E0004; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 768C38E0004
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y12so15544411pll.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=MDL++RwU67VI/KDzUQcRrlXkok4MFBXmtzcxYliPdOtOvK1kB2lx2mDfD/QyS3Mgw4
         uj5WbiwoYJ70+LuuNQ19D51eO2uTj+0I5cWgtS6z0EaZVBHrc71YbZgjuM/1yvCs5tvs
         oSw2znRFTAf+Mo8yVrVQrzmMtwnQvWOxJst54GZ4ZY7SG10IGAYiYjQY5ivM5Vr5UX+g
         B8Xs0hFrszfu1AgSd/AMx5FmpvGY+fdBgIZaF8NE/m4kUAVmvPI/jq1m+WOMnMHUOtJC
         1pBWzFqkgqAn1bARWOrPzcM9/W3ughZuwOLc5Kti/cHhLfHyWIRVIVxWtcIeumwdMFMd
         w3UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYiXARydaJ7R9tBzblXxS6FIZIH46Jkxr7gweNHD7SeRt5uyYhC
	vGntUj/foJ5/0lR9aOj4G+zDJYtmt0UmT9mpIMCkEtM3W/4h8/dJypvyjJY12yKCAz8H5VCf7uz
	EuA+JmAv3Pq6BbBD0xJo3ByUi3nvGfVZ3XHbEyNGjYrulB+UnqCQ4HXfSUJ4vRQhRag==
X-Received: by 2002:a63:e051:: with SMTP id n17mr27491199pgj.258.1550640652130;
        Tue, 19 Feb 2019 21:30:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYLNYfFkVefpRSzPC6YLBtmaY8GbTiGmf50lptM8vENdo503fUCHWdJOXsgsKgwAVqOtc4e
X-Received: by 2002:a63:e051:: with SMTP id n17mr27491166pgj.258.1550640651408;
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640651; cv=none;
        d=google.com; s=arc-20160816;
        b=v4NfrB0/3H5K8pFNU4QqbTorXmrZq97DD3XrSYZ1AcUyJwchBxAo0FwENbLjdPEhmO
         Lltk/VKID8QHcR/jn2g+mdJd8nl+HtsV69k7ckv/tfasI3LEzAK27hp+TQDmqDxjZeTE
         CC33Q1YXN3Q4Zr9Vm+VgFF/bRwvA46MPK3HXxAgQx9PojD7wP0Mhzn+LG7qAxWY2JwwE
         Kn+9eyR7a9CGcP8ZwK2z8AyXwfUERWn6TtlvWRkXy0UYua8yZf8RIzx0/Ar76Fx5XOsC
         733tQufkVT89C1Rlh12dgfWX7fRymZFuJWNiJJzxufNnNkiSect9yZ3T5Jo6zI9g6fCb
         p7lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=nZHqVthQLxmntwa7XQVVhLtMhb5/tH8Z1I8cIGsiS8K+8LT4pWSwhOtJtDLk15kH+O
         tdcuwl6DoaxQKqjSMEgtCzen1QD7CPLf3WWdEcgLbrSfb4xk6yRq09/rycqo5qjAJFgM
         xZFR8wb04sbsSJjJGiMlwUFP0x/H5t7mWxMmOxjpbamHmL8JLjnVq63IAf6+xRk1hAAk
         hM62/D96peTsYupu/oliu+3YTpkjpiiOPSgR6RXCK0Llg2NgJgZega1zD4rF+BfEfNP6
         VFRjKYCX6CgezjY5jTCjEP+bqFpvMlox0KI6eCcCqVSsPBhJ+jE6gPA6O6B185f/XfdW
         zaaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id t3si6328884plq.430.2019.02.19.21.30.51
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
   d="scan'208";a="144924919"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga002.fm.intel.com with ESMTP; 19 Feb 2019 21:30:50 -0800
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
Subject: [RESEND PATCH 6/7] IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Tue, 19 Feb 2019 21:30:39 -0800
Message-Id: <20190220053040.10831-7-ira.weiny@intel.com>
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

