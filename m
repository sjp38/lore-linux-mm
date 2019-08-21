Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FC67C41514
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:02:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DB2222DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 17:02:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DB2222DD3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB3E46B0325; Wed, 21 Aug 2019 13:02:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8A6E6B0326; Wed, 21 Aug 2019 13:02:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA0AD6B0327; Wed, 21 Aug 2019 13:02:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id AA60D6B0325
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 13:02:53 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3C3F1180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:02:53 +0000 (UTC)
X-FDA: 75847054626.03.shop64_8d902dcc89a05
X-HE-Tag: shop64_8d902dcc89a05
X-Filterd-Recvd-Size: 3571
Received: from mail-pl1-f195.google.com (mail-pl1-f195.google.com [209.85.214.195])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:02:52 +0000 (UTC)
Received: by mail-pl1-f195.google.com with SMTP id f19so1654111plr.3
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:02:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=U6z5UAUGFghdvzjH4C6pX/4JXep5tUCHLfsHPzlx9LA=;
        b=Zd3fcP2qaH+sRUq4svcRztPmWz+nYQZFYyjBrNP9DwIyCQKaF53mxS5dNmykwopLf0
         /9F2+yjb3uE9YEjrIi5FNNSnz4/gfIx1mT+2FlFAMKc1MS3IuIKPSQW1Y3V1+bsxtGGH
         gaH7MNZjxymzjFmqCOJU8f4F3AUAxgGQC3WxuMbRlODNJl3mOzwphw63ufhsy6tOsIKT
         193bWpp/vp5b+0zZg7QbvV0JOogwmuG6XmzFc1UVN2UiPVzHmvbZ3oH3hDVDIJzEXT4U
         AC7ol/GF91qnT4XPiDfYknSKxhPX653Oz5j3hNv6nOtylGlnzmfJBseFXouCIA9K5oe3
         Vxtw==
X-Gm-Message-State: APjAAAU21y/EwUiNn+TRIlJT3FTLbav76hbclhSBfVxirtF5vugU6np7
	lDgyFnCt4bOOa7JCvpY+o5U=
X-Google-Smtp-Source: APXvYqwSHmzMs89oPrC2mo0cPIKVAkb2F9Ln2a5cPO2U0/JORRLOHxSXJwFKQGFE12cP6dDufj9BgA==
X-Received: by 2002:a17:902:e407:: with SMTP id ci7mr20821703plb.326.1566406971488;
        Wed, 21 Aug 2019 10:02:51 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id b18sm15151398pfi.128.2019.08.21.10.02.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Aug 2019 10:02:50 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Nadav Amit <namit@vmware.com>,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v2] mm/balloon_compaction: Informative allocation warnings
Date: Wed, 21 Aug 2019 02:41:59 -0700
Message-Id: <20190821094159.40795-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.010679, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is no reason to print generic warnings when balloon memory
allocation fails, as failures are expected and can be handled
gracefully. Since VMware balloon now uses balloon-compaction
infrastructure, and suppressed these warnings before, it is also
beneficial to suppress these warnings to keep the same behavior that the
balloon had before.

Since such warnings can still be useful to indicate that the balloon is
over-inflated, print more informative and less frightening warning if
allocation fails instead.

Cc: David Hildenbrand <david@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Signed-off-by: Nadav Amit <namit@vmware.com>

---

v1->v2:
  * Print informative warnings instead suppressing [David]
---
 mm/balloon_compaction.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 798275a51887..0c1d1f7689f0 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -124,7 +124,12 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
 struct page *balloon_page_alloc(void)
 {
 	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				       __GFP_NOMEMALLOC | __GFP_NORETRY);
+				       __GFP_NOMEMALLOC | __GFP_NORETRY |
+				       __GFP_NOWARN);
+
+	if (!page)
+		pr_warn_ratelimited("memory balloon: memory allocation failed");
+
 	return page;
 }
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
-- 
2.17.1


