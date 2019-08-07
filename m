Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8327FC32758
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39AAA2173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L/mKoqNB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39AAA2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 413276B0277; Tue,  6 Aug 2019 21:34:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C1A16B0278; Tue,  6 Aug 2019 21:34:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 179976B0279; Tue,  6 Aug 2019 21:34:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D36956B0277
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id k9so49423374pls.13
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=TT9mhYjy5Dh4fO5nHAI1kIM1OYgAuzR5aV3CzzJr+zWbbdl13B9K5b1TRdXP3gVsYj
         Sk2CKVjPJdOywAiN8OP+gVTs1pZw6LykjzU67RxjpWMh8SwYyArUznFoX9tqVq5Fhc2F
         DajbKq/W6/S7/xvnBBlDwwNmV8jNHmN1PK6rXw1qMyQlHGuavxH2QAPGKZzsD0dh9G8U
         mjzqajGxBCoVp7+2ssazdjQHdSxkeAHxGP4ZwDdkNytDh8D5r5+Ab5rMDaO62Kqo4PSm
         4vqQaEFCqozEg0yGHJWEJMJEnoavKA9FLaUdU7oRGHBtNywnRmvi+IzhrTbdNANtYCcZ
         EsiQ==
X-Gm-Message-State: APjAAAVzG08aNlk33QQZWqyoC00vTfsYzsgc4/86zaELxXK6iduQlM/W
	Ylk5FOUi4n2r3O2teQeF28BW8N6H6rlyr7YDMmiFw/2rqGitMYTF2Dit8ZWHAq6Y224bQxYvhd+
	/AyxHPVaRF/iYK2uuC3ZzCNNL/UNHx1gEXothxDm0YVvJ5/GtkWI4DwOcToNLRP4XfQ==
X-Received: by 2002:a62:e815:: with SMTP id c21mr6978966pfi.244.1565141664560;
        Tue, 06 Aug 2019 18:34:24 -0700 (PDT)
X-Received: by 2002:a62:e815:: with SMTP id c21mr6978889pfi.244.1565141663550;
        Tue, 06 Aug 2019 18:34:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141663; cv=none;
        d=google.com; s=arc-20160816;
        b=pC9vNpAwDUTWhaBdM8NGEdto7EabyY6SQxdRDJMkqVRVjTRaEPb22XJZthwBXVkJ6N
         MkPglxX4HJ6PqzgXuGtH6eahNIYUYjqPp1GuB9lJqod3c9smsJ4Uztqb2sz8xOYxYa2L
         oSj0FZ5sw7MXNl1hpgcatSydFoS0V5HokVXUuAVxt9muV209HQS1GBpdhvMSaSUdhxRo
         ysmp3zaesjJtvpK2RkvuN5ez0+pPz4z33dRPKwdrw9ix+Ie7ivIJsg9Y4absfG/hmeh5
         owSCFMgSDdZ50ETbAmbyzLacPfPwY92dnyzYxz1r0/KtDLeF9wXkfg+/JDDwk+QWkz29
         eJ5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=tyH1p846VuwrsVZ11uxyKXPjsbFwVXeTECH880jsDpOmuPTUQoymq1JyhCpy6QHYUm
         eFDIVllc+8Z1hFshtl7KOUhC8RqtgnFsMgE4n5IUhri2jA2mQ55snrF2B9l61M8SN726
         XxW7mwRuVBmOEwvEEaUuXv8R05Hew3teyl44/mT1+IZxAPx+JpW1x+HzDpmXKQEJCYC2
         Ogdn2XqwJzCguwKJOXoe6M9hHG/jHndbSmToS8Uby67GnKxk4L3n4bkvZTRDAve7bhn9
         ns7uZeXelg6A64gLabh2G3X0U1YJ38xf3XONTwRFOwyeVPVvi7DAkKZe4j+pFyu3b4/z
         gRLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="L/mKoqNB";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 11sor96764355plc.47.2019.08.06.18.34.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="L/mKoqNB";
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=3zvxFRr3gjg9t3ZKCwZWoMY3PeLUGF9FofBT0j+JfJs=;
        b=L/mKoqNBpvGTGBp3epVJp9Jwmcabm5Zof/TP6cMpNTp5QyY/bNS8ra/phjhs5sRAaN
         E5tTttcEItcQL3b5Zem0k5qJxKcKktTUshMTiNWzGKXLywBoBoQ5bitV/RkFpPMu2On5
         4WHRSoAhmad+Sq/Uze+Lrqj/EHMra+wpLWdL/I1wMa19gtn+2FmmEpJ2BiwYWrwVtu4s
         ErDZEb/zzGVZaJO6WBAU6eZcAtQlFXpJrdCTpwcNxdnIPyz2Lta4bzP9L9aVvEMuLhxO
         FtQSTpdSuYFA1RpMOlExoKqI8fe7oDB8Q9BkX/iI0jL+EMoGr57KcyP7PRTXBQFgsK3f
         6S2w==
X-Google-Smtp-Source: APXvYqw776L+7/s1i5+0uj4rHYr4XOYwzb6gLf8HmDykG/CGNwoS9owiEzaUd2cmiWPaV4acbHnsQA==
X-Received: by 2002:a17:902:4683:: with SMTP id p3mr5420824pld.31.1565141663334;
        Tue, 06 Aug 2019 18:34:23 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.21
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:22 -0700 (PDT)
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
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>
Subject: [PATCH v3 24/41] orangefs: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:23 -0700
Message-Id: <20190807013340.9706-25-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
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

Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: devel@lists.orangefs.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 fs/orangefs/orangefs-bufmap.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/orangefs/orangefs-bufmap.c b/fs/orangefs/orangefs-bufmap.c
index 2bb916d68576..f2f33a16d604 100644
--- a/fs/orangefs/orangefs-bufmap.c
+++ b/fs/orangefs/orangefs-bufmap.c
@@ -168,10 +168,7 @@ static DEFINE_SPINLOCK(orangefs_bufmap_lock);
 static void
 orangefs_bufmap_unmap(struct orangefs_bufmap *bufmap)
 {
-	int i;
-
-	for (i = 0; i < bufmap->page_count; i++)
-		put_page(bufmap->page_array[i]);
+	put_user_pages(bufmap->page_array, bufmap->page_count);
 }
 
 static void
@@ -280,7 +277,7 @@ orangefs_bufmap_map(struct orangefs_bufmap *bufmap,
 
 		for (i = 0; i < ret; i++) {
 			SetPageError(bufmap->page_array[i]);
-			put_page(bufmap->page_array[i]);
+			put_user_page(bufmap->page_array[i]);
 		}
 		return -ENOMEM;
 	}
-- 
2.22.0

