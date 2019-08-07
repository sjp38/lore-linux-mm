Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5665CC32758
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04FAD2187F
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X+oC46vd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04FAD2187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAF2E6B027A; Tue,  6 Aug 2019 21:34:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D375C6B027B; Tue,  6 Aug 2019 21:34:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9EC46B027C; Tue,  6 Aug 2019 21:34:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 707576B027A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 28so5525278pgm.12
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=CSgylg5qo423jqUoUlQE5UDq32uuQEf3cPUs39Kl1TI7xBVBM3aJMD0NOw6OpBpUp+
         WlNJFRg4T1SKKciQ9B1Obei1pY/7MdV/J3jmrpqhHaL2v6Dc06Ae6Vgb5Q52FC8IqBA8
         UhOfmuD5q/YN9pD4pndyGuryx0gtZq82bRQHkGl20PLydMsFEIpAsyta9EoAs2pCYK+7
         v6rJlC3zExZljOPn+AS+MXDKT8lcnpm+CLn+G/Araw8B1bH3E6JMFdZJDprW4MHg6P0V
         Jeaia6bxZVafpNmuRMYlcOSx+RrzR0ijTHEs0kHwiObhwDDS+axe/+9BdP80ORALTLb6
         T6Jw==
X-Gm-Message-State: APjAAAXWNYFUSrvrbti603M9bqnYTwNX7ds7fW+3is2ARqrEMQVCSAB9
	/9mM4mJ/eqnPPppKqXyKPRXOKVxkCNUtIuvcXCviDVUVBUDn/QGMv/KxbU6m8CcO3AIkmPhyz+r
	b8VQlye6IWunxomUWUF+3E2cE/jX1X4UxXgj2WynZs3AIaf9hw/6A62QhaEPQmQuNHw==
X-Received: by 2002:a17:902:9349:: with SMTP id g9mr5793508plp.262.1565141669136;
        Tue, 06 Aug 2019 18:34:29 -0700 (PDT)
X-Received: by 2002:a17:902:9349:: with SMTP id g9mr5793480plp.262.1565141668490;
        Tue, 06 Aug 2019 18:34:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141668; cv=none;
        d=google.com; s=arc-20160816;
        b=LyzPJi7dnypsXSMoQvvkr1dddwdvCdUZDI5QMX/qn2rpbKtbve7zoDea9894b81hjs
         fI6CehGob+yrq73oku2Fn+7QjjUHJ7w/WEK9I/Kzb32BwDvxf3iVy86OWYMTyckDxE1a
         XB88pVyOPxbrmVgxEBUme3Uh85ATsyWT/Qw/tx3zD+Jm1tWNUCoqyKtldYMqYgfXhvHH
         07Ew5qqoxa28uV8epm7i7rr2l+IQiYU6HdKpC+rxCyA9S2qR7zsK00CqbHAQ0gdP1iXY
         nVPEfLqqAIeQ2PILFHTpbW2fo6v75h7Sxd2fUHsJajqq0qXuGzRZX93R9iPe7ld22pQb
         a1iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=JSap2DssUS9HNHjtiudwGh6sQ9397YQ6cyQ+bxLtJBKAs4R7+z+tUQd1B6GYQzzaPx
         LQUMv8B4g5Q7tvmupnZdCtwu9WDzk+B63nvj2feWHFd5pocyUeD/Wx4cMWXUlj9pkACS
         PGGnoc9GjtOVF/itEGg3G3Irb6RpLixGJjhGmQQEJeq7xkYmBpnzqE/IE/VW/VpA5LMG
         a4Jvfqg9d9SGko3CCKZLD/CHS6/xxLt48gme1qfrFPaz9bP4J4zm3xUFRd/PgRK70u2l
         w31U/dkxuIBUZw+h3fo7d0qn2rJZr1BrbFqK6JaWwImuM3j4IguwodAjZbHD2yp0dWeb
         6bqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X+oC46vd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 67sor42553558pfd.15.2019.08.06.18.34.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X+oC46vd;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=XDFswRI13oGzit66yuxshlgOj+nOKd4gwJhAdxr7MGM=;
        b=X+oC46vd7xsqyIlCfk9jfvvzV6KsruG8Ld3KbyZxbsoEi8/HO1GbnyS051djmD0t5e
         IHHS/+1UxUZwPEi5YIHD09i1hw+sYQFPMWL5MXVDvXn8jTsvyuss+94LZL/cM8p3bjpq
         d4b4EaFpAv2r0fuq82w4gX6G8xDhtpwliffNpgIRnaMzTN6SuMgZ7nNfOclK8ThivKOZ
         7xyX43NI19Uw1hhV+vBLTAkRAlmFP4cWwG7rBuQsdFHL+GJXdhmd4ykYSxe8XYPo9VdG
         z0ekXKuUssjo5Om7rTdk/VGJmbSK9hbVth13oi1xkOKAckGir4q2yshriVnE4uLo3fC5
         EABw==
X-Google-Smtp-Source: APXvYqyNVjxjb1rRFJ4zL7VZgTd8hKKqHIiZI2K7th6msFTgZFcONMzTsZWyvyMWu34CEbDocoskag==
X-Received: by 2002:a65:5202:: with SMTP id o2mr5279108pgp.29.1565141668202;
        Tue, 06 Aug 2019 18:34:28 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:27 -0700 (PDT)
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
	Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 27/41] mm/frame_vector.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:26 -0700
Message-Id: <20190807013340.9706-28-jhubbard@nvidia.com>
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

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/frame_vector.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/frame_vector.c b/mm/frame_vector.c
index c64dca6e27c2..f590badac776 100644
--- a/mm/frame_vector.c
+++ b/mm/frame_vector.c
@@ -120,7 +120,6 @@ EXPORT_SYMBOL(get_vaddr_frames);
  */
 void put_vaddr_frames(struct frame_vector *vec)
 {
-	int i;
 	struct page **pages;
 
 	if (!vec->got_ref)
@@ -133,8 +132,7 @@ void put_vaddr_frames(struct frame_vector *vec)
 	 */
 	if (WARN_ON(IS_ERR(pages)))
 		goto out;
-	for (i = 0; i < vec->nr_frames; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, vec->nr_frames);
 	vec->got_ref = false;
 out:
 	vec->nr_frames = 0;
-- 
2.22.0

