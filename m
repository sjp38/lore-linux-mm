Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50FA1C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:41:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C3F82190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:41:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WXncvnAf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C3F82190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC73C8E0001; Mon, 22 Jul 2019 05:41:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A78646B0266; Mon, 22 Jul 2019 05:41:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9680F8E0001; Mon, 22 Jul 2019 05:41:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 647C36B000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:41:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i27so23523161pfk.12
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:41:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=uuCke/m1jxxr5tTC/Z7FAkFIKWk99JBUnhxnHFx1S5k=;
        b=oyE99z7JVItwE5KKgCS16/0Jqn4MVb+Ku2TEh/inui7tvPqDKBJBHl6l8ro1HsLMiq
         wZNXFsV4TwSXV6uHQAyneooFz524FJuCidEfPTBgWcwL03ohIfq70RlBqf7mv6pEhhia
         3Tv/0n2wDg+NJs6STwFVCsJni4Ny9uuIaGkOII8DkA/I3c33lfw+qcLYpL7pwBeDgJjH
         4KfBf6MneVViY7g6TDnUZZsRxxMftFx0/nc5chumbjZ6suoeW7TunDj7B/al7SUT9BMM
         HYB/gQOSGsoO0tuZBZHR+fidaNSWkUj0OUwKEggeVIUkux+vTYv8V0qJ5aXKpJbujJ6d
         Pgbw==
X-Gm-Message-State: APjAAAWbjt5RSsmGiOA4Z/vscUk/hRu+0ItByQcKiOzY4XrTcCBD8tsV
	yidFfZwe++iDgPMf3cPQ1Yx9xmac6PPj3pPG3i4rkDkHpFEiDICjvDM3ck7aKQJIeYb+w0jivR6
	aRx5ruRybPQ9doLwWezkTGOEG2GPXievoipNMJ7pQi7g4LZx2Ig+zZEuhD8Ep6qc=
X-Received: by 2002:a17:902:e512:: with SMTP id ck18mr70653942plb.53.1563788507901;
        Mon, 22 Jul 2019 02:41:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc8AdAx9Z2ziu+mvOlKa4XB00bMKDy/HNOZupzD1zWzhxqxgPcbUCwjNyamvgqmKvoNxb0
X-Received: by 2002:a17:902:e512:: with SMTP id ck18mr70653896plb.53.1563788507304;
        Mon, 22 Jul 2019 02:41:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563788507; cv=none;
        d=google.com; s=arc-20160816;
        b=oRjEJ8qpaLXY1WTU1LHKX7yJHIkxKp8fUEc9seFuAbommiWe8WnzY/3MAom3j6400W
         GXaqZM9cVPKGcUcwkj9DW/+gluXLFB4oTs3VoL5aKv0gcExnCQRGlNrbzsI5aQZYF5Gi
         Z4tv73GtrldUJYD9j76JsX4Mgn7gMFOBtSnMqmDiKbmrUxj/bg65scdw3cvyt9LRmIS6
         /Lb49Q9IUXQ32lwsfE3xJlAxG2N9p3BwhBdknn6lChCZhQeL5n6sKOf6teGu7RNgxUKw
         L/SFSyfeTzFm84K7wdqF13nqniYhVR0XNp6h0Dk6W6CzGfj/5HRZDX0Ljtqw9e52yKmw
         cr+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=uuCke/m1jxxr5tTC/Z7FAkFIKWk99JBUnhxnHFx1S5k=;
        b=xlF1S03oiRGT9pDHUYlBigEkLQOjTqGnUBtjL/METerT4BFlDy99PVSKjYrmyuMeNH
         BLdsLnA4d1+SGv+Iqm5b5xjD1GSemmVqypfNgeFzFKu9YiWDxRTp16xdoD7tYfkDk4U6
         3D+3yWmeBCT2HAD3Lx3P3DyJdvxzXtienagba2F0ylr/sZNpAKU4AT9XIRMGuN5dK7E8
         Ej3wzaxtzTRbHA6Aaz31H7Egaf8aMK0fY4F2oG65t0qBwca7lVYtutZwShefhpLQVBaW
         TTtiF9OHH3GvMa7LK3UvUR5Y1749XhymeeaOg08uQW6TSxnEHUF/krLXRfOjaCyNYbpC
         3J4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WXncvnAf;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t20si8165584pjr.107.2019.07.22.02.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 22 Jul 2019 02:41:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WXncvnAf;
       spf=pass (google.com: best guess record for domain of batv+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8b691fc55bcfc6b3008b+5811+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uuCke/m1jxxr5tTC/Z7FAkFIKWk99JBUnhxnHFx1S5k=; b=WXncvnAfRIhXiNhfTvFgzTSrF
	ZeDnrZaWqROY3q3TyF6+hGQSvWWIqJD7MeOQoMk2WZfLDNomf3R8pV6dpv5+mvmHXTpeI0UX4RNUb
	hkDTyr1coiXAyEeAdPb4CXbPQALKGS57XYw9PzDyGdU9Z+CS1erUFKlVunUphg5QtGfA11SuI7rsd
	ChVghFzuHlEUhYWDLVjXggS1uDOscMM3UYgK2ZtbOaIG4ZTTXfRKdD6YE+r6yOBrLNmlIcVbvsbhg
	1PjGys38TyqD6c6dJsU1JVr/v3+VJT097jYWFnAFx4U9ZFuPcYA01JJmQi4DL3qInrz7U/mzTF/F+
	z7WiJCYBg==;
Received: from 089144207240.atnat0016.highway.bob.at ([89.144.207.240] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpUpF-0001Az-4X; Mon, 22 Jul 2019 09:41:45 +0000
From: Christoph Hellwig <hch@lst.de>
To: dan.j.williams@intel.com,
	akpm@linux-foundation.org
Cc: linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] memremap: move from kernel/ to mm/
Date: Mon, 22 Jul 2019 11:41:43 +0200
Message-Id: <20190722094143.18387-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

memremap.c implements MM functionality for ZONE_DEVICE, so it really
should be in the mm/ directory, not the kernel/ one.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---

Sending for applying just after -rc1 preferably to avoid conflicts
later in the merge window

 kernel/Makefile           | 1 -
 mm/Makefile               | 1 +
 {kernel => mm}/memremap.c | 0
 3 files changed, 1 insertion(+), 1 deletion(-)
 rename {kernel => mm}/memremap.c (100%)

diff --git a/kernel/Makefile b/kernel/Makefile
index a8d923b5481b..ef0d95a190b4 100644
--- a/kernel/Makefile
+++ b/kernel/Makefile
@@ -111,7 +111,6 @@ obj-$(CONFIG_CONTEXT_TRACKING) += context_tracking.o
 obj-$(CONFIG_TORTURE_TEST) += torture.o
 
 obj-$(CONFIG_HAS_IOMEM) += iomem.o
-obj-$(CONFIG_ZONE_DEVICE) += memremap.o
 obj-$(CONFIG_RSEQ) += rseq.o
 
 obj-$(CONFIG_GCC_PLUGIN_STACKLEAK) += stackleak.o
diff --git a/mm/Makefile b/mm/Makefile
index 338e528ad436..d0b295c3b764 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -102,5 +102,6 @@ obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
+obj-$(CONFIG_ZONE_DEVICE) += memremap.o
 obj-$(CONFIG_HMM_MIRROR) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
diff --git a/kernel/memremap.c b/mm/memremap.c
similarity index 100%
rename from kernel/memremap.c
rename to mm/memremap.c
-- 
2.20.1

