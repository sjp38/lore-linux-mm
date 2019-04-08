Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F216C10F0E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D10AC20883
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 02:38:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=iluvatar.ai header.i=@iluvatar.ai header.b="AU1KUwf+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D10AC20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=iluvatar.ai
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C585D6B0269; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C071A6B026A; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACE876B026B; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 779996B0269
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 22:38:18 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j1so9414104pff.1
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 19:38:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=+Ok9chkdp27Y5YtmQeTDw961jkYIka3EJirxsNMqBYg=;
        b=uMCWpYcrIktjgHK3fgmsZ64a4ID69F6LcGvXlBettqzUC+GahQg0h3nB8ZT4NuoyHx
         IMlWEUJkm7WQ6DNyGllIF2ZPakYsEZm4UuDe3lPqO3q2h9yonySYAnyvaWMqZ7HpW5fN
         JMhekzCDBB6/1uaPV6PY60ruu/UhKBrI5+GX7pfMUfAmrT2V/FXMmwIM9cAIHB6LuvpA
         Wq7GIpyoJev1mnrN2J6iWIFYhZhaIq+63ie8A4LKpKjfPDToPe8t7xDR3DWE1idQwL29
         ngpt9omXJXjXq9QM4tyHGuPKTRssY6b6wFMRn1TDfWNFMrBlYskA5FKDVlzDJaiHmOHc
         h/5A==
X-Gm-Message-State: APjAAAVDsCTSAwQYAvCfwiljI59TMB3qbcHjBZPRSigijCiL5g2noeHz
	DLZO2i57RtrZXpf4/VAc3abcl9/NgtYm6d5wQ/qIYEd4ztygcruy+5d+b+jRFlKvAv0pIIYuiuh
	IWd1ZUSIC6JcJalkeCSg1D2+3DdxET3R5ml/uNCg/2gqY/utUdT/pXbQPNY/hmg39mg==
X-Received: by 2002:a63:3185:: with SMTP id x127mr26055276pgx.299.1554691098138;
        Sun, 07 Apr 2019 19:38:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwri8WdRaJJn1RU+XLcaHNKTsGkP7hDDunUHH1XRXlxHoON17oZbGmiePvPk6LJjLVVJt+b
X-Received: by 2002:a63:3185:: with SMTP id x127mr26055220pgx.299.1554691097354;
        Sun, 07 Apr 2019 19:38:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554691097; cv=none;
        d=google.com; s=arc-20160816;
        b=smPrgH4V18qJRIJ+2GIFKc0Cj758EuSGX6HKO65KVu9zPLnI6gAJ7TGvcQ/rSYCZdX
         KGhzzTe55d6o5CzFlVp6H0sWtfQJLsSjus7XbZzfca0oOkuiPQBJ62UgO2toCSU49C7S
         zoLFBDzzWWwpes3e/DfwaBBkxu86jLS31M7QcPBmn3WODu0Fyq/NXqm+7StrjFjS3nrK
         sNSqLVbSQkPZA++0kKZT7bPTZw6VzZUUGev0aSrXHIBiITMkd84wsxzUrtuj4Apm8rXs
         efVPVeRnE8dFPxu4NuPf6Fu/fPgrZLj1MinMQYb/FBE8DF501Df1wU/L4Ph/7etYdFzj
         U29Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:dkim-signature;
        bh=+Ok9chkdp27Y5YtmQeTDw961jkYIka3EJirxsNMqBYg=;
        b=dWULldL9uB0LBkbDIoo8a6EGbtBIGawV0xjY9jC4SYIhX08N7w6Fhl+jo+EzHWCThO
         nCFE4xly4boRsqYn4qpFfI9Occ78qB1NKVufbba3fbKW1Gdd7AjY2oMjn/YSDypZJhT7
         uCL8j8kAlVo0AYth/fDCW/lkW/3noxOc6xKINhR+mi3D8KEjkrmSSEqE8anu87TdDWGE
         TB0kkz3XTKPXbK0lwcfzw2ZdsOAR0fp6WGEOly8cwNssl/H5vCadYOHu2h0fp4RnbJdS
         y8vp+XMoEiPrPiJ4e884ZZtAYbFCbemFyl+qHMuLOsMDdWrtlE8KrRMWG848OgrSCv8K
         DixQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=AU1KUwf+;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
Received: from smg.iluvatar.ai (owa.iluvatar.ai. [103.91.158.24])
        by mx.google.com with ESMTP id y70si23704049pgd.359.2019.04.07.19.38.16
        for <linux-mm@kvack.org>;
        Sun, 07 Apr 2019 19:38:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) client-ip=103.91.158.24;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@iluvatar.ai header.s=key_2018 header.b=AU1KUwf+;
       spf=pass (google.com: domain of sjhuang@iluvatar.ai designates 103.91.158.24 as permitted sender) smtp.mailfrom=sjhuang@iluvatar.ai;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=iluvatar.ai
X-AuditID: 0a650161-773ff700000078a3-e7-5caab4179207
Received: from owa.iluvatar.ai (s-10-101-1-102.iluvatar.local [10.101.1.102])
	by smg.iluvatar.ai (Symantec Messaging Gateway) with SMTP id A8.E3.30883.714BAAC5; Mon,  8 Apr 2019 10:38:15 +0800 (HKT)
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; d=iluvatar.ai; s=key_2018;
	c=relaxed/relaxed; t=1554691095; h=from:subject:to:date:message-id;
	bh=+Ok9chkdp27Y5YtmQeTDw961jkYIka3EJirxsNMqBYg=;
	b=AU1KUwf+Zui5EhUQvq/QC5qbPp2q+T2lBS/6sJVrspxov87D9kSQiQTtkeRNZDwrFsdHElnMip0
	msK+EKc5CzFQ1Os1AWLZC2dgi84GzzQes1HRpchaESdHRPLMBD06hu85Y43J1ph1MmMa4YAnVaQea
	8w9znxLNchlW8ECK9DM=
Received: from hsj-Precision-5520.iluvatar.local (10.101.199.253) by
 S-10-101-1-102.iluvatar.local (10.101.1.102) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1415.2; Mon, 8 Apr 2019 10:38:14 +0800
From: Huang Shijie <sjhuang@iluvatar.ai>
To: <akpm@linux-foundation.org>
CC: <william.kucharski@oracle.com>, <ira.weiny@intel.com>,
	<palmer@sifive.com>, <axboe@kernel.dk>, <keescook@chromium.org>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, Huang Shijie
	<sjhuang@iluvatar.ai>
Subject: [PATCH 2/2] lib/scatterlist.c: add more commit for sg_alloc_table_from_pages
Date: Mon, 8 Apr 2019 10:37:46 +0800
Message-ID: <20190408023746.16916-2-sjhuang@iluvatar.ai>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190408023746.16916-1-sjhuang@iluvatar.ai>
References: <20190408023746.16916-1-sjhuang@iluvatar.ai>
MIME-Version: 1.0
X-Originating-IP: [10.101.199.253]
X-ClientProxiedBy: S-10-101-1-105.iluvatar.local (10.101.1.105) To
 S-10-101-1-102.iluvatar.local (10.101.1.102)
X-Brightmail-Tracker: H4sIAAAAAAAAA+NgFvrCLMWRmVeSWpSXmKPExsXClcqYpiu+ZVWMwal/bBZz1q9hs1h9t5/N
	Yv/T5ywWZ7pzLS7vmsNmcW/Nf1aLzRMWAInFXUwOHB6zGy6yeCze85LJ4/LZUo9Nnyaxe5yY
	8ZvF4+PTWywel5qvs3t83iQXwBHFZZOSmpNZllqkb5fAlbH3ymrmgv1sFae7WtkaGHtZuxg5
	OCQETCRevzTuYuTiEBI4wShx4s80xi5GTg5mAQmJgy9eMIMkWATeMkk0n77MBlHVyiRxbusk
	dpAqNgENibkn7jKD2CIC8hJNXx6xgxQxC9xilNgx4QkLSEJYIFRi68IWNhCbRUBFovfMRbAG
	XgELiemT21lBbAmg5tUbDjCDnMQpYCkxfTrYFUJAJa0Nk9khygUlTs4EGckBFFeQeLFSC6JT
	SWLJ3llMEHahxIyJKxgnMArNQvLDLCTdCxiZVjHyF+em62XmlJYlliQW6SVmbmKEREXiDsYb
	nS/1DjEKcDAq8fDeyF4VI8SaWFZcmXuIUYKDWUmEd+dUoBBvSmJlVWpRfnxRaU5q8SFGaQ4W
	JXHesokmMUIC6YklqdmpqQWpRTBZJg5OqQYmMyeFFTPbMndc+FGjLTqdYfrC2WlefY1/3ft7
	12Q0HT2zenHP354/fBq6U/5teXVvP0uVwc5tMw/d/h1VdCG8uTykRkfz5/r5RT94tV5Wa5cX
	vA8Tn2z9m6l0w7579ldfNjyac311R4+FU9lX+9DynSqzhKU26OcuKK/+wyoY0vZMLPT7EY+w
	HEflldcXvtnP9jv5YP0mzTsMO5J2a0dcOx3bv//dJM9W7uadu94wZDlXzK5gOvG6ouSNRqF4
	gpbcyftRtZefvubq2L2SfbZj9sTnxaEuu/tmztZ8/6vvmFJoDpfTghwXd418u5h7IXunptU/
	Tt1sevXh4tOVn55N/s/xMGWd6eGnEz5eNhJzUmIpzkg01GIuKk4EAOJRwDIHAwAA
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The get_user_pages_fast() may mess up the page order in @pages array,
We will get the wrong DMA results in this case.

Add more commit to clarify it.

Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>
---
 lib/scatterlist.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/scatterlist.c b/lib/scatterlist.c
index 739dc9fe2c55..c170afb1a25e 100644
--- a/lib/scatterlist.c
+++ b/lib/scatterlist.c
@@ -450,6 +450,9 @@ EXPORT_SYMBOL(__sg_alloc_table_from_pages);
  *    specified by the page array. The returned sg table is released by
  *    sg_free_table.
  *
+ * Note: Do not use get_user_pages_fast() to pin the pages for @pages array,
+ *       it may mess up the page order, and we will get the wrong DMA results.
+
  * Returns:
  *   0 on success, negative error on failure
  */
-- 
2.17.1

