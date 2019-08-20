Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F59BC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6587214DA
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6587214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5DEC6B0006; Tue, 20 Aug 2019 12:37:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0DD96B0007; Tue, 20 Aug 2019 12:37:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9251C6B0008; Tue, 20 Aug 2019 12:37:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0084.hostedemail.com [216.40.44.84])
	by kanga.kvack.org (Postfix) with ESMTP id 721226B0006
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:37:34 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0C6CF181AC9BF
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:37:34 +0000 (UTC)
X-FDA: 75843362028.15.kiss46_7c012ea9372f
X-HE-Tag: kiss46_7c012ea9372f
X-Filterd-Recvd-Size: 3114
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:37:33 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id p74so3191004wme.4
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:37:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=E4X7QCNLqGFBsy/7pYjpRVoBo5sZi0bTAtJeoQQ6ohc=;
        b=ay7MBqohICF7ItaQAcLQEXAbxLkD3GLbtKK8+RvK3zyrLt57kIbG3TKGy/hl/D9aAI
         VRuEgKn8EjSwiNNw+OdDXjazEyUKuQreyuZjJdpYsGEDJxOAcn+Kynp7k07P8OpvT7vR
         5y+J4d3S9A2H2i07NierdkVGHwYc2N2PFKLxDSwqlcruFmqOEkZqjj9Tnldwi6BdwfJE
         wGpe7OLhhxuHY1dCB1MUlIyOmJoLe+PPwGKRO4SwzYUhFtl6KFW3d35gmZDCbqgPjBGg
         aG/x6dmIKbojkIMKO/TWcME/s7jVrAW7zqIAfR+y4PoimNp10eoR6cCTeF+7pEimmY0d
         WXvQ==
X-Gm-Message-State: APjAAAVIQ4jASTbe1LcQZF8YzoxAL6ER4LQPfRMCgy73EylJA8XRrZuW
	KcJvLvOIn/PXUG/9uDNwT9E=
X-Google-Smtp-Source: APXvYqyWdL5QMRDrlWABWdxtx+qi5mJSVMhKc+4wusrmLOkgTE8w+/nuZlj5Jc1f8al4Vo4HPQPOEQ==
X-Received: by 2002:a1c:2dcf:: with SMTP id t198mr858820wmt.147.1566319051721;
        Tue, 20 Aug 2019 09:37:31 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id n14sm58485385wra.75.2019.08.20.09.37.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 09:37:31 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Nadav Amit <namit@vmware.com>
Subject: [PATCH] mm/balloon_compaction: suppress allocation warnings
Date: Tue, 20 Aug 2019 02:16:46 -0700
Message-Id: <20190820091646.29642-1-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is no reason to print warnings when balloon page allocation fails,
as they are expected and can be handled gracefully.  Since VMware
balloon now uses balloon-compaction infrastructure, and suppressed these
warnings before, it is also beneficial to suppress these warnings to
keep the same behavior that the balloon had before.

Cc: Jason Wang <jasowang@redhat.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
---
 mm/balloon_compaction.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index 798275a51887..26de020aae7b 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -124,7 +124,8 @@ EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
 struct page *balloon_page_alloc(void)
 {
 	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-				       __GFP_NOMEMALLOC | __GFP_NORETRY);
+				       __GFP_NOMEMALLOC | __GFP_NORETRY |
+				       __GFP_NOWARN);
 	return page;
 }
 EXPORT_SYMBOL_GPL(balloon_page_alloc);
-- 
2.19.1


