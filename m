Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9844BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 568622147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 568622147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9D368E0005; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D23AE8E0008; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A1C68E0005; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3EE308E0006
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:30:52 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id b12so5872874pgj.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:30:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=HTY81QnsRuz1UP0B+Fcdj7NDqi845JtDjYkbBTbpD1F0lRs7qwCFPjKGAeGmB5QzvP
         vr8U4Nkk1MmqOfpRTHta3d/3DP5QKPFekKm849vDYAQNN7YhaRiwOKu0u4P9nFiYQIxO
         r+fIkzgqikh5LF1SwMcwUijGRUFuOxdsXejqjxJ1HlK6GntDe4o8My7IlCrpWfBdI8Hc
         LFkVCjoh56BfDFDeP/oLflPjiexsCyOFEDTw5IrbUP4vz7OZmRBWkmhakw/AlHJOvnjN
         2amEI+d4x37KA8r32QLEuLsmiGKf1GSETp8958Q16wo053EZuhcnLdJm3kH1tk4I/aE8
         5t6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuadhm8XHpm6npXgHWi5h7E5Lm5eYostipFao2hhoQHFcELaWYxT
	31NAZAhiGP2MVGT8GkklOLP6dmm/EIUVQ3mrlm87vLA19x4PQW8FGb3kkjbricT05k196WIQuZi
	uRVNKu4+jxp5ftaMW+SUa1PvncUf/DlWoOdBQ7+0A6h10P9hE5aRaegxaWfAq0cuyrQ==
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr22237486plx.186.1550640651956;
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia9fqd1OUMhjQLCbWg+ECRMgAbFcGyKH21qBoH75rUcPe1ncu2WtDKTy2SmBo/D4Dgr9CyF
X-Received: by 2002:a17:902:bd43:: with SMTP id b3mr22237438plx.186.1550640651121;
        Tue, 19 Feb 2019 21:30:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640651; cv=none;
        d=google.com; s=arc-20160816;
        b=J9qtMuor5IqYXg0jf/BVi/CFLG5Eo2zYFh4KlgRcfyikeYDuaZcguZb/H8FvNoVGwq
         fzpxDOcI1hyOsa0TCo2R/zaTCBWAEqO0pyQNsrRGfxhwASt2kGEwa2BojURR4iLCoeak
         5MmE0Ppkiv+LVQJpKi6pLAuCmeW8ZIJt1VhtY2bb0tLxVhACOTQwxfLnAwr/3UR3m+eh
         0hMFbZQaM5wkjOUciu/nlBWcOv2iQT4maUs1KpybO+FHaanMTPeI6xIFEP55SU6c7bZP
         KsGAZGsWSfNHcSDd8wcDnK6NH3NBxCm2gW7WlcpPgDgFg+HX12sA03XVmHXHGissGe+N
         HORg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NxuweNm4GxL/BoOqBVX9oI0qswOBhm+J5hpwG3wNYwI=;
        b=yvgcUSrifBpdquBfQs9DtLdCJw4NFxugzGlEEQCA/PrpPc9bVMC2Cm7+xFK3sW1pJF
         6T3si0aZx2OZq9hLTmM1MjndIkYr3BwQDUAlChDkE+y4D5K7REfN7+4E0dmUi1sFkHt6
         UBX8Ka765n+PL+zi61Z8kGIEGw66bDaUtJUqgDGGiDXK2aazm0Zj2ZXnKAR76/4RmCLQ
         hIwmgj5ylf9EJjz8cEeOYew26AqXeUl1QkqdyKnzDTtxmNOmEjts/ruUhr1TPXpqia1M
         HDbEmD0ur6yawRTIvBo78DL7zpNbIM8zq7Vmy2te27P1zS3cja13ky27rpTGNKg7HKMc
         4kdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id e17si17976549pgd.109.2019.02.19.21.30.50
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
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 Feb 2019 21:30:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,388,1544515200"; 
   d="scan'208";a="144924916"
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
Subject: [RESEND PATCH 5/7] IB/hfi1: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
Date: Tue, 19 Feb 2019 21:30:38 -0800
Message-Id: <20190220053040.10831-6-ira.weiny@intel.com>
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

