Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A98D5C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70A0920896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RvMLHQLM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70A0920896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBEA86B026E; Tue, 11 Jun 2019 10:42:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E43286B026F; Tue, 11 Jun 2019 10:42:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBFD86B0270; Tue, 11 Jun 2019 10:42:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9F36B026E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:42:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f1so9758621pfb.0
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:42:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=19P6HKT8gx+qvtagjEoAfgixjiXJTHCy2J5lWoKb+RI=;
        b=BVNKj9Scj8tiF43XC0ZmISsOCBl85UCsgP3eOtrLIPJL/gMoKtSKXYjFzVPJDe0MSf
         DV8V3JIib2N2V1qQ+KaL7W9xFtsCm6SKLiRERFjD9dstZCN2Mi681ZbdX2Bu+CyHqdb9
         tpXOBp1389LMWIYT0Yvbk3gsHU5RNOVPf2GcX/OLxApVQAvVcDsa4FY/gG14zXdhRHDU
         eDg3A0f87c+NrSI56W4nYxyAM0w7teyLVfFmOL4sU+dBUIZ4WSRe5V7ByckNhF+RbhpT
         6d2IIi7QWAoi0zcZpVBW/rRFAmK6wxmcXa6vvCuHX9w/K1L4cs5jKM2Yd3OSMy4RNEcf
         XAMw==
X-Gm-Message-State: APjAAAWvDyvTRwp61ryCP4Urqx5KYYmCwkng/bM3C3rzrCR4HuLv/48s
	ufzEN25TttY/YMSAd9AEG4LYzfV/PxZw0aMFcoLkji3GfU03WKf1EUtx5FLxEfFf0y6WgOv+ITr
	SYxyzRwreMVoR8B05rT+SyccmC8fSe0Fdjmyt9W6YGPeL2tURGNKY79ffW2SHfdM=
X-Received: by 2002:a63:1c16:: with SMTP id c22mr21659786pgc.333.1560264121055;
        Tue, 11 Jun 2019 07:42:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztbKK58aSi1OJMRwW15u10sLuz3NLqMbBf6SW9RnIJnbdd4pwKVRrG0tm3tVy/kC6YU/kB
X-Received: by 2002:a63:1c16:: with SMTP id c22mr21659742pgc.333.1560264120370;
        Tue, 11 Jun 2019 07:42:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264120; cv=none;
        d=google.com; s=arc-20160816;
        b=z3H87B1i+Ty1FrS909PU4r55OAk3Jp/dJFrGpZrhn/ym3xVisnu/94ywedPcwpYmF9
         hGm1c+/QY6OYK/QTm5uL4EhlaPs7yxUFIxjJxX9csQ9HzInU8kJ3paYno0d4fWXCS5pt
         5IFk4nImj+A3poXmWrtYeomFSf/vhmYFvXqS5BVWTG4VLyOjFZdrvylaaWdw6xV68x0z
         8GXeGGMFv7IyMLAadyWGAhC9s1HJ86IqhZGgGopDsiH2Tw9NFD6vSbB6GMUWIFCftjYT
         fsQ1ev92cXV82jDwtVPqZn81zmHOli+6fabj5bPasM1maIyC1HUnSDT+xD1AtvhYQIzC
         Srbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=19P6HKT8gx+qvtagjEoAfgixjiXJTHCy2J5lWoKb+RI=;
        b=CoqViVhMHKy2V60EkdPfZiLrLkt2nY88j6Tvmrh1/9SAWfdR54f83zspUPmsU7ay5j
         /UKz6f36yqqNLsMdeTyBZ41Pd/x1Mbt2/dyaD/GMX70j8LH6ENcrXkdjOM1SM1ILLJ/L
         goM/aKDy4ozlUKbn1VWN7WNysEt79QiR970JhN8YNA1XZN9s9PF7iNqeley9k4n4maLJ
         el6/fkMEvOXvwQDXKhSvI/kSNIUNVgSZq2py2kZ40+W2CSBgCbsKznKUCDm83vPmdacb
         LLaMSCrQm6G2Fs3UPoi31C2qwInTiONDT4Z4aW2/urWVsbFiWF7FE0PLawHfBKUQZfYA
         kt0A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RvMLHQLM;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d31si5437395pla.84.2019.06.11.07.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:42:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=RvMLHQLM;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=19P6HKT8gx+qvtagjEoAfgixjiXJTHCy2J5lWoKb+RI=; b=RvMLHQLM0EqS4QeoOT3XL4S8Cn
	bxrsz4T2AKHyg/Jnz9ysLo0v7PvYXCdSxmLvfSIpHzfHqH9NklV5iCu1CJz+7sk5NP0HxWHhNDbVS
	APpwXXhK22mKDDmkVGTsQl6GmckrjXQaHs33F/LL3JxSB4TnsvLYz7ZZIfzWiwRU6CjT/SINtqap4
	868A4nTBLbFV2gFiY5ook73YDF/6b+QARegN2/rb9yAqWpqUDNB0D9CjTXtsogPm0omdTGL9Ajdmp
	roiPNf+qsDk//cZFte1jfmP7N7hAUk6jNYUyMBU3Oxq/RYBPF/lvSKYiKGZQIUGuymNMKWpU8qPg8
	8Ld3TJGg==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahy2-0005YC-6o; Tue, 11 Jun 2019 14:41:42 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
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
Subject: [PATCH 12/16] mm: validate get_user_pages_fast flags
Date: Tue, 11 Jun 2019 16:40:58 +0200
Message-Id: <20190611144102.8848-13-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190611144102.8848-1-hch@lst.de>
References: <20190611144102.8848-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We can only deal with FOLL_WRITE and/or FOLL_LONGTERM in
get_user_pages_fast, so reject all other flags.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/gup.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/gup.c b/mm/gup.c
index fe4f205651fd..78dc1871b3d4 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -2317,6 +2317,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 	unsigned long addr, len, end;
 	int nr = 0, ret = 0;
 
+	if (WARN_ON_ONCE(gup_flags & ~(FOLL_WRITE | FOLL_LONGTERM)))
+		return -EINVAL;
+
 	start = untagged_addr(start) & PAGE_MASK;
 	addr = start;
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
-- 
2.20.1

