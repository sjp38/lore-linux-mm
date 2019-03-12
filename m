Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4097CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD1472147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:17:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20150623.gappssmtp.com header.i=@toxicpanda-com.20150623.gappssmtp.com header.b="BgzCtPne"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD1472147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15EDB8E0003; Tue, 12 Mar 2019 16:17:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10F4A8E0002; Tue, 12 Mar 2019 16:17:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3F0D8E0003; Tue, 12 Mar 2019 16:17:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6B768E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:17:46 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b40so3489598qte.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:17:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id;
        bh=QDBzu4VNUY5wLD/K94fhKHZWbt8UrME554jrnUlbq+w=;
        b=DYn/M0LBgYyka0J+g9G/FeHZVLubhQc4R4VwWPykeDwI/sG/5ZJ441QZrTeRvM2OrI
         xlCF6iGJX4Itd9xKEE1pblqNDagbEvnyYxQQd3xw6DVBhlgAxHPnyYRehzJqWnE8ng8b
         lszGmZzVvvrpGFf90jvcN4m+bmMMW1czfnGGgu7SShe87acKrR8uvQ/RCSI2oKNbcNIj
         oKvLLLM3z8qhCip1qL4gshb7srDiUF+MKDCGdn7upU3ktab8w5V/zcGqkUnKU7Tuqcxk
         jvMmau2+YGuS4tdVpqcIQdTlrrPwocTm9FhdtLjPmu1BqorlHZ9cplEny0DyY1TgMN4T
         qbmQ==
X-Gm-Message-State: APjAAAVweIfxFrjzF8UHq5c46DBdzaHZHv6iKT/41WNiYb2CqEejUXHt
	88t+aMh3+wiYwCi8hGKyy/t3bh3Ig2Iisv97sWyr+9MU1UYRlbNO4cSkzc5fynkhhE2XMycBfxs
	gOvfEItNP7/OKLiu6QrCmQlbVIuntc2jDh5FhAgXQc+hnHrBF5Dc4G8nM+nVCTbNk/qDUaf4YTq
	J6xiyOYM+a+bKgGhLES3iRj5Z+rNJGiWSwwaHesh1UuWvZ9jcradX/ZOXc0rcLclqj4RERbqcHL
	fpyOao3twWWSgUPjHzKG/yhsqzPGlTrsUfQC6isgL8g3jiXszpvKoTGnouCggbtQscba8mJOVw2
	ymMqx6KSrVYFepo5YrES60+0nAi9EtXTqZl8UxXVBSXoU5TlHG7J2T3t7TMY+m+Hh0tneMxXvuY
	T
X-Received: by 2002:aed:3bb3:: with SMTP id r48mr32455066qte.278.1552421866546;
        Tue, 12 Mar 2019 13:17:46 -0700 (PDT)
X-Received: by 2002:aed:3bb3:: with SMTP id r48mr32455026qte.278.1552421865832;
        Tue, 12 Mar 2019 13:17:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552421865; cv=none;
        d=google.com; s=arc-20160816;
        b=tpywK+5fl6V6ScP2ocg49EcDNODiY/pV/DZRPyEgrnggzv8qRJN28F4Qx0IJEd1lUd
         qIKp/ZIpcJZ/Qsyug/MsGyVhuL2SMQ25XwVu3gqhGHgyVsXBCOe9KM6+gx2vudOsIss6
         x4raiEpt1XGRjC2Q2qG/2XXoyGu97VpTukzgFamEVCbqxGqSzWkueLoD3B5lJw7Rro+l
         LnilGhddVVhKCRUWLK1VYQdAQOW95ngvKvH3cHhoQpUCcylynVHVWMHDQzXRssoiALn4
         TkLJr5a2kpFCLbEnWo7Pm3Uj2jRVkvGjlrSMtSolBnqonCe1NgmC2Aan179wR9E5p3j8
         r4cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from:dkim-signature;
        bh=QDBzu4VNUY5wLD/K94fhKHZWbt8UrME554jrnUlbq+w=;
        b=T22KgsilcQhSXdj+adT520D3mR5hHosA+EWY44vE3SlIhosWOEP3HEwpuY02OO77Hj
         DU10OWfYiGRGslptxP/XCIgzl3cxL2qmGdapVJ/qbRA6qShO3fvR69723sc3SOBVwYK9
         SyTTR5/mvHR6ewX+euLNt4UWbNIPAvQUsnBqzFUi4jbDTORZlIRXaCTlxwIfK8ZhRI/Y
         86kDnC7x4nZlUSnBZCeA8yZR4ts5rVdKqyBL6q42subLBMXOdTG0mKSHXIA4CjIRvZyy
         WnjBb2I5gxzM0FzsVGQY+T65SJDMNqnLkUBBHwfdpS0ifA6XXXMI6YefniuQbiHaOJuS
         MVoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=BgzCtPne;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e31sor11840642qte.64.2019.03.12.13.17.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 13:17:45 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@toxicpanda-com.20150623.gappssmtp.com header.s=20150623 header.b=BgzCtPne;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of josef@toxicpanda.com) smtp.mailfrom=josef@toxicpanda.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20150623.gappssmtp.com; s=20150623;
        h=from:to:subject:date:message-id;
        bh=QDBzu4VNUY5wLD/K94fhKHZWbt8UrME554jrnUlbq+w=;
        b=BgzCtPne1Bziuagj6IzfwcFxAsDOukfmqfhhBmdQhE9ltra9NJ8tF8Bih0QPt1gZLf
         WbmTnbqpPv7kgQqNY01aOIPem0TBQSb3bIxJypdgUfvoabQsZqYbHbaXlBvI1tLYCqpp
         tT/vs2Wue1s6tOX7W3pUuYGZWbHvdOfcyxQvAq9U6dOPgA3P82fgUeTZBT0ht7YJnuN/
         1bzgaA+0NKCbQIyhRoZ9iHImX+FPHM7WKhIbC39sGqYO+oGiZishki4yGfeWv1e5N48v
         lUlbkK2co6+Wa9pjSvlOKI9jRLgngWufBjWZNTkcg193eYMwqykD1GJh9JYMImftpkJs
         Mbkg==
X-Google-Smtp-Source: APXvYqwWy5PpExEinVaub8tOKn9MGpXVZhR1HmBlNfRCTTZN4vVlfuJ0eW9J8Gms1HOVJ/241Fbx4g==
X-Received: by 2002:ac8:43d5:: with SMTP id w21mr29628188qtn.98.1552421865206;
        Tue, 12 Mar 2019 13:17:45 -0700 (PDT)
Received: from localhost ([107.15.81.208])
        by smtp.gmail.com with ESMTPSA id h194sm5641093qke.61.2019.03.12.13.17.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 13:17:43 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
To: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	kernel-team@fb.com
Subject: [PATCH] filemap: don't unlock null page in FGP_FOR_MMAP case
Date: Tue, 12 Mar 2019 16:17:42 -0400
Message-Id: <20190312201742.22935-1-josef@toxicpanda.com>
X-Mailer: git-send-email 2.14.3
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000061, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We noticed a panic happening in production with the filemap fault pages
because we were unlocking a NULL page.  If add_to_page_cache() fails
then we'll have a NULL page, so fix this check to only unlock if we
have a valid page.

Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index cace3eb8069f..2815cb79a246 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1663,7 +1663,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		 * add_to_page_cache_lru locks the page, and for mmap we expect
 		 * an unlocked page.
 		 */
-		if (fgp_flags & FGP_FOR_MMAP)
+		if (page && (fgp_flags & FGP_FOR_MMAP))
 			unlock_page(page);
 	}
 
-- 
2.14.3

