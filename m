Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A14BFC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59E6C2083B
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nL5gA8Hk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59E6C2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46DFA6B0273; Thu,  1 Aug 2019 22:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 421CD6B0274; Thu,  1 Aug 2019 22:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 273296B0275; Thu,  1 Aug 2019 22:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id E05A56B0273
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:41 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y22so40726998plr.20
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=tMHEVkwSmfs1vsDeakJ9kK+OWXuZaWS/fESpKEnAuimjZf4i9eHE6/UjCD6HIl1FQp
         2RTeVL8NSr3wHvFI02qwas1Z7HS7GG4zepbNmsuzQKjNe25w95FjyUIwbr1OYKn86hdr
         y75i4QFcv6MIEV/nFffF4P+kM9AhsB4uN7Co5RJ+YLvJhrMiUe69FrvFMIowIn79GOjQ
         CB7VblnVlckxkkoUxvUzR5V8fkJkWfDvoVe35nLe1RU/gWdykqpgREXWmEHMjoNfDdgb
         Y9V/Z6rEAA4v8Mg2ZyLbPrCZSqwR0DAhyxvfpSyMLzKyZtRkqXme8te3/E8LXU5cU2/7
         Xukw==
X-Gm-Message-State: APjAAAVpaKeBtIHVaY5HqTMbSNGfYAtS+P8BU/bfapRtb99HTZ/KMm8x
	PBLV96BYKbewN06BIGoJMo1LsezLnJ8+drEMGHpKRRwJjNVxZobjB/1h0tCvVDqdEdYVeBjdeIG
	comLH9TFuahCGQNMtTkwT4c54+syVPTAOjQ7o4FPEtCxaApaFe6JAjMuzyFXEn2HQqA==
X-Received: by 2002:a17:902:28c1:: with SMTP id f59mr11480plb.269.1564712441569;
        Thu, 01 Aug 2019 19:20:41 -0700 (PDT)
X-Received: by 2002:a17:902:28c1:: with SMTP id f59mr11428plb.269.1564712440706;
        Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712440; cv=none;
        d=google.com; s=arc-20160816;
        b=dQi/yObVVmQUFaalfyUZUgtVJ+b+aFSJmIGNrzHHDuZZWDsOPtq0jGGnKlTf2dSe02
         Dp/hf3UWKrX+4A4KcRStawrtF7smr62oTJhRTOV8uAFb7KKPrstqyaMMVWKT3fr+AvVN
         QjdQm8/Knj7tVf7zVms5nouqsERzDu5bjyuMfAcezMAMadBomnhy87IZ93WD8Hk5oEjh
         yqSt3I/m9vSvIlT/toI6QAZb35D5/LPu0BLj/cBlNx+XA3AR5Q9JikeM47A+GNC9LnC+
         vL6gUFiewO74WGSu6g1ii0NA/k3J0a+0c/+2UQd9WQqmlcOBFKUMGGu77ApFbISz/3nX
         SB6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=LRUvUuc7OWmAY4GJFuYblyNmVRk/wHpslrCdazcTktoB2u2hMNEW63hEy1TwC9xVv8
         UxPJqGgY631u/o9yz0yiUyXAHkU48yaTVIB93cuxe3AIje0DlRik4nig1Bj2oWZ6TQOQ
         qjQiOzgeGupD5ttDmAV+gV0Dd/0CaL9iNJCrMW+QcfaVFiwu7JQnp3byfsKxSyGg3IOC
         4Oari1rblC5X5lBh8ZO11IcUJeNn7pzsYM6VcITau0/i3X9WrtJwDuXea+yuiSIE+9Zw
         btCL66zt8uo4oDlR4ENxk9mS/Wn90gt4df8kQc1PHsjTeEol+BE7VWAF7UB9MNSdbemr
         l+Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nL5gA8Hk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7sor87387026plp.58.2019.08.01.19.20.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nL5gA8Hk;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Zk7mJfsjIPJK9Qgsn0u5osZJajJrXebF0c1tZrgdgoI=;
        b=nL5gA8HkBp1qUXL8uSk44yRPDpQM1GzztnKY+vjFkpLO4+ej8Ho3KCm6C4y+E5m8LE
         h9Iaftsjh1UsJUr+Pb21bHX0tSSHXapiGzhmehbpJMXTX/8OVSokepo7ZYp/sAOufRJM
         Dn+Q/LNbJL1I2nNGcQbJ8ZQUaKHbOXUsbWTmj876BCAWOoZWZ6NdZCYaUx//X8gLE1Fe
         Ao4iR+EL7uUQrdQvqWcLAimsvB7jPrqJUl8VTCYTJSYJDpeTKlwz9tVoL0Kex6hlm0oH
         POKBdW3YOuZavjeRiRdEl20H0UanKpKGw2d45prgvnfRqnKjFtcxDl+Dci+NMwFW+1GP
         a0XA==
X-Google-Smtp-Source: APXvYqztsbUVpJnR1pWJXE324fW+SugJBxHHKLNQRZirN/VnD1v0OsiDr/qT4pG5Y0OOV3QlfOZRKQ==
X-Received: by 2002:a17:902:830c:: with SMTP id bd12mr131600821plb.237.1564712440479;
        Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:40 -0700 (PDT)
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
Subject: [PATCH 18/34] fbdev/pvr2fb: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:49 -0700
Message-Id: <20190802022005.5117-19-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

