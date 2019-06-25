Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D50CC48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB907213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="k2Z56jK2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB907213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98AD08E0012; Tue, 25 Jun 2019 10:38:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C3EF8E000B; Tue, 25 Jun 2019 10:38:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F0F88E0012; Tue, 25 Jun 2019 10:38:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F44A8E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so12003872pfi.6
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xf8xwUJqGTGhdY5pjBOHQgYHNWWmClOkIpScch6iAnk=;
        b=KoptTZkJm80gnsrxJrcig4xsMtj5QMQHoOUHTVQ2FaYAqy0ZGYB/6nWnmt3kwMzud3
         aU9skdSuK7wtTHS7jUcyYHtozlNAwAlXIWVTtXgyBvpFXXO8UzobFimFqd2X3buQ/CSv
         0X1yP6Td2mKFJhKh0GMpcIuUiCjX0zSSnxh7a2juS3OtmNxcb/DYMZhrTGTXn5mFEGcg
         MXCJ1R7FSITPMQBGb8uEOdIy4v7uAExEsiupk2fqPr8irgO/fACSp061Xr2umDiuSqgv
         P907h2dR9q3/T7fIBFjyhrNgx+ocegMq0cc1PSxDMe+L+CWQvIvjmach1BgxPmhg2Sd+
         yR6g==
X-Gm-Message-State: APjAAAWSgG46x2EbNjMkN8kNX9Lxnd0OZYfDY3iUXRYwa5MVSo+A1WVX
	xoWV1qUNpDVhb73JnIZmnDB0oEREzsUl+P83B+hkc7xG+vzZNRdMG7sVH9MRuo4WyYg+JhCyOtp
	iFW4QlBrP/pAXU35I/O4FLmbT0XExEr/jNKqHRC3XV/h1vhgY3X2auHfOdAn8uMk=
X-Received: by 2002:a63:8b44:: with SMTP id j65mr27776393pge.241.1561473507806;
        Tue, 25 Jun 2019 07:38:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEEYWL2mkRwD+dKjW3a31dK/ZihO5yx1/N6EUsDJ/gNymGh3IslPvFbswfJAWQwA6dl6Zs
X-Received: by 2002:a63:8b44:: with SMTP id j65mr27776336pge.241.1561473507136;
        Tue, 25 Jun 2019 07:38:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473507; cv=none;
        d=google.com; s=arc-20160816;
        b=OjIqaa1EvRwfhvpAZhMHHewU4kw9Do+GlV+yd4qFBzBAqabmbmZBWSX+9Vmrg7ZOsG
         CR9cIxVJjXqRl0yCJLrWj8ebfUUspiPHxhj9ABcG+SbtP77dUM1V0GAFBCtoT8sCK4vf
         FcGjQd41oad4U925ddQVib0T0LjymxBnBIsxkSMYw4u4kLEoX9mgomtxuzcy0lTqnTZ6
         cEKdIAiQAz3YiXMIA9/HGIs6bkUuAzL8Q1SSy3P2YNkGLzzQBeerhp5p+gLhFXISpxlM
         biN7Qx2sYNpdSqZiM5/m40BXEohIHADigybyAES5ix8fJC97qrPWhN6A8f6DBv6dF0b1
         3sSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=xf8xwUJqGTGhdY5pjBOHQgYHNWWmClOkIpScch6iAnk=;
        b=NHnqS+CRBWr5JLclRWj8S1Bi7h7EIysAU+kP2vzGDw9iVnaWCjm8vq13QkSEpR6NR9
         X9+uQB0I360qEMHpaerf5Jz/lKVKKWqL9nKHawPJX0KbuM74qmAJ2Qzxlbmv6Yz81GLR
         WqhEaSV1mPJZM1ivY+1+r5VJuBm/6mKpcE7PZZpQrebDaw8QGQ1nu1PIFQZ0/lhkChlN
         L/O/EjxEK1KWoHZ+XxvZ7zLPWNkpyawhnUMyGqMDxzV/D4yv9ewJPN7zCfY4k6Wgw9Ts
         4ot1sfMxdCZU3ugK5ubFZcDl8MLLpEe8t0G+DmK8gzhF3UdQAWV529q2u58NLApUBmba
         /qHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k2Z56jK2;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o4si483688plb.274.2019.06.25.07.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=k2Z56jK2;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xf8xwUJqGTGhdY5pjBOHQgYHNWWmClOkIpScch6iAnk=; b=k2Z56jK2d5xI+yMTjSN6h/vuiP
	u0SXzPC5Gaaj+zKYS9DBaui94DW5JdYiyeLGMMheoNYb7P1thRVfck4ZdTInGgIhRsvlkKuVafPuT
	qoEpZkZKHIQ/5Yo/qDaES8pLnbs8H4v49XR4BJswGTUAtFhXZ6YE/EB8y06wbIQVXnxShdZGCT/mg
	oO6SyoF/565YBqQO+A8hQbcrcVfzoWPdpW0JqHQjy9NjYjmi6vmVYpj0yblBNGtKd6ZM5x0og1UTB
	RPTRcqRD3JNKL9CoM58cLDWs9bCXv7Bra0aDAA5QpvIx11coqbSOkucnqEEJaTJsAzvMcQnEY09x9
	vYVBnHwg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmaI-0008BD-Qf; Tue, 25 Jun 2019 14:38:11 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 16/16] mm: mark the page referenced in gup_hugepte
Date: Tue, 25 Jun 2019 16:37:15 +0200
Message-Id: <20190625143715.1689-17-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

All other get_user_page_fast cases mark the page referenced, so do
this here as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/gup.c b/mm/gup.c
index e06447cff635..d9d022d835ca 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2020,6 +2020,7 @@ static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		return 0;
 	}
 
+	SetPageReferenced(head);
 	return 1;
 }
 
-- 
2.20.1

