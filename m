Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33BC2C04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:08:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA12F217F4
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JFPAa0My"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA12F217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35F686B0003; Fri, 10 May 2019 15:08:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310356B0005; Fri, 10 May 2019 15:08:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2261F6B0006; Fri, 10 May 2019 15:08:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF5236B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:08:39 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id m12so2697485pls.10
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:08:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=qqmmhku5NomnoxUpgEvNAyGjbBl3yg9ZxTTgvkD102M=;
        b=o+GJ8Va5BSnBPQrb5BlZ5fs3vLsbEVJbZh9Qx6zM93WfWZ5nqSaq6hjit2WFhaOGVd
         d+o/5ro51Xb4EpbImxfdI/L1Q1pLTG+wd2cKiFBr7ortTA+g6Mw955f1Y94loYc8Bg2m
         G0gw/dv5e9hU7DNtwAfpCYqgfe0UyaIJNELSjibN1xJEI/2Wa2yCG0jv2iYvpWPQ0JIG
         l+XhVbDW8QSYdksMQFdXJabw5FGdRFiuP/hT3Nc/nrSiSOZpnies9VV+1c3Z1+mLDGc+
         WC7z9j8M+60gayn+rBmwbTxqbLqp95wq79hCRMVh0BDoTbDsh/4NKQOqcoEL0uy9fWHs
         MKQQ==
X-Gm-Message-State: APjAAAVdp0OxnJ/kfqf0Ye1GT9qRYOSmX1w4A+CRAY7GXkm+RgvSea4g
	RNM9RkQ0L4GcSNA8Wbg7EBF7J3vlwybyRGpPT5h7efZHaRSHCPH5KhVL+0s/6LF6GtlVsjMmIrO
	ItFTTpI4nSpz+tCGkSUtWg71MkNK9ivgw18OMGO3Dt4E0/VWWP2/z4TmnszrALXeyKA==
X-Received: by 2002:a63:4c26:: with SMTP id z38mr16058319pga.425.1557515319549;
        Fri, 10 May 2019 12:08:39 -0700 (PDT)
X-Received: by 2002:a63:4c26:: with SMTP id z38mr16058256pga.425.1557515318651;
        Fri, 10 May 2019 12:08:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557515318; cv=none;
        d=google.com; s=arc-20160816;
        b=PsQJ0kFl8CXjHtdOu7Z82F4I9D0indUi+YGk88Q3uEkiJu9V1lx3rZ99EgksLoGCS7
         4VzjNyBYpYiqWhF8rd0dvCgNHziguMk9sbbV7/Lzh90zJzCEVzX6CN973MVio6wuM++B
         mRaC+8tCCCbojaCsI0brTclo/E1fWpFrsAyrqXpCKsMPnbWB+ciQ7vmpnTgP0fPEb8ne
         4vXfzFYOykbzNl5+0qqRZzkHzZRaIqeahd+bduT6/s0Ndc3fzf/WJCBHnnfXRoCMqSXH
         2GOVoyX15S2rFM9mLV6XfsDpKf5fuo5tqZb/w2QtfE4B/xBIUL872Rpvr8owPP170woR
         ltEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=qqmmhku5NomnoxUpgEvNAyGjbBl3yg9ZxTTgvkD102M=;
        b=gcTYRt+fFhX7UMOi7UwgSJ2vQMEkc05tfhGScQit8ZzlmoTdheGZZmoy6G4LkkBNJB
         G3ewB52CXpazLXchTDkizW0+eRAKqSBOcXqF8rW4WEDT7Kq2XJuEKujt8XAG7JeWNQ75
         YpxNh91FvHalAxpjdIkcmgn9vaog02JPNj/0odM/sbHU4mxlagpg4UrnEpMXhjAH8+sl
         24H+h1wO5EM323DFdqev+60LFUhCzzempruAZMlw5eDicVn3O5r0Ic74nN9FPLKBENkz
         Zz7WZnJid3XjzXgT422Hr4WR3UXA5bN4Kt6/gzSn5t65qBglfDXZAnfkjZj94BgAWQiF
         sRag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JFPAa0My;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor7238128pln.54.2019.05.10.12.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 12:08:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JFPAa0My;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=qqmmhku5NomnoxUpgEvNAyGjbBl3yg9ZxTTgvkD102M=;
        b=JFPAa0MyN843d9zgKq8io8uewPn7zQ1PlQO8aYvOzS1Mi4/cHmf4jamtybEB7GaMdr
         KQKmp/J9r0HGIdRuJ/pkRJn8cj6NUlBep2gl0Jwa4FytvdYtKgSqtH0gsuq+tlZFZB50
         qaIVA8B5VcbN4RkEpELN/98rLFrA+O95RU+IjnZLOxsYUlx3OV+iP1Q7MR39z/xEZTMm
         MqthEewVVIosDHZ8TNNC+DHXXKw8d3hzaBJweBxrZzrC22mujl3Ai2pHvhT2nJ/gq4G3
         Wafflc2ems0wgOGPDIkzVZiSFwxjEyOADGhqyfbq7Gk/aaW4QmnQBGXsvExXeC8W17wr
         uplg==
X-Google-Smtp-Source: APXvYqxh11p32GP45ZppQiFiuUUwfmEh21dKrieWhO5ETBbE1nGlSaazDVYxL6/U8v91WdBwtgfbfg==
X-Received: by 2002:a17:902:4503:: with SMTP id m3mr15124532pld.97.1557515318193;
        Fri, 10 May 2019 12:08:38 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.31])
        by smtp.gmail.com with ESMTPSA id g83sm3699314pfb.158.2019.05.10.12.08.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 12:08:37 -0700 (PDT)
Date: Sat, 11 May 2019 00:38:32 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: akpm@linux-foundation.org, jack@suse.cz, keith.busch@intel.com,
	aneesh.kumar@linux.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH] mm/gup.c: Make follow_page_mask static
Message-ID: <20190510190831.GA4061@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

follow_page_mask is only used in gup.c, make it static.

Tested by compiling and booting. Grepped the source for
"follow_page_mask" to be sure it is not used else where.

Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 mm/gup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index 91819b8..e6f3b7f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -409,7 +409,7 @@ static struct page *follow_p4d_mask(struct vm_area_struct *vma,
  * an error pointer if there is a mapping to something not represented
  * by a page descriptor (see also vm_normal_page()).
  */
-struct page *follow_page_mask(struct vm_area_struct *vma,
+static struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int flags,
 			      struct follow_page_context *ctx)
 {
-- 
2.7.4

