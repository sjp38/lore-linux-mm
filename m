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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82AD0C41530
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C95021874
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SC6fy0nJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C95021874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80C3F6B0273; Tue,  6 Aug 2019 21:34:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71EED6B0274; Tue,  6 Aug 2019 21:34:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 571176B0275; Tue,  6 Aug 2019 21:34:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B1A06B0273
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q1so359168pgt.2
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=Btr/9QBRyx16vd7GAvV2MiiincWhqy99uroN6JPFtp1tnVto3gEGv1vq9MLzgozgz1
         GCnVenbyZWx9OCAfWlDkGZNSgrw46gVGFp3Lwy2NxlkZYw4R4Kx+6xS419LdrZlUW+SU
         k03uKaDXBlDv+0TvNcj/i0ola8Zkb8a2W4VeTsoDL6ZAl4vvUdmfvdVkaT9Km5wkSlDi
         q0whXcKZbWeUmOvQ3em1M2PK/a3ZiDDECNkbYG5nzbyeaPseIFHqKcWJwcqzcFZ3gDKE
         58i4zxY0twrLOgmgNFgCMiy3TOFixzXSvkJf/s2QMZAqYYCnGBCtRu1j1w3j4HE/Ady3
         NL+A==
X-Gm-Message-State: APjAAAXMEGtwEwbtFDwDOldX/Xd8OCnRJSEnjQ5k6pi5884dp6or/aS8
	UeRBQjm5GZ42UBPc3MiKCnK60yTGwcvhr0By02RqnklrWux3x38QGgMMFgmZPdraWhWBeEzvHFS
	UNU1mps/Hqb+MYvr1+20RUL8TpyIBflh7dc/K2uP7HlE5IOsgX7k4zmW40O35zjCZ8A==
X-Received: by 2002:a63:2004:: with SMTP id g4mr5294214pgg.97.1565141658712;
        Tue, 06 Aug 2019 18:34:18 -0700 (PDT)
X-Received: by 2002:a63:2004:: with SMTP id g4mr5294142pgg.97.1565141657342;
        Tue, 06 Aug 2019 18:34:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141657; cv=none;
        d=google.com; s=arc-20160816;
        b=ieJBijyWy9DN99B2YcmT+ZeyEnQvOOfbpU/O65ehShxCtUgB+8xG2zhf3j3UXIGq5P
         //h0UQexg/RglUOhq0JmoNPgJUkIUoeTki6yYPsYcASpLjFUE0Xe6lmWQUbQX09aJtog
         lkAu4R3p5UsjmHChE0y2ZR+rn+BFZySDH5VRje/dwMqcONW4wcnIviWYKW+V4IMiuz+p
         wbdTVTFO8DDLsUo1M99LPfzUYKx5MtQHsaoKM60WCBBtCyiNOM/4Ks9RaMHw2dHR1fPQ
         2VSM83iI8DF9OCs1TEMKrAzpNldbgXc4ZrG0An4R5xcNSTBzyuaBkckGNTG9/rq3eOFa
         aOYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=RrkvzLq1DkLVMP986DM8t4A1S8Vzk4e856UNnmcVC5yPTlZwrwgqvaxGh1k2xxqs8R
         UYlwCGBwOdgd52jrL+ju8Hw9+LTTHRtB2XyElWlcKkMyVzs8n5zzaEceVl29av9AAR0o
         vTBmMiZ4tJg4BLhk6xZ6iPnT2xIb4f40HUEMNd2UoEyQHc0fSH7I4PywH2ehW6F6E+re
         R/CJMz4JHC9jWp5DxoDnxcbdrM00d1A5K2giMgxt05YJGozGP3EZXHgDxk7qjL6YL5TH
         qlGl2uGhhtyGPHO2H8DnZ8iEjlzmcCPnxK87lXeK9j7KyUN4iLycahOU0nIwa0lHoCtX
         k66A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SC6fy0nJ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor63327425pgg.19.2019.08.06.18.34.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SC6fy0nJ;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=SC6fy0nJ+5PJ+uzUodkQNgZrF01XL4oLeLC56OFBk8WNdVXJEhXdfnbycjiEGLb0We
         Iu9ehQr2XuhNar0+cOOcnuWTDzgnJQOZf2nhFq9SkSbfMVKKQlgbBbr/DzgGJpA2zgNE
         SH9LdtGtZEDMK2ObSXiKnb7p35+i1ZPY62UTf23m8h6lM8RDSVmojjsKFFq6AHV0Kg7N
         l0Mr0PozM18bgs6gsyipPgOwh2HesyAFpZqdTaDseaeVgz0a/Wn16vsKh7i90SBwvo7N
         ssA83RPwWAs18iPpiVevS9yzToDMKktmsaAXU8RmgcEKrZ1Ps1HBX3IeUwmveghlYyG8
         ruRQ==
X-Google-Smtp-Source: APXvYqzgZPQySecfl1w9rbSdSUoujeX96j23T70OrIYhDcbszTpXzwBQIEpy9+PmeMFp8KmBYei+SA==
X-Received: by 2002:a63:dd17:: with SMTP id t23mr4918609pgg.295.1565141656992;
        Tue, 06 Aug 2019 18:34:16 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:16 -0700 (PDT)
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
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Kees Cook <keescook@chromium.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Bhumika Goyal <bhumirks@gmail.com>,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 20/41] fbdev/pvr2fb: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:19 -0700
Message-Id: <20190807013340.9706-21-jhubbard@nvidia.com>
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

Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Bhumika Goyal <bhumirks@gmail.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: dri-devel@lists.freedesktop.org
Cc: linux-fbdev@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 drivers/video/fbdev/pvr2fb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/video/fbdev/pvr2fb.c b/drivers/video/fbdev/pvr2fb.c
index 7ff4b6b84282..0e4f9aa6444d 100644
--- a/drivers/video/fbdev/pvr2fb.c
+++ b/drivers/video/fbdev/pvr2fb.c
@@ -700,8 +700,7 @@ static ssize_t pvr2fb_write(struct fb_info *info, const char *buf,
 	ret = count;
 
 out_unmap:
-	for (i = 0; i < nr_pages; i++)
-		put_page(pages[i]);
+	put_user_pages(pages, nr_pages);
 
 	kfree(pages);
 
-- 
2.22.0

