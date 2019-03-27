Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE796C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58FD92184C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 18:11:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ko7SEPAl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58FD92184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCDB26B000C; Wed, 27 Mar 2019 14:10:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7AF16B0270; Wed, 27 Mar 2019 14:10:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B26386B0271; Wed, 27 Mar 2019 14:10:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8DD6B000C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:10:59 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h15so14555896pgi.19
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 11:10:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oEBcxAdpCIW/LfbtKqfFp9cdJVP14S8VLUHk4KLW/5E=;
        b=WWPFBgQ6CecUiQxjOgUFNxFJ/rAxxgTpLUYcstgR4XUzQSpOAFS/VAqR6NcMOJCTMq
         uCDne5FSlrdQz111EkUqe1xvFGlNluolUA2pYXeo1olIuG7qM6L1mXJInwOEEIhCLkt1
         KEgPAXKNGb8CkNiUK10tKpDHeiRCgATCCVtQNbVeSWlr1y1BoSCIJw22AGFihAAFBS/e
         NRce1g7hYJt3ZFuYGrGhFBNQ0E5jdHnA7DXU86NzAA4P7BodeR4NUENFq7qVyivh5Dbt
         z420hf4zkK30WWcWQ2phnETXhF3esSV06NGEbEjNTjZa2qhMMyx8SGRgJsXR6oloxDMU
         qjTw==
X-Gm-Message-State: APjAAAWDbxjTxzpMWJnKE23Q7Wrt8S1UyDEjuEgvQjb6q92RfqvPTrj2
	o2Eb9mwc4Ph188x49CDyYIjFm9KiCc1GUN21psVUl8LsG8UHfB0DRZX0W+f+z/8LcsEMIDGsEnq
	D1wR+ipsEO7uX3APvyoDbq9yBZ+2kDfePCEMqQuBo4XGCybO7gyp3JkcSZrB43YWJng==
X-Received: by 2002:a63:ef05:: with SMTP id u5mr35862696pgh.177.1553710259047;
        Wed, 27 Mar 2019 11:10:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzi8Y0UhqZ9njDxKJPwQLwwd5bwEg1FCyRBtamDIKQiiq6jJuPjPldKrr70GwHbc+pde4mZ
X-Received: by 2002:a63:ef05:: with SMTP id u5mr35862633pgh.177.1553710258298;
        Wed, 27 Mar 2019 11:10:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553710258; cv=none;
        d=google.com; s=arc-20160816;
        b=fIfAA/hSaBPwJmFtorxIrnPpsuVkAtNjcV9QROsnrSjDd6AwW24A1ofWTN3DsFLe70
         vZU8nET9feT5kqBRYbwdHwvzGMfR6Ihor5XbdzYMMd3jgqtEE/0INA86DvKbAkXPrhqS
         vjxm61TyKScs05piSKaIARyqGFq8oAdywFLnQcDSOfKaZ0aLjQnJcMEv32kTDz0ibvfd
         kekV5L0vsylua0wevVN4kTszXzY/4bN6UidG0W+AdKlAStPastDjaj7HwVpACBveadkQ
         i3dJVQTYxq2WrezizRFmxRTwkQKTXwnbBQVpWGj3UAd+o6qYj74XdyWIc/yqEaVfocUp
         gpew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=oEBcxAdpCIW/LfbtKqfFp9cdJVP14S8VLUHk4KLW/5E=;
        b=c+PE4jI0KWa2xwLzrUqUHsZb0o37qHYYtxd+085K4vqgwmvuyeNcqyFwNf5rcR+mH2
         tFQWqrGv0Oq1koJqkoATk4M/0pcCo6K5H3W9pnqAyOwWT/bf3/4zdUEqJYMr3iVXX8jI
         lcX4+J7VZLkrbp6aZXhSdRWdn5aJJ7hl4L6vn6U5vQx7jZCZI09tzJppY37wfxJR7M+2
         w1K13n98mC23UHAOiSSSHsdp3i+3UVAzveOiVcdKOf+KY0dbKN90sJa2XA5rCEVz2qm7
         B6bCYNjIQ0AjKVr4Gsj5tBTdDzi2jqiwuKc1fP3lGIJdThdkIe+RIA9Qk9nm2qrj7Axs
         8CuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ko7SEPAl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id c13si1822802pfb.67.2019.03.27.11.10.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 11:10:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Ko7SEPAl;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 087682184D;
	Wed, 27 Mar 2019 18:10:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553710257;
	bh=F6LVIjqoBQw4+4vg1nhHNG/PqzrDUarrDFl95pWBNEc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Ko7SEPAlJilWBOWBBmuUPHTmYEnJ8EoqFZN289Qk/NfCE/Ooxq9nrIjNpRXKXSY5A
	 shQ1HVo5hv/1F5bpLgOQBIRL/l9352lRavJVBr7+h7RD5IYWKRqAdfE7uIMTl/hhAU
	 GFKYgp5g/zzqa8o3B7dVbxIsO+VwM5ikzic6bAAM=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 021/192] mm/sparse: fix a bad comparison
Date: Wed, 27 Mar 2019 14:07:33 -0400
Message-Id: <20190327181025.13507-21-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190327181025.13507-1-sashal@kernel.org>
References: <20190327181025.13507-1-sashal@kernel.org>
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
index 10b07eea9a6e..45950a074bdb 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -196,7 +196,7 @@ static inline int next_present_section_nr(int section_nr)
 }
 #define for_each_present_section_nr(start, section_nr)		\
 	for (section_nr = next_present_section_nr(start-1);	\
-	     ((section_nr >= 0) &&				\
+	     ((section_nr != -1) &&				\
 	      (section_nr <= __highest_present_section_nr));	\
 	     section_nr = next_present_section_nr(section_nr))
 
-- 
2.19.1

