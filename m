Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9DE8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BB7B217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:02:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KBaKqEmY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BB7B217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EB116B0007; Wed, 27 Mar 2019 14:02:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09B9A6B0008; Wed, 27 Mar 2019 14:02:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECCEF6B000A; Wed, 27 Mar 2019 14:02:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B68A86B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:02:49 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h69so14611243pfd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:02:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rSaj9L1xCJ7iztPjfarFG1shcw+7hxXe+zCxGAJuYMQ=;
        b=B6TwNTqva+/+nbOymPHTGnbWpKt1gnoukuB4n6j4HuuNzJEWC+Y2QDOJafuHztn5D6
         NCIfOZbwpH4aLyZxlaWaCmbSEXlaQRaEG2VjwTuLbkm/7mVZC/4drqghEnDMpwTvgbcP
         Yt0nfROg8p4Tb3DDAv0ks+Cg2WExoXfUSwR/A18KoQrnnyN2FbmoZC73HFVbN8mSPpfW
         BKY0tOI4BheBrpfCQjl9xDrRYIcYTGNpF9I0WIxzrGhtqrAdaSQ7JKHzsnydUJ9jm88U
         9c4865UpPmOl9Ph5y9bG0LqyiNjwxBCLcNzdE8qH34IYBldSL5aTFQzs9+RlMBvJKAuP
         LGng==
X-Gm-Message-State: APjAAAW1VtuneTSCLp30uv6afdyGLJU1eZzIbkse0c0ZSm9qijpD8GnW
	bPjDe7MKhSZQAXpvNwRXCe/DsSg21mGI04ZO1HeHxzeoSjaaCwY0m9uXuGwNmhZPicXQktCMp4z
	uQKF3cAZ8dg+/DFOc0Two2NSn46OQtEQRBzAMrGqqRGXNG3eIvUWaq6cUSCH5fMYCpg==
X-Received: by 2002:a63:570d:: with SMTP id l13mr28063729pgb.55.1553709769418;
        Wed, 27 Mar 2019 11:02:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR1A5ewndwe+MvOlJy1A4496nVF5hZyQXZXD/D8bY7WHZrS05B0UE/TGxAmZEt02pAi7mu
X-Received: by 2002:a63:570d:: with SMTP id l13mr28063650pgb.55.1553709768574;
        Wed, 27 Mar 2019 11:02:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553709768; cv=none;
        d=google.com; s=arc-20160816;
        b=uNga23S+qHO9dunj/pfKP3kxSgIZNG1dmGKt2gF+XjESwqsIIL5Rczea4bR8CZB60K
         kFZXCvJVU1xlyQB9PPGFNbnG4qiKHhKSQtkp8V3k/QmBm6S+uT4awp4tAzZ9NF4g1pxr
         +v/q4rnHnCS3qoG7VIQbWwwnUlHwzOqe6nfN+VnnhXFvpDGF3rfVbcXLhskXkJmt+415
         xiduL9SSxriB9eLtogwetMdb+HHDZ5n320AQ2kDqnAThl3R2Kx1uFkZJZI8UXxo0xDJ3
         SzxkbnBxHwzRJo9DP/V/dlq4mgUpYL1swQjjav6kEnq4itB+lqWVCT73qot+XmuK0XhF
         C00w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rSaj9L1xCJ7iztPjfarFG1shcw+7hxXe+zCxGAJuYMQ=;
        b=qiH2MXrk/of09IHBxuV1gVoKG0ArK0e9ZzZJbmiSeSEOLV559qYuDnaLzpP3n7smSJ
         9Us8rUn2Yl1Oiv6gYolPWYIGRDekee4Fphdz11Vtn0FU0jKTYQ3/ppAY1uN2VeDlPsY9
         xB2hW/XEApyd25Kf45KTPHbaIXomvB6NELmXPhd5OQE/FhmQp2pz97nrn5azJb6513u+
         b5QWVyikk0Hl5ThTXuI6JwAKeQtzkxsDHFm5nYG4lBbiszHOoH8q5YEUqSli+VAIZL7R
         ewmzMLYkKpYhr3qlKG6MHJwiqtm4+Kg/4y8Tz1f/VIhMq6sUC0tw5ikh1k8HpT7RI2vK
         Kjwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KBaKqEmY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q11si18797486pgv.337.2019.03.27.11.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:02:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KBaKqEmY;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5C1D22082F;
	Wed, 27 Mar 2019 18:02:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553709768;
	bh=b5xJuu4cKmJC0HBUNTG66oXfu8IqPF1/ejzqYlsS8zI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=KBaKqEmYIAB49HWucvLauhdZFKkmZxCUMrWtfwDMDOxFJzoBdZfIw8b0dcd+4PeQN
	 MRR7BLRlpWtTGF878QXdZqfxdmAAlCevJD2dIrvXfgJhC24iDJ2J+HVMr5hOrBeIFN
	 AdDzqyK1ed7xLuZY31ZDlguYZEU/7u5i2ALmpRIc=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 030/262] mm/sparse: fix a bad comparison
Date: Wed, 27 Mar 2019 13:58:05 -0400
Message-Id: <20190327180158.10245-30-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327180158.10245-1-sashal@kernel.org>
References: <20190327180158.10245-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit d778015ac95bc036af73342c878ab19250e01fe1 ]

next_present_section_nr() could only return an unsigned number -1, so
just check it specifically where compilers will convert -1 to unsigned
if needed.

  mm/sparse.c: In function 'sparse_init_nid':
  mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
         ((section_nr >= 0) &&    \
                      ^~
  mm/sparse.c:478:2: note: in expansion of macro
  'for_each_present_section_nr'
    for_each_present_section_nr(pnum_begin, pnum) {
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~
  mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
         ((section_nr >= 0) &&    \
                      ^~
  mm/sparse.c:497:2: note: in expansion of macro
  'for_each_present_section_nr'
    for_each_present_section_nr(pnum_begin, pnum) {
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~
  mm/sparse.c: In function 'sparse_init':
  mm/sparse.c:200:20: warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]
         ((section_nr >= 0) &&    \
                      ^~
  mm/sparse.c:520:2: note: in expansion of macro
  'for_each_present_section_nr'
    for_each_present_section_nr(pnum_begin + 1, pnum_end) {
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~

Link: http://lkml.kernel.org/r/20190228181839.86504-1-cai@lca.pw
Fixes: c4e1be9ec113 ("mm, sparsemem: break out of loops early")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/sparse.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 7ea5dc6c6b19..77a0554fa5bd 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -197,7 +197,7 @@ static inline int next_present_section_nr(int section_nr)
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
-	     ((section_nr >= 0) &&				\
+	     ((section_nr != -1) &&				\
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
-- 
2.19.1

