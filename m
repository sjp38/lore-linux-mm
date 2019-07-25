Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD375C76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 541F322BE8
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:45:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 541F322BE8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9D3E8E0027; Wed, 24 Jul 2019 22:45:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4D2C8E001C; Wed, 24 Jul 2019 22:45:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D630B8E0027; Wed, 24 Jul 2019 22:45:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id B76008E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:45:04 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id x24so53259017ioh.16
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:45:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=vz0jx96ofZ9UjjGvBEksui8236reJmZLSSfYCSJN4Q8=;
        b=NCE2aQT8v7POxXFm26fEvl4R4XpOk20bOvjcqWCy/z4rF7MfGiUcSmzMslkA59LLfh
         0P5mVogseu4ltYe6Iel/gy28cu1xA/Q9odSdr9gkEykrOgeCUNMwljOndzgm68+3nhW/
         qwPJPMla1VpsDtZhiVpOpJAEgLDmxFAGOOwZdA9pIQhCutVrZCdHvyhqmVArpTQhLvkK
         7OE+0nh9IXOMKHxtyPt2+bJnbKcJnU2oC03NzC7Td3Xc9Jm0PI1D9XQZcVw8qkNhSq31
         TtzE0vsCKJFwMiXWxJyMvkzBvgE/CKq+lDQU9GF45aTuNDJsxszLLTyHd5hr8KCNSXJH
         ftpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
X-Gm-Message-State: APjAAAWlrlDesJzorkzReZdU6KYZthaKpzW6Sza8MYvGqZcsdbwL8O+l
	fQlGDKzyRQ+Vx9REOPKGI7dtRDsVQREJXLFH1WOAK7dJFYQ7Yi3FybJTcCJhzUKzf/rRNPZg/px
	mWhNfL1uRC6ftYRYTTDX5pVcIzgdAeCzP7/whiddoYdKF1s7OFUDODlr3X7d9KaV0AA==
X-Received: by 2002:a5e:8618:: with SMTP id z24mr81900102ioj.174.1564022704531;
        Wed, 24 Jul 2019 19:45:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWTzXCRUG+MtCS9pOq3krOJ/TvKM60LIaWzI49D8BVc0Kl3TkfPQTtRqglTwU9zHnyjSEw
X-Received: by 2002:a5e:8618:: with SMTP id z24mr81900063ioj.174.1564022703792;
        Wed, 24 Jul 2019 19:45:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564022703; cv=none;
        d=google.com; s=arc-20160816;
        b=UL7ySqHNtCDUJghZI36ZermTgJGIwMYjPojj6zRLaQC5caseOwQyN0k5yr0SNJMM4T
         dO9Qf4qISp1g88XqGnEDYq/VdwdNvwzPlrZLsuIwcT4xRlTHcsbnVO6c0PdZxtHO4Ll0
         dKtAxF71mzz4JAXiZkgsRJPNfqnjGPq2JzbTbxMPzK502NfQAAhtoa+sLDvBZ/aGc6tg
         CEmVgN+1LGyvbPXAmR093k3Us254U4LhDpVm4gyhYsnS7tOI2IzYBOaJ9tu/VC66vEIW
         EVHYLXOZwXwwzG4HZ7A37Jj33NqiMqQ0wbQ/fjdOZkstADvZWIO1TjkDQK9dRTkiv3vc
         fAgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=vz0jx96ofZ9UjjGvBEksui8236reJmZLSSfYCSJN4Q8=;
        b=tKPzcSEzk7w8CqlBnaj7vI7jv7EJJPtqm074j8GECXMeeBrv4g1iS5XTwNCx089sXH
         1JmvP7e8QHiRxpPaCcnp+KGS5mZnu2Ufoi3TT5mRyEvvkrh1zmB4N+7oHOA+v17tpL3k
         ECAXqG1CDmfNrIlfrtTciEED/seROf4oKCgVPT+vo2jOCVy4XpsFcFAfT/1qcDOJGlTA
         OQSlNIjZQvN44qoILrbXEr5VyPsmusdRsJz4Yzd/Ddnj5UrG9BH8G4Aif/lEmhbfawJj
         KHv/bZMS1OQB5CUv3Fii1DR52Rd4uoDwLsCA2ewPFRf/7d+hiBwVbvcKZudzDFSjs/IH
         VC7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id c7si60146509iot.78.2019.07.24.19.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:45:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6P2ijAV011189
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 25 Jul 2019 11:44:45 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2ijmt010164;
	Thu, 25 Jul 2019 11:44:45 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2hcGH020828;
	Thu, 25 Jul 2019 11:44:45 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.147] [10.38.151.147]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7096052; Thu, 25 Jul 2019 11:31:18 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC19GP.gisp.nec.co.jp ([10.38.151.147]) with mapi id 14.03.0439.000; Thu,
 25 Jul 2019 11:31:17 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        "Naoya Horiguchi" <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>,
        Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
Subject: [PATCH 1/2] /proc/kpageflags: prevent an integer overflow in
 stable_page_flags()
Thread-Topic: [PATCH 1/2] /proc/kpageflags: prevent an integer overflow in
 stable_page_flags()
Thread-Index: AQHVQpEJxWCHK2zdZkqohzEuXiyadQ==
Date: Thu, 25 Jul 2019 02:31:16 +0000
Message-ID: <20190725023100.31141-2-t-fukasawa@vx.jp.nec.com>
References: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
In-Reply-To: <20190725023100.31141-1-t-fukasawa@vx.jp.nec.com>
Accept-Language: ja-JP, en-US
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.135]
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

stable_page_flags() returns kpageflags info in u64, but it uses
"1 << KPF_*" internally which is considered as int. This type mismatch
causes no visible problem now, but it will if you set bit 32 or more as
done in a subsequent patch. So use BIT_ULL in order to avoid future
overflow issues.

Signed-off-by: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
---
 fs/proc/page.c | 37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 544d1ee..69064ad 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -95,7 +95,7 @@ u64 stable_page_flags(struct page *page)
 	 * it differentiates a memory hole from a page with no flags
 	 */
 	if (!page)
-		return 1 << KPF_NOPAGE;
+		return BIT_ULL(KPF_NOPAGE);
=20
 	k =3D page->flags;
 	u =3D 0;
@@ -107,22 +107,22 @@ u64 stable_page_flags(struct page *page)
 	 * simple test in page_mapped() is not enough.
 	 */
 	if (!PageSlab(page) && page_mapped(page))
-		u |=3D 1 << KPF_MMAP;
+		u |=3D BIT_ULL(KPF_MMAP);
 	if (PageAnon(page))
-		u |=3D 1 << KPF_ANON;
+		u |=3D BIT_ULL(KPF_ANON);
 	if (PageKsm(page))
-		u |=3D 1 << KPF_KSM;
+		u |=3D BIT_ULL(KPF_KSM);
=20
 	/*
 	 * compound pages: export both head/tail info
 	 * they together define a compound page's start/end pos and order
 	 */
 	if (PageHead(page))
-		u |=3D 1 << KPF_COMPOUND_HEAD;
+		u |=3D BIT_ULL(KPF_COMPOUND_HEAD);
 	if (PageTail(page))
-		u |=3D 1 << KPF_COMPOUND_TAIL;
+		u |=3D BIT_ULL(KPF_COMPOUND_TAIL);
 	if (PageHuge(page))
-		u |=3D 1 << KPF_HUGE;
+		u |=3D BIT_ULL(KPF_HUGE);
 	/*
 	 * PageTransCompound can be true for non-huge compound pages (slab
 	 * pages or pages allocated by drivers with __GFP_COMP) because it
@@ -133,14 +133,13 @@ u64 stable_page_flags(struct page *page)
 		struct page *head =3D compound_head(page);
=20
 		if (PageLRU(head) || PageAnon(head))
-			u |=3D 1 << KPF_THP;
+			u |=3D BIT_ULL(KPF_THP);
 		else if (is_huge_zero_page(head)) {
-			u |=3D 1 << KPF_ZERO_PAGE;
-			u |=3D 1 << KPF_THP;
+			u |=3D BIT_ULL(KPF_ZERO_PAGE);
+			u |=3D BIT_ULL(KPF_THP);
 		}
 	} else if (is_zero_pfn(page_to_pfn(page)))
-		u |=3D 1 << KPF_ZERO_PAGE;
-
+		u |=3D BIT_ULL(KPF_ZERO_PAGE);
=20
 	/*
 	 * Caveats on high order pages: page->_refcount will only be set
@@ -148,23 +147,23 @@ u64 stable_page_flags(struct page *page)
 	 * SLOB won't set PG_slab at all on compound pages.
 	 */
 	if (PageBuddy(page))
-		u |=3D 1 << KPF_BUDDY;
+		u |=3D BIT_ULL(KPF_BUDDY);
 	else if (page_count(page) =3D=3D 0 && is_free_buddy_page(page))
-		u |=3D 1 << KPF_BUDDY;
+		u |=3D BIT_ULL(KPF_BUDDY);
=20
 	if (PageOffline(page))
-		u |=3D 1 << KPF_OFFLINE;
+		u |=3D BIT_ULL(KPF_OFFLINE);
 	if (PageTable(page))
-		u |=3D 1 << KPF_PGTABLE;
+		u |=3D BIT_ULL(KPF_PGTABLE);
=20
 	if (page_is_idle(page))
-		u |=3D 1 << KPF_IDLE;
+		u |=3D BIT_ULL(KPF_IDLE);
=20
 	u |=3D kpf_copy_bit(k, KPF_LOCKED,	PG_locked);
=20
 	u |=3D kpf_copy_bit(k, KPF_SLAB,		PG_slab);
 	if (PageTail(page) && PageSlab(compound_head(page)))
-		u |=3D 1 << KPF_SLAB;
+		u |=3D BIT_ULL(KPF_SLAB);
=20
 	u |=3D kpf_copy_bit(k, KPF_ERROR,		PG_error);
 	u |=3D kpf_copy_bit(k, KPF_DIRTY,		PG_dirty);
@@ -177,7 +176,7 @@ u64 stable_page_flags(struct page *page)
 	u |=3D kpf_copy_bit(k, KPF_RECLAIM,	PG_reclaim);
=20
 	if (PageSwapCache(page))
-		u |=3D 1 << KPF_SWAPCACHE;
+		u |=3D BIT_ULL(KPF_SWAPCACHE);
 	u |=3D kpf_copy_bit(k, KPF_SWAPBACKED,	PG_swapbacked);
=20
 	u |=3D kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);
--=20
1.8.3.1

