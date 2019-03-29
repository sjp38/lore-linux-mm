Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C89C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:29:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DBBD20645
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:29:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DBBD20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B91366B000D; Fri, 29 Mar 2019 04:29:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3FFE6B000E; Fri, 29 Mar 2019 04:29:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56586B0010; Fri, 29 Mar 2019 04:29:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84F1B6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:29:27 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id h51so1473854qte.22
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:29:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=5twMoMjMOvf9bw1OR0G5ZaTFhu7W5fUrKujt+S6RwVQ=;
        b=X+pWNAcxQgDTQlRFm6/KIoCw+cAE4ggOHySNQN0+RB8iNqKbIyWIgwkCDiuu8UDSk/
         a3cgwgu6tBhQwocckKF+TTISdmJraG/ix7W2CaZmz/lOLV2gRcyrAcSbbLxbndGa8WjY
         DfDcoLzfcTrlfZ+uu2Kwt4PwSEL3cuPLAFPmEjxQ+SkpJjJTePxMmuCKdySfWOeQd4cH
         S1pbT5H5dvxJBhrFLDxKBImgO8U5YpivTRSBDnMohA2xwyYNTGkRGh/96fCWfS7JAoXP
         f8v6tmpsKEsLJHvxuDciNG9dHgD18aHNy+2xeaoHI+ydpJipOk6C+gUkUBUkua6QxT3l
         aRUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXazXw5medwLbAXnWYz5hLCaa+mkVewDA6AyWmqXMbFnILtA2oQ
	xEukdEkO2EyrHsqrmf3p6NZqVRIrRTNegdP7jH558mJN2s5pjBA/ZyV3PtM8XcofY6rCNJeojw8
	jobguzH61wo3gnB7H+XlZdeaglHQC6jRaSGvaA1inYjzSZ4bQyqM+X+mi1jn7lmvXSA==
X-Received: by 2002:a37:a94c:: with SMTP id s73mr37099188qke.76.1553848167343;
        Fri, 29 Mar 2019 01:29:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRwu3tudveA9KYwPk4M6mPANusbtyh13w0mjUQUDIyq9fd4s+x6Wfd40+YaKl0x3mBNFHw
X-Received: by 2002:a37:a94c:: with SMTP id s73mr37099155qke.76.1553848166498;
        Fri, 29 Mar 2019 01:29:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553848166; cv=none;
        d=google.com; s=arc-20160816;
        b=EP2hn5UtRpFe70wQrsndnU5RvbAlWmP3WFguWf6WPVd/sKlU+hmBn7CW2TPnHVjpya
         nGd/a+d/tLuQpB3k/2GFwSFUq/V5ERX85bmAMZ3m4pv4dD9qt5f4fgBjZPI1/lFW15+x
         izgu2/hUauhcGO5iAzxEKsMkbjXWSOcA+LIpGUFCuaoW0OPbOiCkr9hJsvTfXzgXYeaA
         6xXNZ3RBqCvInbk2GvTgHE9bJ/D5hR+hcxgcq6PoN7mqB3uIt6qkVUJQqvrQrnIaqIM3
         VnLRzp0pGFVBVkz35QVW1XzAtDNx7nLcPYtqBdUT32eO0WY/pl/GHITGN/8u74oqx/jG
         gVmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=5twMoMjMOvf9bw1OR0G5ZaTFhu7W5fUrKujt+S6RwVQ=;
        b=rrjm8lVJ+TkUQDg/B4jT+/RmQhFS79M9ko21wd+Yms5gzRDO9CMj3jMy282QCMXBhN
         g60r3f/smIhgNNYB4ysIQu7s7P+FPxJ6Sji+fOatNn6pvYOMO/4V8wz7oL83i/z4ftsl
         uH380F/CuFDyFYpvAMOysuKhjoJyrgGMEbEZBFv91cDtkAw4YEJwCPDbnUkQzHd6k4mt
         3GzbqPgnxWwDV24EbBi1tdiT9FippGjfXiIuPtuRLF+6j+tIVQSZ8HC5LMjwL+dqdXjq
         EW1g0g2VeDCkUnTedI4RMLlNAgHztqzsqS5FBP8aJIX7y58g6Cg61PvnyJemw3jpsNTi
         iSWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a8si882363qtb.82.2019.03.29.01.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:29:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A8FEF1E319;
	Fri, 29 Mar 2019 08:29:25 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CE0935D961;
	Fri, 29 Mar 2019 08:29:21 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	rafael@kernel.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	osalvador@suse.de,
	rppt@linux.ibm.com,
	willy@infradead.org,
	fanc.fnst@cn.fujitsu.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 2/2] drivers/base/memory.c: Rename the misleading parameter
Date: Fri, 29 Mar 2019 16:29:15 +0800
Message-Id: <20190329082915.19763-2-bhe@redhat.com>
In-Reply-To: <20190329082915.19763-1-bhe@redhat.com>
References: <20190329082915.19763-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Fri, 29 Mar 2019 08:29:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The input parameter 'phys_index' of memory_block_action() is actually
the section number, but not the phys_index of memory_block. Fix it.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
v2->v3:
  Rename the parameter to 'start_section_nr' from 'sec'.

 drivers/base/memory.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb8347500ce2..9ea972b2ae79 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -231,13 +231,14 @@ static bool pages_correctly_probed(unsigned long start_pfn)
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
+memory_block_action(unsigned long start_section_nr, unsigned long action,
+		    int online_type)
 {
 	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	int ret;
 
-	start_pfn = section_nr_to_pfn(phys_index);
+	start_pfn = section_nr_to_pfn(start_section_nr);
 
 	switch (action) {
 	case MEM_ONLINE:
@@ -251,7 +252,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 		break;
 	default:
 		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
-		     "%ld\n", __func__, phys_index, action, action);
+		     "%ld\n", __func__, start_section_nr, action, action);
 		ret = -EINVAL;
 	}
 
-- 
2.17.2

