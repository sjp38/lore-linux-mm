Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12EF6C32751
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0BB62089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TnoFvHk+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0BB62089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C13AF6B0283; Sun,  4 Aug 2019 18:50:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9D666B0284; Sun,  4 Aug 2019 18:50:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A19E6B0285; Sun,  4 Aug 2019 18:50:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 60D946B0283
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:11 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n9so47934006pgq.4
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=S37NeLY5NkuBQdgl0dlSCEtry8J5VPSfrRLhcZsy8lDmJKg1xMvM5dMt/wRQ0do6Bz
         TXb0YjdD64ceCo0sBKLgqiXk7IVMTXbXPOioDDoKqN24PpgUjQdjUGug4ybhethnR3gs
         Fi69ww5sM9HbYXXY8N69RlXiFnDkhe+wVH1GQ+gPTWaQn2NY5dL2AujSVA15grcJE8BB
         I0K0X/N5hab+6SIaXVapQ3v6LLjjegx6Yv26ujnbe5HfZBBACOYg+uO7+tAum2OqJEcA
         DeeUwXiPLuyBTh6foTKzUMyd6h65b8SZ72DI46dmulPS7Z8vDe2Y+31Xw118ZqRgaSSX
         bpZA==
X-Gm-Message-State: APjAAAXBvZjVNuUJDhN8aFUex6p8dCZJ/ttzYtbOO/yJpvWCUfpJcvbp
	f4D6S0Y/H8+FNkmRknyvDUyh8DA0tKqCgQZofcGPubDDZ7GNE4fqwM9yDMUWL7XafhjBODIJG3w
	j7fvmjo2S9XNPPniKQK4MCijShSi6MoPfGsU8RF9/mKnwGubdmHv1zAG3+R5KygxuNQ==
X-Received: by 2002:a63:5a0a:: with SMTP id o10mr61594977pgb.282.1564959010998;
        Sun, 04 Aug 2019 15:50:10 -0700 (PDT)
X-Received: by 2002:a63:5a0a:: with SMTP id o10mr61594960pgb.282.1564959010282;
        Sun, 04 Aug 2019 15:50:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959010; cv=none;
        d=google.com; s=arc-20160816;
        b=h4eVmjps6hnXwzOXY6tPuans78bDOTihTFWC3dy31RAwiFKonmAfg5dVUvwJI3P5MC
         aBe/lEjfkRkR2KGSjxMT/x9p5bYo7FDN/+nQK/keeXTelcvFOLa+OHzxgnI2r9R30KoW
         EHrYQKgn8Hl8Ca0UbTMALi/JHCyH6917WqtIZhZb7M6p8lS7aMI5x3amxol61znhBtKM
         XSAAuHC2R38X6g/1igH1B7pP4cQYtZQKPP8oGt9vzBCeWzgrJ2WtFTt9xrVYwUNbqCYP
         G1w+MkafTs5mudGEtOpGZvgQHWbjdHU0ZDhlEviDLUdqhEaRoFQ56wCwfOHSKyzOo3bf
         ssoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=mTBrGbdwNZnJ0ejqBnhA6/6CZqtjoHX/OR+I7FuqM62uN9a6K7Hn2lsyKakpdvH8qj
         NEQDhltSVBuZWdPwy+1ubWF1D2nc2FSAvF+eBtGbYha4MAIqOTyPbuRsHCeYakb5uj/k
         ZpwFojVvsbWAdhK9/m7dzTeJwEloMx68DcTB9JR5plHBl3j9EX7A04/mP07j5TKpuNTm
         art27mQshRGhDfv8uDcjymT+tqrkWkzetJXlYhJJgS06N+CoBmMupZcr7l0xFQbk8K9J
         WAnKDoW7mHMt+wNq9tIWnpMZr8yaBwZmqh8FRnCkpO72PY9Dxxc7W8Azo88YkYDS13/Y
         8A4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TnoFvHk+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a38sor97669212pla.0.2019.08.04.15.50.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=TnoFvHk+;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=46lxAY1z81U+mrrESVpVIrQ+fWJc6iHl4OExj8KwBEA=;
        b=TnoFvHk+U9GlniOKiXvWmHaHCeiVRyFhspf1Ucco3Opb6Zsra5EKt4aW1VdCEHOoOL
         B19ZrZSjdl4XOLjhMd/tz/suTkdRby0Q/hj5CJZSGF/pCKAPl5af/u3ds9o4NJugQJUH
         wah7eFEy+LBD8ieXrf5M4ghNwdqYF47d1zgnqfS2OWPzozoT/nJvTGXUM3ZYObcV1Nod
         /B+8RZc6MysuCMtgdDFKXIhBZ1vxh5KoYsW/S+ERZyza2fEF3JOhoez0XL3hqg3QsNHf
         A2vrE2EWhCkc/+2Bi4Qkus+K6o78OOjPZC/JIdc8d4G2oWHuj6EfQ91Jku0EJ0FsNSHa
         w9qg==
X-Google-Smtp-Source: APXvYqzB7V+habp3I96Q8m7XMJqRYvky1QL0M1s1kWUjAVtyhhVWp0HvJtmcLDTq9kGGDNeFtLuO/Q==
X-Received: by 2002:a17:902:9a84:: with SMTP id w4mr21647219plp.160.1564959010056;
        Sun, 04 Aug 2019 15:50:10 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.08
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:09 -0700 (PDT)
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
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Roman Kiryanov <rkir@google.com>
Subject: [PATCH v2 32/34] goldfish_pipe: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:13 -0700
Message-Id: <20190804224915.28669-33-jhubbard@nvidia.com>
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

Note that this effectively changes the code's behavior in
qp_release_pages(): it now ultimately calls set_page_dirty_lock(),
instead of set_page_dirty(). This is probably more accurate.

As Christoph Hellwig put it, "set_page_dirty() is only safe if we are
dealing with a file backed page where we have reference on the inode it
hangs off." [1]

[1] https://lore.kernel.org/r/20190723153640.GB720@lst.de

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Roman Kiryanov <rkir@google.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/platform/goldfish/goldfish_pipe.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index cef0133aa47a..2bd21020e288 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -288,15 +288,12 @@ static int pin_user_pages(unsigned long first_page,
 static void release_user_pages(struct page **pages, int pages_count,
 			       int is_write, s32 consumed_size)
 {
-	int i;
+	bool dirty = !is_write && consumed_size > 0;
 
-	for (i = 0; i < pages_count; i++) {
-		if (!is_write && consumed_size > 0)
-			set_page_dirty(pages[i]);
-		put_page(pages[i]);
-	}
+	put_user_pages_dirty_lock(pages, pages_count, dirty);
 }
 
+
 /* Populate the call parameters, merging adjacent pages together */
 static void populate_rw_params(struct page **pages,
 			       int pages_count,
-- 
2.22.0

