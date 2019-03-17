Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67937C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E224214D8
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 02:36:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E224214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 247636B000A; Sun, 17 Mar 2019 22:36:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E70776B0269; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B896A6B000A; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C50A6B0010
	for <linux-mm@kvack.org>; Sun, 17 Mar 2019 22:36:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so17551445pfz.8
        for <linux-mm@kvack.org>; Sun, 17 Mar 2019 19:36:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=iJKlxDuHg9LMuqOwnHoWaySqzsG77sd37lb9AdxIEvn5K9J9krPz0x1Dhbb5+IL8Es
         PUEWKf645pMNmTD7R75O75rjhQO21egMuwKGGjYkQRyARKtUE8o3iKPoO/ffDqNi3tEb
         tvj1kLNXMJ7nNVfxeY+D2Rth8L9wEhvdkF3U80rKJUZWagtbyQe/gQ7jRp/rzKFjSTLm
         M+nMZOafUYF0be2dVdGSZ0PNungrGtVRrZR0eG3NCs0nj/EL80YfVdYcYo0NPPVlOUVc
         Y6vLNaUD3FkcojKuGZ84dGSWcgZ6Tdl0v5TvRGUt0IZ8iiDTjZPgTYeMCrzZ+Rk41ID8
         PdHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUPilYimtjvJvD607liGjIVtSuef4R4CuuZ0VZyppKvjjh7JeKi
	enP3hi8dYxF90Z23yqN7RuJ5hO50Js4SZh1j56WhTDGjDVaApEXCr1Rz5gju70O7MZljLWTMV5q
	TUnU1bHSS+tex6BpOKtadC7IdhmbLy4cxHxor/lU63X7gIPu4tqkIw94ubsyOfxUPvA==
X-Received: by 2002:a17:902:6b8a:: with SMTP id p10mr17650117plk.109.1552876566836;
        Sun, 17 Mar 2019 19:36:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6JsT8CNJB5TuuiT3ab6mN4rfw5qPG3L72hiZdKoe1IV4zE2v/BPFbCAhOUZVFdUmoMIVg
X-Received: by 2002:a17:902:6b8a:: with SMTP id p10mr17650065plk.109.1552876565951;
        Sun, 17 Mar 2019 19:36:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552876565; cv=none;
        d=google.com; s=arc-20160816;
        b=YyF/t2dIPlnKS4rSQ8bElPSBNdaA8x+ncF+WUaJYmfMlIxaMnexlBmbP43P89zk952
         1Y5ilhlXxy/Cswo5p5UaflYoSaN1EZgHQi5i+LvUOWRNvCT1ANAZOY6pMOJLo8wCfjDU
         L4JsEKhcc66iKjr+fgimH6WdVOCfWzt6vsfeiRDXScKox77h5K7J1/1Tf3MBg9p/RZch
         HjO5IOqqfkMgL8rt/SRfALshWGbipQJbPNhSH8ol4XCmGfXXFbfjIoAtAXf9o76EZX3A
         K0D3ZuYKX6nX6xPkZB6FptKcOudNeGOunEz9amnod+xWnrsw/HBzLoIWaQJl8HJ2CyGU
         e+QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kyMwtL6l+E6laFOjdhzDjY7ZhAMUjFdLnnCnR8EJtfw=;
        b=JNndjUkzJvZjzEif3eyNxxzQ6oRN1D7mLOAvPqOEfLHjhFllhdT0U51Cw8rGJWGEFf
         IkHr1VvBWnC2p6ccmZ8vFOQV2WQSiVD/mlBEYFak13cVKsFD62x+JwFJAS6eojIFOSjw
         O6ETDCb82nB3V1WU6qtKI5TQgSH4xbpocZ0RFThDkjUqTxwzUcI+BU9hj+MFyXTuZ5nX
         fEiThYWQi/m7G3JyM6CRLOlvd19KTD40Igr8oqqZEpR2EQ+k2eMniZOTxaSORiYxqTYo
         /CTQH3BW0zbMsyGB4KprArTVA5yU3Qs8g17LAhvumXpnKBtL1HHX8Web/5WaPqeV29Xs
         KNVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id j71si8521384pfc.280.2019.03.17.19.36.05
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
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Mar 2019 19:36:05 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,491,1544515200"; 
   d="scan'208";a="155877427"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 17 Mar 2019 19:36:05 -0700
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
Subject: [RESEND 6/7] IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Sun, 17 Mar 2019 11:34:37 -0700
Message-Id: <20190317183438.2057-7-ira.weiny@intel.com>
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

