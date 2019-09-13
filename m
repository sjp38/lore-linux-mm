Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA3F0C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:18:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B1D720CC7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 09:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Yd8XmSUa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B1D720CC7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DCBE6B0005; Fri, 13 Sep 2019 05:18:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 266B46B0006; Fri, 13 Sep 2019 05:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12CDB6B0007; Fri, 13 Sep 2019 05:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0138.hostedemail.com [216.40.44.138])
	by kanga.kvack.org (Postfix) with ESMTP id DF8CB6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 05:18:55 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 8B6662A4AA
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:18:55 +0000 (UTC)
X-FDA: 75929347830.06.value20_30c24d4161158
X-HE-Tag: value20_30c24d4161158
X-Filterd-Recvd-Size: 4469
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 09:18:54 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id y91so26410317ede.9
        for <linux-mm@kvack.org>; Fri, 13 Sep 2019 02:18:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=P+McjP7Vs/8Fdw818QwhQTYN2XV5u34Z3buqpTv4oXc=;
        b=Yd8XmSUaTaf5ZXgKPRqAuXJjkPnnIKhtkUDGK4eSkYWR2z+WrZsHrkfoEoYge1pAwM
         O/9uvHx98sl6+wB8+0mZewgDrizHc6Y40mM2Vil7twDyF3v9EabEVJD+ytCFQe63erMX
         cJU3UlfGLt5Nkbmnt2u/lrGZwZQt/MyteUxnz+N8+8PTtjBumNMjS2GygxXoPBjtNKIu
         Qx4uNIPEV6oFHzd5xUoMrkdM/07AQaZ0n+Cl0xs6QOYmtdAdQezQWuEio2R6Xvvz4NFB
         O9zIEae/QqfUSiWX9+uc+Vr4thoL6wlrqqs/TqdTe2s/UmYz5D0XXa/HirqYkU3UreWM
         tdig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=P+McjP7Vs/8Fdw818QwhQTYN2XV5u34Z3buqpTv4oXc=;
        b=K6Xp14XUmZa0zg9EEoIQN96+ldey0ozt4KmlpdobYZoMi/7lLqOg2suO3jpDUGvi3w
         Ih3QC9Tcl13riZPEMVzC2gqwO+u7lll/xQYgpP3OeNSzbzllvjUKvnFV5Tk1V2O4SHRQ
         JuZ/SNmMpq7Z6zZGyUxHF00VT4gh+IzHvTAwCLzC9Jvydr0LguQ2vvXyk28HKKzJuCEE
         ahae+2ZOpH7Cbcz8MyUqL1LyizDFWO6jTyWj/1DdTyiKv56dVBov8No4mTxHJHA3VUVJ
         a+oFATw9zb7XU2aR/gIoQfW3bwWB6L6UDauzSegr6x1bCJ4S07XmwmCSphCp7LPw0J1R
         hvmg==
X-Gm-Message-State: APjAAAVBFDvSA0AESg+JIwwBmLxTeWiY7N4wfglRNs+//66Vx+mL1bub
	DIcnUA9o+rjcsP7NHD6YKOqUCQ==
X-Google-Smtp-Source: APXvYqxrvAdCPt/mVZYhIV/ppIx9ZAjVNEE6Dhb2/z3ku9W3ZB6upKxDogwZJJt3jIDzN3+F9eEpEA==
X-Received: by 2002:a50:c351:: with SMTP id q17mr9016890edb.123.1568366333883;
        Fri, 13 Sep 2019 02:18:53 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j20sm5201057edy.95.2019.09.13.02.18.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Sep 2019 02:18:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 3A8F510160B; Fri, 13 Sep 2019 12:18:55 +0300 (+03)
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: Do not queue fully unmapped pages for deferred split
Date: Fri, 13 Sep 2019 12:18:49 +0300
Message-Id: <20190913091849.11151-1-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding fully unmapped pages into deferred split queue is not productive:
these pages are about to be freed or they are pinned and cannot be split
anyway.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/rmap.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 003377e24232..45388f1bf317 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1271,12 +1271,20 @@ static void page_remove_anon_compound_rmap(struct=
 page *page)
 	if (TestClearPageDoubleMap(page)) {
 		/*
 		 * Subpages can be mapped with PTEs too. Check how many of
-		 * themi are still mapped.
+		 * them are still mapped.
 		 */
 		for (i =3D 0, nr =3D 0; i < HPAGE_PMD_NR; i++) {
 			if (atomic_add_negative(-1, &page[i]._mapcount))
 				nr++;
 		}
+
+		/*
+		 * Queue the page for deferred split if at least one small
+		 * page of the compound page is unmapped, but at least one
+		 * small page is still mapped.
+		 */
+		if (nr && nr < HPAGE_PMD_NR)
+			deferred_split_huge_page(page);
 	} else {
 		nr =3D HPAGE_PMD_NR;
 	}
@@ -1284,10 +1292,8 @@ static void page_remove_anon_compound_rmap(struct =
page *page)
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
=20
-	if (nr) {
+	if (nr)
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, -nr);
-		deferred_split_huge_page(page);
-	}
 }
=20
 /**
--=20
2.21.0


