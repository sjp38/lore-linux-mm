Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C27F5C19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78AEF2182B
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:49:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vl3ziFls"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78AEF2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BA4F6B0269; Sun,  4 Aug 2019 18:49:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F8156B026A; Sun,  4 Aug 2019 18:49:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 624616B026B; Sun,  4 Aug 2019 18:49:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23F466B0269
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:38 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so52224754pff.8
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=E2/bhBl19hW4Gg0w7fc9jknd4kP7Gzr9dm6eVnCP9gvP61ydoERNlYMouZM9hIntrl
         tso19LltDqJoXlfi61xFTmywdO0aYVtHbUi0tFi+vT5dA/K6GEGgaF3T8+QOJ1okYEgg
         PePnVzYjn5QPo0e2W5G7hWCyrtA/Vll8SthvW+PxxkY7H8Ynt19xjlsgc3Eez4HFe96f
         INWSmx3kvE9xEycHHovAMTVzlNNwFnAiXYBhkH4CmHO1XFcXwT7RHZoeu6EsgFkShUx7
         x1cYml9WowMdvk3Qeoca4G8YNumQF9A5Ka5Q6NigwHP9+eEBRoFk4KJGQLJEzY6s71v7
         Ld/Q==
X-Gm-Message-State: APjAAAUhFBvISSK6004yTc4qp51GHI5B5qdMikGafRm1HD3fiFfRIPwn
	y3zlFWo6X7IaDKN4JpkrgvALwNyO0YoBD0+ycfPGKADoM7H27tr+g9vGxt5tEylyiGEPFlb+htZ
	tJE7yg/Ze0XbYwoOZ0vf4qgC+nplprPJZYwfkixI2EXKxJMtkJsBXJtYq1DeWY2EjLQ==
X-Received: by 2002:a62:2aca:: with SMTP id q193mr71727873pfq.209.1564958977843;
        Sun, 04 Aug 2019 15:49:37 -0700 (PDT)
X-Received: by 2002:a62:2aca:: with SMTP id q193mr71727847pfq.209.1564958977013;
        Sun, 04 Aug 2019 15:49:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958977; cv=none;
        d=google.com; s=arc-20160816;
        b=0gi9D34B0cNR5pfNcVhpcmNDd/WTZTUzs5urXspgpi5NhEUS5Fd4sKDookz9ydDRFy
         OSHr9GOB77ErnWTjE6BFxDxhnWRSTtHG0J3bk5NVILqZD+xPT6hc6UKx3/qmBJBT8QZM
         T4F627wbwQ3L0Wjxs2xLfNT2I1h+/9Wqnqkto5QlQaVfH3yNDNhFoLgF0d7KIJM2PdmY
         QRV83REb50ohYfNbdqSdAO7m3rpFgSayWgeK4kIVaf7p4eN3b0ce5/908QN5YsyxCt3D
         gOELIHXyg41efSd5Fcqj7wW4mbwgu2Bf7zDehZWN5k61NhhPdNYtcn+sN48zdJp+MeEb
         iRtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=hSF4VmAkNUgWFlErHGE/xjcbiG26gXFdKIdP0K0qY2g8OdyEXmn2pjvq+EWOJXEot9
         B+l0qEb/WnSaJ7koTF4kgJwNulx3kjw7zapky5B0mqLqcmRNjnKHjVfYgOOzrb0yXXAS
         ZZFrgh44CkbIqhhLyfLDrB8gkoVEbC/57yFij+ob0YtaCoVoEhZQD2LlWlauZSgYRF6B
         ssN9lYOIglLxpn+zhmhrX3VVfs5V5xmO1n0lRJWqEuRRMEyZd3kNhRAdrryhwDHUe8+P
         9GFq/DazxMMGU5v699NvFoNs14zLjp2pKUwqsGmrB8J5nw4N7Z5VvF8Zb6WfX1VfbeNV
         Slrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vl3ziFls;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor18155867pjp.16.2019.08.04.15.49.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Vl3ziFls;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=34zW6BJN89MycamN6XZc+aPi3iIpUXsyW4mngm2d11Q=;
        b=Vl3ziFlsVP8d5c8y0YmW6fDZsGTWTBWfBuMUsCvUNMfO41hPRu5nz6knOx+9Exr4dm
         faLIZ6PGv5svewcMn6NrpUtC2sVsC+7jyMTiSPQOkMWSlMNBGkEc5Hzdhl1GLUQ+lU00
         s8/u7LPhlwjUp5vP9Cq58ZxyRYaJggFlYisUFFtIS444ycMw8U/APZaIEYWga3Yussps
         tKIhHu6BLxxDR9A3QUeopRp/JQJFEZSB+ASswX2FluN7nR+bVi9w3B9Wm/JRet3KnCM9
         BzOgVm6BdbLPf53jqaXQstPr6PLJxFbgM+ClIPWs4p2Wp5bWVtpTaVjy3ylfOWo6XjbI
         VLCQ==
X-Google-Smtp-Source: APXvYqzZzuc1CJxZdFJgWU/FwmUoZ/p878RlqbCeEzJ5+atuTCZn+89D3JrxmbErf1XY9IXgA3NZ2A==
X-Received: by 2002:a17:90a:f498:: with SMTP id bx24mr15350312pjb.91.1564958976783;
        Sun, 04 Aug 2019 15:49:36 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:36 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Sudeep Dutt <sudeep.dutt@intel.com>,
	Ashutosh Dixit <ashutosh.dixit@intel.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Joerg Roedel <jroedel@suse.de>,
	Robin Murphy <robin.murphy@arm.com>,
	Zhen Lei <thunder.leizhen@huawei.com>
Subject: [PATCH v2 11/34] scif: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:48:52 -0700
Message-Id: <20190804224915.28669-12-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Zhen Lei <thunder.leizhen@huawei.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/misc/mic/scif/scif_rma.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 01e27682ea30..d84ed9466920 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -113,13 +113,14 @@ static int scif_destroy_pinned_pages(struct scif_pinned_pages *pin)
 	int writeable = pin->prot & SCIF_PROT_WRITE;
 	int kernel = SCIF_MAP_KERNEL & pin->map_flags;
 
-	for (j = 0; j < pin->nr_pages; j++) {
-		if (pin->pages[j] && !kernel) {
+	if (kernel) {
+		for (j = 0; j < pin->nr_pages; j++) {
 			if (writeable)
-				SetPageDirty(pin->pages[j]);
+				set_page_dirty_lock(pin->pages[j]);
 			put_page(pin->pages[j]);
 		}
-	}
+	} else
+		put_user_pages_dirty_lock(pin->pages, pin->nr_pages, writeable);
 
 	scif_free(pin->pages,
 		  pin->nr_pages * sizeof(*pin->pages));
@@ -1385,11 +1386,9 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				if (ulimit)
 					__scif_dec_pinned_vm_lock(mm, nr_pages);
 				/* Roll back any pinned pages */
-				for (i = 0; i < pinned_pages->nr_pages; i++) {
-					if (pinned_pages->pages[i])
-						put_page(
-						pinned_pages->pages[i]);
-				}
+				put_user_pages(pinned_pages->pages,
+					       pinned_pages->nr_pages);
+
 				prot &= ~SCIF_PROT_WRITE;
 				try_upgrade = false;
 				goto retry;
-- 
2.22.0

