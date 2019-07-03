Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4448C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B30B218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 12:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GRizeqOI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B30B218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C13DD8E0001; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA14E6B0008; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EF108E0003; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA5B8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 08:24:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i13so1537022pgq.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 05:24:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tV5Q9vU+tNXeMlXcZgsSk1/vWrS+XQOTNkGpzgJ8SaM=;
        b=iZfnDZnwW0I+l0sGF4WR7j4HNsqLTz8+ukfHAMDLl6zAaVNb4EWxEHaPWTyIvksRSk
         mWvBGlKDLBR79nlvM+G6klMz5MZ77cW9UflA7dijIGr8/gvy9GjPOtqh+B6stW5SjDub
         RK8Jx3ROmnp9RQGB2ds2bgIZwq7NMsb9MmubpOQ7u3OS0tSJH1FMZAESyjQtqpcncWDx
         bN6rHAHwMDH+ASt0xWtn3KQRCp/Xe+X1eJBbFjQiHp6TPGaupD2G6xWV331QaTWRl8rI
         eTTuIQR/oQFh6Ni3ADTrMMP/5LQ69a5IODVnfkcYXr4T7QO3SnEfhT6Lr3YiuVkVge3p
         Rhig==
X-Gm-Message-State: APjAAAVJfGws6atkxuxb5VXk3SsOmcwB53U6Y02TpZe7Q+r+06KdLeKK
	N3kC1flrjaTOOSubHXaynuTKFwY40cOGj6HCV6DGV73vLroPY/zK0CPVv70HbW8iIehpoAw7rdp
	A51/gB/xfwUrfSEuwTZ83h5Y7G37RI1HFmF+3yTDGmQticRbdzkUmCQUFvH0IOrY=
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr8446947pgm.433.1562156643944;
        Wed, 03 Jul 2019 05:24:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu26/IFOFIYL5sgL0bwem7MPP+RbJQQ5huFfpnZR1EXoShDxI4V9LtisRhMJIjsPKHmTrF
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr8446858pgm.433.1562156642853;
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562156642; cv=none;
        d=google.com; s=arc-20160816;
        b=YqleEeWo6IY9HjmsdGT9pyIOVOJFtdu8xuueE01uyNoqBpqP15fyIe/xLOpIHryJ4p
         25lh+XzT1Lp5ypXolxEIZ7ZQKz/XsYfdGEjm/iZ7WmDoUX3HCAm4fPElWzN6Essa4iO2
         nx8OsrrtqzylJJqodvqwFavJngkKrt6AITQfhFyFpeAu7/z8JBzg2w3DClOe9L/XY94M
         gD1rDiCDn8RwugHHj+r5jeCvD1GeyvJEWDrJ/Hrct534XsQ1lKdmCMlcpEO63Ikq/BE3
         fqnO+kqMO0jekwYBkALXi+tmw+tOiWEUxi6H3BsRh2VuRXE+obncvpusW842atYFVSpP
         iM3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tV5Q9vU+tNXeMlXcZgsSk1/vWrS+XQOTNkGpzgJ8SaM=;
        b=l3C3d0ZTbEPmqliN4ydcOXKDtGDgLDAjH4Pb1JhPZtSe899NoNN3O53ixHaiSpIl46
         VxVHzFK4Mkjm4f0OWcsTWRK81h/Fhcz0w/8TYXzIT11GbIs3FKORci7ZV/bfPg2MxFI2
         XW+n90isB16RL5bksPnoTzJS+M47u5oXJtVOtm7nQ8A/lksdv5UyqXClk+CwAwZ9uDf4
         R6pD9PEehZKjLJBUxwDY+mtplrvc7CGO3dbaoCZSYX0IDjKYMqNdqW5ncl10v64sD/WC
         2E6Y08t7Xojwfsh6+w20b0cu8z7k4BRd2wI3gISI9PHAajPw3VQHlKF5ivzKvXUzGKvb
         8opw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GRizeqOI;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k69si2210269pgc.85.2019.07.03.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 05:24:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GRizeqOI;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=tV5Q9vU+tNXeMlXcZgsSk1/vWrS+XQOTNkGpzgJ8SaM=; b=GRizeqOIeAVt/poyWWniKCrW9O
	HQDXXZypve6C0K/gMwtK2UXRbImtD+Q5eL9fUTqoplsTqLQZiT6ZsuJ2eLIVAet2qqxjswXYIGEgU
	bUvEEeuTnOACbzDbhuCvRQuHl6g5DrwoYXkLgBOS3JpSvaayVxZ7ZrXbLAg7WAG3YAZihaHKGxnrk
	xYoDO3xz5xIkkvkyznXrdBMrcu520YDwpBYHu/V7PXekqLAUx+e6fLDLAT83R+ULpNO3EQa+/ukes
	AmAraVq9Wtf1Qunn8OCKA6AO/t3oiMA93AQDiFv7xC/3t9fwx4Jm1lgNDbqA9TCJTXfkDdmeoE8mn
	qLv1k1jQ==;
Received: from [12.46.110.2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hieIq-0002G1-4b; Wed, 03 Jul 2019 12:24:00 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>,
	linux-riscv@lists.infradead.org,
	linux-arch@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] mm: stub out all of swapops.h for !CONFIG_MMU
Date: Wed,  3 Jul 2019 05:23:59 -0700
Message-Id: <20190703122359.18200-4-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190703122359.18200-1-hch@lst.de>
References: <20190703122359.18200-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The whole header file deals with swap entries and PTEs, none of which
can exist for nommu builds.  The current nommu ports have lots of
stubs to allow the inline functions in swapops.h to compile, but
as none of this functionality is actually used there is no point
in even providing it.  This way we don't have to provide the stubs
for the upcoming RISC-V nommu port, and can eventually remove it
from the existing ports.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/swapops.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 4d961668e5fc..b02922556846 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -6,6 +6,8 @@
 #include <linux/bug.h>
 #include <linux/mm_types.h>
 
+#ifdef CONFIG_MMU
+
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
  * get good packing density in that tree, so the index should be dense in
@@ -50,13 +52,11 @@ static inline pgoff_t swp_offset(swp_entry_t entry)
 	return entry.val & SWP_OFFSET_MASK;
 }
 
-#ifdef CONFIG_MMU
 /* check whether a pte points to a swap entry */
 static inline int is_swap_pte(pte_t pte)
 {
 	return !pte_none(pte) && !pte_present(pte);
 }
-#endif
 
 /*
  * Convert the arch-dependent pte representation of a swp_entry_t into an
@@ -375,4 +375,5 @@ static inline int non_swap_entry(swp_entry_t entry)
 }
 #endif
 
+#endif /* CONFIG_MMU */
 #endif /* _LINUX_SWAPOPS_H */
-- 
2.20.1

