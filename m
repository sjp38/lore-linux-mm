Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5E5DC433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:26:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68C0F2075C
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 02:26:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bjxN1i85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68C0F2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE5156B0003; Sun,  4 Aug 2019 22:26:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6DE66B0005; Sun,  4 Aug 2019 22:26:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A36E96B0006; Sun,  4 Aug 2019 22:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6BBC86B0003
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 22:26:31 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x1so2815608plm.9
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 19:26:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=lcnoyc82zBJmK7HyZZ9/xYHIo+nvY1F0Vc3WAAWFXf4=;
        b=Z2du/mfU6a6mk9QWchNluoWy05rQwnCtc+m1E+qVa4FYuWejSu+Z1kbqjIGpS/9fnJ
         g/UcKspmuOUOsslJcd32AfL2qhyRIXCdLlB0VkyhASjI864SPvVjsW+hIuLI7V/oZI1E
         ZDv6jNERk8JceVsj5tYfE8fe5Og52LsqpohZKAiDs/wxNe/MCNrrDhU7+0ub0pN81S35
         zoUuUrwSrXuFudAkBBB7B3zeuLB+pZF2CBl62+vqPADHBfTxBcaxojdrYxUtaBXTGWZD
         HbSwLZZxxM+WHyT35HUEhGY4KI2rUkangzyXajKTgHioRdIx/o5lhNn9dqbKNqUE5zVB
         Vu5Q==
X-Gm-Message-State: APjAAAUCcb0Oc8dzKcu4Vo5a8HoTyQy1I83I8VhqRtaTLeqrH8R2xuhh
	j16rMzkjaXLulJAC8DeI2989sa14jIL7ri6L/DAet/ns7Muji9A3DVYeqXktoOKPsI9Wny2NP7v
	aXVqVBJwNlex1FtNeizqFYcuP12OE49/c/2ADYrhc2rdJk2MNhuuwBC9kYY7/rdgDWw==
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr15965261pjb.30.1564971990953;
        Sun, 04 Aug 2019 19:26:30 -0700 (PDT)
X-Received: by 2002:a17:90b:d8b:: with SMTP id bg11mr15965218pjb.30.1564971990049;
        Sun, 04 Aug 2019 19:26:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564971990; cv=none;
        d=google.com; s=arc-20160816;
        b=fzR2eZ4ou+B8jGnnWBmPDpKBKL1HRDYPYVR1I9fkZXKYWrjjfdo67xHeig51DtKM7e
         qtpCcnhd4XRknaHcHdnS0QuIswMYquUvGS8QWBLmQXvcIKTiBzPWn6SLA2l+qOahZmK1
         /5cymRlio6AMeEGhcQCPeJX0HZmyVNdyoErvGf9SOO11Ppm8sUPS1nj8ZiCDjZJiZDQs
         l2IZuLg9pDhx0z/mOdBxYhjywPRmjubjVfevMvrQuecV7u6pp1132gQf3/lArYdr1uBH
         1SpRNbNknkDx+en2rlX7JyJCc5Twj9eCfEDtRIG3npnm8CXKreES3JXiLnw/qJJ4u0OP
         39+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=lcnoyc82zBJmK7HyZZ9/xYHIo+nvY1F0Vc3WAAWFXf4=;
        b=vxi0TKzbNelu0JtlayfezQGaaopBvN1FZ4T1iIv8qmxXbc+zxr+l0Z2LptrsaOVXtl
         jq6uNrcSrqf4nVyCaAy+3cdDgG1oVpqfl2JG3teAHIQg391qQMUWm/vH5DNnBHct7hOz
         RinQ8YZykvmRpWSkU/LK6Z10dgFKB/Hwcz7CDJRhiKMq73evhp7gwsSCJK9U44Kv72bt
         6TDXYEv4eVz6ULKNGt/Jrxh92MoYHjfotFUp6q/Vpb+lJnT1sbKZeI7SlDVi5wCr/X0/
         DejPxGz13MaP3IoWLYWssMJ/o7e+NPV0/vQeJzjoe2UeLAvEcegAjGMwVGn20XIV9mN3
         tmqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bjxN1i85;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a25sor60868211pfi.29.2019.08.04.19.26.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 19:26:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bjxN1i85;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=lcnoyc82zBJmK7HyZZ9/xYHIo+nvY1F0Vc3WAAWFXf4=;
        b=bjxN1i855euNnjUnIRlcEX0LvYqx3HxLcGznZolbzXrZ9h2uenhVqHuurr9ZBo0Mdn
         BEsRrms5VOqtu/pZu/TaKYkRFrpT11Va6g+49pLA5OWY+SZ0hMDbYRKwmWmxzMDhbb8f
         GTQVuKdH4sre765l2YwqLwgEj5U5TCxJ11dgPQgtD9/F7nITzsxx1q+K6fPt8AJTwZ51
         SXQT/3NcHGnARj71eCFz2j1ZKbUjtfQuqmAtbXa6juripZelfrT7KMWdgAkVhlhszJJH
         Qh8QWc4/xPlfmZB6bDU1IsGkYlb7ALstwyWPJLnNFIgVmfoptlw3rJFEc3KpcOW6cCi6
         uYRw==
X-Google-Smtp-Source: APXvYqz56Uy3OWp9yKpnmoBerTa/QncOG/6somzUXYkyfxRhF/JGW0ZcxzT4FIvpzsPEHyTa4Zvc7A==
X-Received: by 2002:a63:2004:: with SMTP id g4mr128483482pgg.97.1564971989557;
        Sun, 04 Aug 2019 19:26:29 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id s6sm122624067pfs.122.2019.08.04.19.26.28
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 19:26:29 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-security-module@vger.kernel.org
Subject: [PATCH] security/tomoyo: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 19:26:26 -0700
Message-Id: <20190805022626.13291-1-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
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

Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-security-module@vger.kernel.org
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 security/tomoyo/domain.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/security/tomoyo/domain.c b/security/tomoyo/domain.c
index 8526a0a74023..6887beecfb6e 100644
--- a/security/tomoyo/domain.c
+++ b/security/tomoyo/domain.c
@@ -931,7 +931,7 @@ bool tomoyo_dump_page(struct linux_binprm *bprm, unsigned long pos,
 	}
 	/* Same with put_arg_page(page) in fs/exec.c */
 #ifdef CONFIG_MMU
-	put_page(page);
+	put_user_page(page);
 #endif
 	return true;
 }
-- 
2.22.0

