Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8622AC76195
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BAD22083B
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:58:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="c6dwQn1n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BAD22083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC14D8E000F; Sun, 21 Jul 2019 11:58:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D716D6B000E; Sun, 21 Jul 2019 11:58:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C61248E000F; Sun, 21 Jul 2019 11:58:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 899086B000D
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:58:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so21973123pgk.16
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:58:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JyrOjFUx/MRse3HXWL5eBpv0RUzUDf7uqwjLdruvk74=;
        b=c6DwZahdmkRKaAjP2WPR7XPec86apIAbQaZYNlqWnA2egkVmiQKm03FHdMXD0df1cq
         JO17JiALKo0GTXw+qh8nMm2VayJOPdfvMIrO3e5CzU9UwGEZwQlG+NWdr2GKFei1kb3a
         Kcpm+jOZ7tgsPmnqocYN5ssy3QMVtKiS0JJGOwK6fOJmKw3Is3Tz0Q7M+BWn/H1v6E8W
         R2H9X0Pj0+XyyZEj17Pb2SGDFKVGSBhe7w2tLblC3/SUhADvBLipKFNYp6BSfIn5JeXg
         II09dR5uxWuA/9vhutOHHytPFltX53zWCw90Zs+IMyToTW+YpOwBfsn1jKzIK4anObgP
         h5ZA==
X-Gm-Message-State: APjAAAVn8+SFpi+6iuEPp60GBUDbdqrJ+wXlLva/tP1NMK9/i5MGEtWz
	tBvzPlEYEhMiE7x4u5LRA00aSXj9tNTJ+dsrl9lLGnS8afaPZ4G/WPDjrCVtypTiVf4hsnqsti4
	6BId0zQ5smRwmthWbcWe4AyIigAxr9r94LP6EoTwwaDemfMkMYyGFge49hIDpcE343g==
X-Received: by 2002:a63:211c:: with SMTP id h28mr66962766pgh.438.1563724703118;
        Sun, 21 Jul 2019 08:58:23 -0700 (PDT)
X-Received: by 2002:a63:211c:: with SMTP id h28mr66962710pgh.438.1563724702276;
        Sun, 21 Jul 2019 08:58:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563724702; cv=none;
        d=google.com; s=arc-20160816;
        b=yrFnPiRAlnPIpH2AChN9fvsvCdh/c7dKteLoPCXT7/etzNd599vvteML2+H6+3JGEE
         QdvOHElk13/bk4gJr9IcTfkJOgjQC0NRSQkqVzMdF5U1JAeLCptQSZ4rvGG6kuEIBXwU
         Zmii/F/O7lmmOIiq1ge8HP3e0nlU5EEPcCTwO30/1eadz6w7fRh0fK67ciQhlnYS+kN4
         LTMNTy84yUiuGtEHTwOMDR0cq88ZnKInP5eaGZbSg8NSopa+DyFg2U7JP6rEN0POR225
         dvzEjO9CYWSqKfQPXfXy30dKLoAWXkVF1+y3uVTfT2kzNzjVvr9jiO0bwYqIXNDYSB16
         ZUyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=JyrOjFUx/MRse3HXWL5eBpv0RUzUDf7uqwjLdruvk74=;
        b=Nz3EiGqzQ6A+jsiDM8OsVz3fih4LJw4IvQHdTVN8Y9/EkGs8W2ACoTOuQ/KK8hXixo
         nxIHW8FCj6kpy0FYIqO7buNcSBDodtwZ1LjKRz3gyG/BQDe6ayHws8ZkfdwRzL6LsVwj
         9vW9vdI3cgsmNdPRnr/LEUxFbH/jvZ+rY7+AGYdxvaHV4gS3/AtskYhpVnCDtK8/Cvi+
         93dwx3joPkTRoFr65n0QxwEjOfpRS3bbIKeU6NLXxiq7enTUW/csFJgZkBcHFfCljp6u
         /jT55DLe79lH/WeP1vgD49TrN0NXptR5IkLSkxBvDKtI2Ns9XHvbGf/h7lr+gx0ltyYZ
         WMIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c6dwQn1n;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i1sor44459797plt.55.2019.07.21.08.58.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 08:58:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=c6dwQn1n;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JyrOjFUx/MRse3HXWL5eBpv0RUzUDf7uqwjLdruvk74=;
        b=c6dwQn1npVP477E/wwUDfZXXs4PH5AGJyZ36YnFhXxt+3hwOGrOvuiiR8gK3sEpjtB
         WiGZWjZ1UNMC1L6Ox3RYGz8Fvu1wKUbJ+JqYncKoWoQaF9hBM5wTRVX9r3WB7z1Q49K0
         4+aNg+MobiwUdEY6WrtZd0FnQQ0o2qXB8gQwFVuCmGe2Jkprim3Je0/L+cu8T9j4wiIh
         myl5IHrGskpz8sAyzbxCnd1e7LSgGIBiCjBwimvtgCUE/LrEor8wEPwb1cnMqV65eiRU
         30xl0000zcHhG3vQsfQtucLqNTeri/MnBwMpv5W5n1g2eLWighpH/DTX8+8d1y6t+S9I
         Kpqg==
X-Google-Smtp-Source: APXvYqxcll7G/MTDDThq2L/Ziyu763qr+TVJaFz6DGgGZzAfccbiPOPYj/IdvSBgFi/gtmy5opFZBA==
X-Received: by 2002:a17:902:a606:: with SMTP id u6mr65491139plq.275.1563724702028;
        Sun, 21 Jul 2019 08:58:22 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id o14sm74720111pfh.153.2019.07.21.08.58.20
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 21 Jul 2019 08:58:21 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: arnd@arndb.de,
	sivanich@sgi.com,
	gregkh@linuxfoundation.org
Cc: ira.weiny@intel.com,
	jhubbard@nvidia.com,
	jglisse@redhat.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH 1/3] sgi-gru: Convert put_page() to get_user_page*()
Date: Sun, 21 Jul 2019 21:28:03 +0530
Message-Id: <1563724685-6540-2-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 4b713a8..61b3447 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
-	put_page(page);
+	put_user_page(page);
 	return 0;
 }
 
-- 
2.7.4

