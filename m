Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45C1EC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 013F3222DF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 22:03:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TNPGouO5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 013F3222DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5143C8E0004; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AA498E0001; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 191548E0004; Fri, 15 Feb 2019 17:03:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAB8A8E0003
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 17:03:50 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id u66so6715729ybb.15
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 14:03:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding:dkim-signature;
        bh=diqLFW2QNnU4w8AwbrLLHI+jIAOfRTJB7J6DX23hrZI=;
        b=YZUw6vitG7wr6vuHhz7LdgGiTCzGq9IOaCxXlxS8C3IkpLomlilyaL0fJOLVVofPH4
         eapVgRH04P/DMjMEo1NH/PtE9/hbexfDnCB9anmd9vCeuqXz4WX2TizSDfea+sXp1/ym
         m+4hpena/o2BGt0QF7OaE0qydWJMJzN8gOrqKmo97sor1sosFiY6MFMrkeD+HkgU2Qb7
         +LMBg+VP1bnqUVwfDXGiU3uORnXGMB53ldRgmD3DzmkngF+FPrGkvsc6rL+L/5musSeo
         C6P/Ha91JjgqVP0jio6xUTeQkO2jDl84alZjb+VnFPSYdqY93mRjsCcwXe+kLA6pmBtm
         Gbeg==
X-Gm-Message-State: AHQUAuaHDwd/Zh0gAmwcIBpB8zaVhKMxWIlrzF55OLNLCqOwhrNbt4I5
	uh/p1B8KyDw1974cnAGWdlH346jI74My5/JVDi0zerbTGuP8DZgVEYrlT/pT+5pS/nw2gyfy1az
	55S29y/dep21+T1KSyRNNxbpt4OrHCJZ2v52QLWikAahW4EQZmijn4OdidAf4eX+rjA==
X-Received: by 2002:a81:9345:: with SMTP id k66mr10061635ywg.509.1550268230623;
        Fri, 15 Feb 2019 14:03:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxEwjj8szBRl0zt0Fnlxa0LHEALHHKv+MvC+qp5u6zUJEDWSPO8gOmxTgegrN/LEl/5lUi
X-Received: by 2002:a81:9345:: with SMTP id k66mr10061581ywg.509.1550268229903;
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550268229; cv=none;
        d=google.com; s=arc-20160816;
        b=koU+2mTvpBTrhLUzmxDPR51paUHcPPHNXV6jLAsyFPBd6GzFATKF6scsHualXeHu+K
         rW5+Gn+zUBUXp+ENhgvVOqBe+01sNiEc+EGMlZBzzHXODsOrF54qOLPTYKISmnGZjoIb
         fssnhWZsD3LcrwWPE4C00kp7tI6I/WKsXpkLMrDDfFDr3X82TZeogaZJdSIl6C7+tTO8
         mYs+IiuanSxndSjZfeJlYajBMEwgAP2i8fjoU9RSxm1cYFN2qCo8b0ye1EDSZBdUJjE1
         t4lNxmeGXbpty5rHfXbdkhgMs3Zn5QT3GYpvaEeQGOeZGmVZv3E6OKxWLWBi7OGOSq+O
         ZVWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from;
        bh=diqLFW2QNnU4w8AwbrLLHI+jIAOfRTJB7J6DX23hrZI=;
        b=jVkPdJcLjnLBC9WdHhJ6ReIWrXQLxYu7yJbYQj6OT+4f5ra/SI7JiTlMnqeD/yQJPB
         0WMV7k4Keo/b27Yq6JxQolCkfKKVQuv45L51vSXVvBdX2a4GJHRrMUgoPtiKkAQqhqXX
         5PoYqoMStY7hDaUOdndd3pOq+Uy6Mps/Cns4T1BCiR+oKsZw/47aZlhrSUghxAKjCpFc
         0U7zj2jqM1GJ08+nG+t1MsIyTXyoaViuo5ck59mHJp5iGxmokN0odZDhmX2KqvPpZE1L
         CUx2b9mHkBxXuLdShBoguE3ukuPXk7UrM3p0FG69Ov92zFZCTvyD+3UKDHmztEAwOwmB
         Bvqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TNPGouO5;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id i6si3997576ybl.194.2019.02.15.14.03.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 14:03:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TNPGouO5;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6737200001>; Fri, 15 Feb 2019 14:03:12 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 14:03:49 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 15 Feb 2019 14:03:49 -0800
Received: from nvrsysarch5.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 22:03:48 +0000
From: Zi Yan <ziy@nvidia.com>
To: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko
	<mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>, John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>, Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>, Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 03/31] mm: migrate: Add tmpfs exchange support.
Date: Fri, 15 Feb 2019 14:03:06 -0800
Message-ID: <20190215220334.29298-4-ziy@nvidia.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215220334.29298-1-ziy@nvidia.com>
References: <20190215220334.29298-1-ziy@nvidia.com>
MIME-Version: 1.0
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550268192; bh=diqLFW2QNnU4w8AwbrLLHI+jIAOfRTJB7J6DX23hrZI=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Transfer-Encoding:Content-Type;
	b=TNPGouO5nlWg/9pe/V0ZKIAiRe2RPkwjLNfb4tKTKlSwmLSAI6tkwxTsSHbrgK3em
	 9lIgIxPe3xW52UImP1RcQXpij3t1nTvgfLzIb2VcLgTNyr7PgA6Jv19FJ8o7o5wm3m
	 TEuF06h4KG4BglTfKWy3Rgwhtax/XYYN+hxVonRdE7YehaicjOeZ+Q4jLKApnJAzkE
	 VJNWWqi68PckR0+9TCndFpK/oBN8OUX+/26Vr7GScR5K9ZjIMIDzt34IFDH4ZvzNOj
	 XQXRlgiZc/afkTojNTryknrFCPq+zNenWZ2PHI0VydDOxlDj/6YlI2PN+lw0corpOu
	 id6BMexbxH+Dg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tmpfs uses the same migrate routine as anonymous pages, enabling
exchange pages for it is easy.

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 mm/exchange.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/exchange.c b/mm/exchange.c
index 8cf286fc0f10..851f1a99b48b 100644
--- a/mm/exchange.c
+++ b/mm/exchange.c
@@ -466,7 +466,10 @@ static int exchange_from_to_pages(struct page *to_page=
, struct page *from_page,
 		rc =3D exchange_page_move_mapping(to_page_mapping, from_page_mapping,
 					to_page, from_page, NULL, NULL, mode, 0, 0);
 	} else {
-		if (to_page_mapping->a_ops->migratepage =3D=3D buffer_migrate_page) {
+		/* shmem */
+		if (to_page_mapping->a_ops->migratepage =3D=3D migrate_page)
+			goto exchange_mappings;
+		else if (to_page_mapping->a_ops->migratepage =3D=3D buffer_migrate_page)=
 {
=20
 			if (!page_has_buffers(to_page))
 				goto exchange_mappings;
--=20
2.20.1

