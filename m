Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F7ABC76186
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:46:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D975B22BEB
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 02:46:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D975B22BEB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vx.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 772428E0028; Wed, 24 Jul 2019 22:46:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7207E8E001C; Wed, 24 Jul 2019 22:46:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E8EB8E0028; Wed, 24 Jul 2019 22:46:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8AF8E001C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:46:31 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so53244731iol.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 19:46:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=ej3ixoFYFkq09MGF7VNo/5o+dyXIYh3STWtzRBJRtTs=;
        b=pXtRZF9VqIaz7yQ2WVp6SyD53jjq1+8evo1/BCsAfuXIZhYv8v1l7FFlLBpZafpTBt
         FtbkoJPqKsIKCGznwUDi2+kiK6a0Ev7EzxYo02SOyTHiiF/Zy7PVyrfL0v1Dr7JlyAcu
         6XBsq8T+N9VyyGPPRjkDQuXUVM1QWl9h+rxUefHHPeq+hVoQOaStbsrm8AwbVbrxWXyP
         NPth+iRhccLs9UXPvaZ8hW2LdFUTL+eRe71f8Q9E9Dg8TwiXqDdzENF4Kaz05406CQVa
         E/sJYayekRpF7KHWHoex+lah3oy9qjiQVZciK/bgrCmripB8ZEeDJegbB6V2KXZ22tDQ
         gbVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
X-Gm-Message-State: APjAAAVLLci4fNR11q/Ub+jOX88eldcvDHEZ/A13vhpV8QZGziu64g9t
	lf+GLNu321XTrL8sppqGPJKX9FtVu98V94sKrKlW/tLa98W6z0siHR379NNrgQwo1teeV/dri2V
	0xXrVv0ivQPDOgOIdhknX44+3Y9r4WFrlFja/fIet2ZgFBA/hDH1vgm0syeZILx07ww==
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr76704975iof.184.1564022791012;
        Wed, 24 Jul 2019 19:46:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzwLrKoJx/KDzrSgPiyE952VxbGz+Y2RTrbejnuPFHlwuOELauxq2rJmMdGbl24OAsxtUl
X-Received: by 2002:a6b:c9d8:: with SMTP id z207mr76704921iof.184.1564022789812;
        Wed, 24 Jul 2019 19:46:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564022789; cv=none;
        d=google.com; s=arc-20160816;
        b=Mw2DfWPtOjTyhZ9huSiuHvk00VUpmi1wfz+KoFkFhwCJAn5Wp9GLMmSVxRhRjpHKKW
         0tmDuSj2TLsQiNtjrMJIPyPaobfDxU6HHW/o+hIMHk41nzrxZCjpnTNNOe6ja66akCY0
         LoIGCwBnq0ug8r7Elk9M6KkD8voR8NJHQigG7znVlLQ+wlTKIUuKgBrVqED+C77BhFWL
         FE/QcLW//4IlsUT2A9N1Hz/w4C5vEVAkRCE2DsrxFCvdXkPiYbNKcYXz/l4ceuawKJ/5
         r5jBXF+RoJwg7mlPqXTeYkQjlDQZx+/zYOJDC9PsxjDxzYjUQuP1+xNY0659OISsGw3g
         eVMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ej3ixoFYFkq09MGF7VNo/5o+dyXIYh3STWtzRBJRtTs=;
        b=Aoaxj/2iNIGESiYVVQRtcAKx7yB68rpLUZ+YOoZS7uWTtUBTvVOOZ7reZ2xBF232BY
         CGVcWn7IWgq4B2+w+et/vEEt9buptya4BqdEI1Zj43mFyimMl2dDAAaDR7iONvSiTK5i
         Dr/9jqltkR8IcXvoM92cTqdGIOUMjOuBr9jWIv93FheMOdLVhYAVLd6/Sqk3cSGGsD3x
         3vbUb9yKRteX1BoxqrJaZFRDl2Ijf+SE0idRyTalQ2IR2tCNWENkP7DIuC+YxPQpKLcr
         IJZYTzMCm268GhlRxYYL41nQ4VoEWQ+absfaSS/PFkJw5wAwdaeYPjdNMvodW4rH26kX
         ryRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id y8si73565037jae.39.2019.07.24.19.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 19:46:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of t-fukasawa@vx.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=t-fukasawa@vx.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6P2kGiX012442
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 25 Jul 2019 11:46:16 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2kGxh017452;
	Thu, 25 Jul 2019 11:46:16 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6P2kGb9022572;
	Thu, 25 Jul 2019 11:46:16 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-7096057; Thu, 25 Jul 2019 11:31:20 +0900
Received: from BPXM20GP.gisp.nec.co.jp ([10.38.151.212]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0439.000; Thu,
 25 Jul 2019 11:31:19 +0900
From: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
        "adobriyan@gmail.com" <adobriyan@gmail.com>, "hch@lst.de" <hch@lst.de>,
        "Naoya Horiguchi" <n-horiguchi@ah.jp.nec.com>,
        Junichi Nomura <j-nomura@ce.jp.nec.com>,
        Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct pages
Thread-Topic: [PATCH 2/2] /proc/kpageflags: do not use uninitialized struct
 pages
Thread-Index: AQHVQpEKFGt+j6P+NkKoSe72QQuzoA==
Date: Thu, 25 Jul 2019 02:31:18 +0000
Message-ID: <20190725023100.31141-3-t-fukasawa@vx.jp.nec.com>
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

A kernel panic was observed during reading /proc/kpageflags for
first few pfns allocated by pmem namespace:

BUG: unable to handle page fault for address: fffffffffffffffe
[  114.495280] #PF: supervisor read access in kernel mode
[  114.495738] #PF: error_code(0x0000) - not-present page
[  114.496203] PGD 17120e067 P4D 17120e067 PUD 171210067 PMD 0
[  114.496713] Oops: 0000 [#1] SMP PTI
[  114.497037] CPU: 9 PID: 1202 Comm: page-types Not tainted 5.3.0-rc1 #1
[  114.497621] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
rel-1.11.0-0-g63451fca13-prebuilt.qemu-project.org 04/01/2014
[  114.498706] RIP: 0010:stable_page_flags+0x27/0x3f0
[  114.499142] Code: 82 66 90 66 66 66 66 90 48 85 ff 0f 84 d1 03 00 00 41 =
54 55 48 89 fd 53 48 8b 57 08 48 8b 1f 48 8d 42 ff 83 e2 01 48 0f 44 c7 <48=
> 8b 00 f6 c4 02 0f 84 57 03 00 00 45 31 e4 48 8b 55 08 48 89 ef
[  114.500788] RSP: 0018:ffffa5e601a0fe60 EFLAGS: 00010202
[  114.501373] RAX: fffffffffffffffe RBX: ffffffffffffffff RCX: 00000000000=
00000
[  114.502009] RDX: 0000000000000001 RSI: 00007ffca13a7310 RDI: ffffd074890=
00000
[  114.502637] RBP: ffffd07489000000 R08: 0000000000000001 R09: 00000000000=
00000
[  114.503270] R10: 0000000000000000 R11: 0000000000000000 R12: 00000000002=
40000
[  114.503896] R13: 0000000000080000 R14: 00007ffca13a7310 R15: ffffa5e601a=
0ff08
[  114.504530] FS:  00007f0266c7f540(0000) GS:ffff962dbbac0000(0000) knlGS:=
0000000000000000
[  114.505245] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  114.505754] CR2: fffffffffffffffe CR3: 000000023a204000 CR4: 00000000000=
006e0
[  114.506401] Call Trace:
[  114.506660]  kpageflags_read+0xb1/0x130
[  114.507051]  proc_reg_read+0x39/0x60
[  114.507387]  vfs_read+0x8a/0x140
[  114.507686]  ksys_pread64+0x61/0xa0
[  114.508021]  do_syscall_64+0x5f/0x1a0
[  114.508372]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  114.508844] RIP: 0033:0x7f0266ba426b

The reason for the panic is that stable_page_flags() which parses
the page flags uses uninitialized struct pages reserved by the
ZONE_DEVICE driver.

Earlier approach to fix this was discussed here:
https://marc.info/?l=3Dlinux-mm&m=3D152964770000672&w=3D2

This is another approach. To avoid using the uninitialized struct page,
immediately return with KPF_RESERVED at the beginning of
stable_page_flags() if the page is reserved by ZONE_DEVICE driver.

Cc: stable@vger.kernel.org
Signed-off-by: Toshiki Fukasawa <t-fukasawa@vx.jp.nec.com>
---
 fs/proc/page.c           |  3 +++
 include/linux/memremap.h |  6 ++++++
 kernel/memremap.c        | 20 ++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 69064ad..decd3fe 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -97,6 +97,9 @@ u64 stable_page_flags(struct page *page)
 	if (!page)
 		return BIT_ULL(KPF_NOPAGE);
=20
+	if (pfn_zone_device_reserved(page_to_pfn(page)))
+		return BIT_ULL(KPF_RESERVED);
+
 	k =3D page->flags;
 	u =3D 0;
=20
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f8a5b2a..2cfc3c2 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -124,6 +124,7 @@ static inline struct vmem_altmap *pgmap_altmap(struct d=
ev_pagemap *pgmap)
 }
=20
 #ifdef CONFIG_ZONE_DEVICE
+bool pfn_zone_device_reserved(unsigned long pfn);
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap);
 void devm_memunmap_pages(struct device *dev, struct dev_pagemap *pgmap);
 struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
@@ -132,6 +133,11 @@ struct dev_pagemap *get_dev_pagemap(unsigned long pfn,
 unsigned long vmem_altmap_offset(struct vmem_altmap *altmap);
 void vmem_altmap_free(struct vmem_altmap *altmap, unsigned long nr_pfns);
 #else
+static inline bool pfn_zone_device_reserved(unsigned long pfn)
+{
+	return false;
+}
+
 static inline void *devm_memremap_pages(struct device *dev,
 		struct dev_pagemap *pgmap)
 {
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 6ee03a8..bc3471c 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -72,6 +72,26 @@ static unsigned long pfn_next(unsigned long pfn)
 	return pfn + 1;
 }
=20
+/*
+ * This returns true if the page is reserved by ZONE_DEVICE driver.
+ */
+bool pfn_zone_device_reserved(unsigned long pfn)
+{
+	struct dev_pagemap *pgmap;
+	struct vmem_altmap *altmap;
+	bool ret =3D false;
+
+	pgmap =3D get_dev_pagemap(pfn, NULL);
+	if (!pgmap)
+		return ret;
+	altmap =3D pgmap_altmap(pgmap);
+	if (altmap && pfn < (altmap->base_pfn + altmap->reserve))
+		ret =3D true;
+	put_dev_pagemap(pgmap);
+
+	return ret;
+}
+
 #define for_each_device_pfn(pfn, map) \
 	for (pfn =3D pfn_first(map); pfn < pfn_end(map); pfn =3D pfn_next(pfn))
=20
--=20
1.8.3.1

