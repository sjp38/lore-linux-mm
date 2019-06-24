Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D346BC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 875582083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 07:55:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 875582083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF14B6B0003; Mon, 24 Jun 2019 03:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA0D48E0005; Mon, 24 Jun 2019 03:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5C78E0001; Mon, 24 Jun 2019 03:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A6F636B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 03:55:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so9083527pfj.4
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=xASDYt0H0MH/pbNzuMICxtrSKYUlduJvpip2fwjqvtE=;
        b=MgYiXb5LuzvXo8590Eu4DcyNiNH5sZ04tcievznVL9D2IvSTrLcIQetcBI+5Yu9o4T
         JE0T/0v7f4nqikaarm7AbjBK8Pr8lAIaLPDTc1dQhiw5vrKQzmfhaIOE1Q5cjP3A2wfV
         M4vEi4dry6m8AOYhqFPcjY+xe2FoN8EqUde7mmDnRCImNE3Sj0cZm6rkpjNNg9pSxz9+
         Ty3IZdSfGQmnkZyRTuwwo5OOe8EpG9vN6dKpsmGQsGzccEnS/pKS8tFRFh7u6A+7blPm
         hReIAOg/dT6DiB4daxtuOvJy1zZ8Zw64Zp1kSBrF+R49NQHXV1Is73gU1xZyV3dYjcOZ
         aOrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWLuIVBEUWp9nSu796s7zoYHUEuagxKqnDYE3WcXUk3BgHTJu3W
	cBjfLGg9eKdB4RNhdbh1PnKR9ailRkjsVQbAnvO67nYZi/CsUzjfXtRhx9umhOaSm4IOoJTMWzb
	3/jgyV6Ijtx+rnNzASjwGBbTrz12hUXN+4mv5UWmjgD3aElwMXSuP4ALtm2H+q78L+Q==
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr22514783pjq.69.1561362927219;
        Mon, 24 Jun 2019 00:55:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwepy/0MvmbRhMWkznu9NqQHFTSfNSYWD2DxO/SBr/FeESCUWdKvpo9ZNQ9HpIe6+UkEZ7b
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr22514742pjq.69.1561362926530;
        Mon, 24 Jun 2019 00:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561362926; cv=none;
        d=google.com; s=arc-20160816;
        b=mNAOPBAhW+GXs/avZyoP9ydJWjz4UazCiA+pCA1VBoyw0dxOp1jDOpBQwBCLPOicC+
         lrlv9hlz2eQoqjCqHElf7FHussoiY15RxeRtN0s8DofwhuEGDLeLrdlhiVWDs064JxX9
         caFeEttZ2ZDwLnJpt6KjKxif42ZyEV2mKms6vo9yXsd7hwiWKqLV3C9nwDtyKKqd7rwz
         whWMYcX2TUBqxY6i2CT0PDbF1rhr/e4x+iHhu0XBEX6Cu+LWEUVzsvVzbTEMF01YXw6t
         b38RsfMyQV5IR/RAfKtYwkNgAj9xNaO2q+vR0T1OXbGfn5GtHAvVNYVRqKAwZcmyl8mO
         6Ijw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=xASDYt0H0MH/pbNzuMICxtrSKYUlduJvpip2fwjqvtE=;
        b=wlHAzVQHualoke63lv1SjbIZ3shg9qObFYwH7v/Yvv3G5xJYA4SuJtkH3waYHtpPZL
         fOt46obkdSS7sdLSDZB3fNZcH1WK/yAVPVdPWRW8edRcEnLV4mmQwIiYxw4wxinTirjU
         0fv/NYHAR46Jj8VKipLktDWNlQ0R90pD3/9oN3WgMdBMjxSh3l3sT6TKs3uFavlI+uQO
         TOHBprXsdG3shqxKpPy+9bvVPCnjWbZjudhllRn9cLtZ1KKyOpVaD5aCqzAiodVUEpKi
         A7udnUQA8CQ1c7rPNsg1yNcM51H+/YHSIuQAn+23pw9311YvCL1uu3SOhcBPHpfmWcId
         QCZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id d18si3952406pls.423.2019.06.24.00.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 00:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Jun 2019 00:55:26 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,411,1557212400"; 
   d="scan'208";a="187844126"
Received: from yhuang-dev.sh.intel.com ([10.239.159.29])
  by fmsmga002.fm.intel.com with ESMTP; 24 Jun 2019 00:55:23 -0700
From: "Huang, Ying" <ying.huang@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>,
	Ming Lei <ming.lei@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Hugh Dickins <hughd@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Rik van Riel <riel@redhat.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [PATCH -mm -V2] mm, swap: Fix THP swap out
Date: Mon, 24 Jun 2019 15:55:15 +0800
Message-Id: <20190624075515.31040-1-ying.huang@intel.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Huang Ying <ying.huang@intel.com>

0-Day test system reported some OOM regressions for several
THP (Transparent Huge Page) swap test cases.  These regressions are
bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
fail when swapping out THP.  That causes the OOM.

As in the patch description of 6861428921b5 ("block: always define
BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
THP to swap space.  So the issue is fixed via doing that in
get_swap_bio().

BTW: I remember I have checked the THP swap code when
6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
and thought the THP swap code needn't to be changed.  But apparently,
I was wrong.  I should have done this at that time.

Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>

Changelogs:

V2:

- Replace __bio_add_page() with bio_add_page() per Ming's comments.

---
 mm/page_io.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 2e8019d0e048..189415852077 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -29,10 +29,9 @@
 static struct bio *get_swap_bio(gfp_t gfp_flags,
 				struct page *page, bio_end_io_t end_io)
 {
-	int i, nr = hpage_nr_pages(page);
 	struct bio *bio;
 
-	bio = bio_alloc(gfp_flags, nr);
+	bio = bio_alloc(gfp_flags, 1);
 	if (bio) {
 		struct block_device *bdev;
 
@@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
 		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
 		bio->bi_end_io = end_io;
 
-		for (i = 0; i < nr; i++)
-			bio_add_page(bio, page + i, PAGE_SIZE, 0);
-		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
+		bio_add_page(bio, page, PAGE_SIZE * hpage_nr_pages(page), 0);
 	}
 	return bio;
 }
-- 
2.20.1

