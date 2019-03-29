Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD23C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 12:26:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED07B2183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 12:26:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED07B2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86B556B0010; Fri, 29 Mar 2019 08:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F5016B0269; Fri, 29 Mar 2019 08:26:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BC066B026A; Fri, 29 Mar 2019 08:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42F8A6B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:26:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k5so2065417qte.0
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:26:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=5mOrzRv/HPyQ53b0gSOzKRXcbgqVDdoYfbXz/Rxir5o=;
        b=cxuTbdFvIXH4GF3sWNmry93a2zs5yqsuGHFauV8OHVfxFS8R3VKoS7nC0HsEX4y/UI
         yP3VU1vUUzPuGGInPupicIwVp1cjljDeRYiRwrnD+cCYewpgjl0J9iVLLtSTSquGnHuL
         5dbIsvfsmNTfqjrYs9PiQKqoxN8mTzRfFHJIuKg7G/Ph60oQD94+PVAd+2JISqj7vYs1
         19tGViZICPCLl4h8IY6BJJAAzndcZTDcyy5DoW8hF44ue1EFDohOOdhfrFdzhv9Tn5oL
         go9fTYT8RPXh1P5xfXVs40ciruP01MkVBmkHxAz7eQhx6tu7BCHcf6bYR/gnJZH+7T3I
         72uQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV2liVvCb5mMDYhrZBnLTk6ZZ46K2/6DWe+No02r7q4HivaEkLL
	f22A/XVWjq4JE3UPU+eDXG0Bii3xZ7Wz45ByIosoO7B3xgXMhjzIvMgL7WKjmU7E1nXAmWZFWUZ
	jI6HShcKOg5sMgURXHLkj61JY3gGA+RVEzBXX4o0ClIpDnAMPapl6VuesqOQHHlpCUA==
X-Received: by 2002:ac8:27b0:: with SMTP id w45mr25490345qtw.341.1553862418008;
        Fri, 29 Mar 2019 05:26:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDUIxoi0v8YvevDpoC3cEqEBpcnRUVoRDOUPho8VFD7T8w87sN4PJv8eegvrAOM0ZN/bgO
X-Received: by 2002:ac8:27b0:: with SMTP id w45mr25490294qtw.341.1553862417194;
        Fri, 29 Mar 2019 05:26:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553862417; cv=none;
        d=google.com; s=arc-20160816;
        b=ZEt/Jb2+4drtRk9SI7eWziFtUPz4qumGAD6hOGuG1E93LQ4EUw03t842GyyfBAey7Q
         zeplEm6iYTgVYtq6L9IUmNin097LzqTBN2f7ftycmA5G5wdGvhc2MePtI9fKMOXk+NyX
         i3Co4k+Lty5aSzgyMMF+RjEX7wF+ylE3iI7334NNtnR7hajaCOOC+s2/8azytE95Eep+
         Iv9KGSo+cXRpA5aLovWLXNrDNVuHFq+EKE9Vok1b4Bt3qatEcnb4zkdUahDGkGlExTlU
         VpaLiM4TZ9LrIAl4n6toz5tjv6YTcZhuqk0oaeYHiZpOhJ0T6j/fPRc/qwJg386J9l22
         3uDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=5mOrzRv/HPyQ53b0gSOzKRXcbgqVDdoYfbXz/Rxir5o=;
        b=Odh/ioaszugo1b6HrbWIqKaOBlDvmfqyoN4Ei+7yujWU2C1Ps8DBdwzeUpgXHDJobK
         IwKOEqNCbetmLQhNi3702kZy5yMQPIcyHnINBls9JzoZFf7gZpKtFL3hVrCe2eKvAJzf
         /KWD/tTxBSWTeWCMcaOG7V3ATOGIvgVmIfABfqJR6gbq60+8mIevkvFjWA+E45IeboFf
         2KJcnxz8a1C8sXDDzCzFh6qklFN6QULUGn9d7Ya+xFtQye5cH4JgGguxzS4iHSYOY1TH
         L/BY18ycnLPVXAS3QZLzb42zR/5zoE1wNvVBdHSUt7qZD/eTvZe6vzswTIvIfwT9Cw6u
         wMrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y16si119193qth.296.2019.03.29.05.26.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 05:26:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4FAC2307D914;
	Fri, 29 Mar 2019 12:26:56 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 44CC417991;
	Fri, 29 Mar 2019 12:26:50 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH v1] mm: balloon: drop unused function stubs
Date: Fri, 29 Mar 2019 13:26:49 +0100
Message-Id: <20190329122649.28404-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 29 Mar 2019 12:26:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

These are leftovers from the pre-"general non-lru movable page" era.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/balloon_compaction.h | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
index f111c780ef1d..f31521dcb09a 100644
--- a/include/linux/balloon_compaction.h
+++ b/include/linux/balloon_compaction.h
@@ -151,21 +151,6 @@ static inline void balloon_page_delete(struct page *page)
 	list_del(&page->lru);
 }
 
-static inline bool __is_movable_balloon_page(struct page *page)
-{
-	return false;
-}
-
-static inline bool balloon_page_movable(struct page *page)
-{
-	return false;
-}
-
-static inline bool isolated_balloon_page(struct page *page)
-{
-	return false;
-}
-
 static inline bool balloon_page_isolate(struct page *page)
 {
 	return false;
-- 
2.17.2

