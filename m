Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2871DC43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D459020896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 14:42:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lctxf60o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D459020896
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6313C6B0010; Tue, 11 Jun 2019 10:41:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 592E16B026B; Tue, 11 Jun 2019 10:41:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 430FB6B026D; Tue, 11 Jun 2019 10:41:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 024636B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:41:49 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id q2so7886532plr.19
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 07:41:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YLjfzK43wQ9CU00al+Ym+V5yBUHCJAJzq91hYzEVV+8=;
        b=r9DerkRziYTd44gypOSCG8aVYpqRTRTbWJDrvKsXDu6duvKcZWQovCJ0+mG40PVFic
         2tzOvBAJ0Yq5XFNRxeSGygwQ4eevWyBA8atqqsDU9BXOjIoM9B9XYH9eYwFDLs+BN5Uh
         adEx9XoP9HxUyTYS81JfPkakVpL+2wnpEcXA9J7yg3Is8FV0Xjbv61TYiRi31ilrL9Hd
         LP3RLhUAKB2Nd0S11SKr14YK2ZVjcj/VQef1lvsLa/c+FEpKrO3DuxUHlxpb4kkJK8sy
         vt5Lu0Jray1inz9n9raqdTsjKYbCjfuzJGbFLYSp/ooMeVeDYXXJSGXht45GuQGiKbMe
         dlYw==
X-Gm-Message-State: APjAAAWZa88zsyHCk3M59aPONDhYIaRxMk0lKf1S3YgNRwGCREmu56lV
	4FBfIzSzXC5iR1ibk32fCkOHOrUuy+8x97MxRAkZOS0B2sJqBTpFacdwOeIayDddLe2tj5SuEFn
	Xmcqnwcn+X6HeDCNGH0eam8W+pC5RDgVzJfZjccCDAwshA1LMkfJ5sAu8S/rt21A=
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr76740553pla.235.1560264108652;
        Tue, 11 Jun 2019 07:41:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4AgG7xBAVa8MSs6Ko15G4gx3sz5+J6zHT+EVoqHrjCtF0q+84xIK1wtFplXqBm+SdcmII
X-Received: by 2002:a17:902:4a:: with SMTP id 68mr76740465pla.235.1560264107654;
        Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560264107; cv=none;
        d=google.com; s=arc-20160816;
        b=xOSLAqnn0DVWvxXZQhCf2wkQPR9H0iWpsmLfbg3R9K/5Ifz1HnBtVCmW/Bk8y8Qesz
         ZXGmsItyDmnYH/24CLoMx/kqtalgCZn6EIhofpxZF+oGDfR45s/HIdIYMk9xu2Sw+JbD
         jWoYtmxmTujYOax/wGjQFNq15n/K9TkP+pUG/uG4+7yKEEF495TQTHWOct363ANSLXfs
         X8ScxDO6ll2cdSeEEuAe3vh0AdIs0SWKQgJ43yxkyQL33+AkvAl+j7Yut8d+zino5jAT
         Ml5k1SPNyD0q2+FkDKKERGHtohqqMeiMGLU+aa7P3lX5TPxrzviOqnmomEhk0i4WOAk1
         DT+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=YLjfzK43wQ9CU00al+Ym+V5yBUHCJAJzq91hYzEVV+8=;
        b=EJaxE79zMzy25oTNFhgy2ZHmJrIbJVZbexWncJ8Sp2fT6YLIYR5gzxXt0KiGSFoXyp
         hBPfKRLNuogR+SrFdH0/xgHgC3sTGCOMClJ3qIuN8EofgxynMKvptQVY1yuwLr4C4AaU
         c08Y+QdDm4SR9PbeAsHRlVpKRG/1y4DbXDagOAtzQqYXyAUt5noIj/NqHgXC+nvUCirJ
         1c6TxSgCNKAWCq8Rod0MUau/roxQxZU6EAStYwJPcRiyvlhNbukOQ1MrHz6WAVzVIzeb
         RbeaWjF1zM1MjZoYKVsW/rptzIv3MpbEIJiivlasaaxsNquaoMRO686iIHWA9/h0iwWV
         KPtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lctxf60o;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n9si12788926pff.14.2019.06.11.07.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 11 Jun 2019 07:41:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lctxf60o;
       spf=pass (google.com: best guess record for domain of batv+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+98d4ae9035936dc2f97b+5770+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=YLjfzK43wQ9CU00al+Ym+V5yBUHCJAJzq91hYzEVV+8=; b=lctxf60o+qeZ56iUVs4sFHqM9g
	Bhl9Dv3SAKW713Ypki/OIDIOKgshgcusVFDaJY04xE9PEL+nj6W+vPTcq7JYNGL6xmdw2OKqVHSZA
	wJ6OQJcmfOFC0wdk6AGsIWyjU3jowYGGcpltD1WM9o0bAv+v5iEFLlAgDzcA9g64YCZnPb3LMbiPy
	wfa1Qmx12MM5qG3ouc5kp6B6jJ7pltFZOfe7Y+qDODepS8DylwA9QQ6maqbjNTcnhamI0AxDdQ8Jo
	bTNehbXDNjVFbP2iwArNFZoxouMJxnrPETVIANVvrT3NyE4+eQyNI4FET7Z9TwvgVWAqjvhPnaJEp
	KTHj52cQ==;
Received: from mpp-cp1-natpool-1-037.ethz.ch ([82.130.71.37] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hahxr-0005RJ-A2; Tue, 11 Jun 2019 14:41:31 +0000
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
Subject: [PATCH 08/16] sparc64: define untagged_addr()
Date: Tue, 11 Jun 2019 16:40:54 +0200
Message-Id: <20190611144102.8848-9-hch@lst.de>
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

Add a helper to untag a user pointer.  This is needed for ADI support
in get_user_pages_fast.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/include/asm/pgtable_64.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index f0dcf991d27f..1904782dcd39 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -1076,6 +1076,28 @@ static inline int io_remap_pfn_range(struct vm_area_struct *vma,
 }
 #define io_remap_pfn_range io_remap_pfn_range 
 
+static inline unsigned long untagged_addr(unsigned long start)
+{
+	if (adi_capable()) {
+		long addr = start;
+
+		/* If userspace has passed a versioned address, kernel
+		 * will not find it in the VMAs since it does not store
+		 * the version tags in the list of VMAs. Storing version
+		 * tags in list of VMAs is impractical since they can be
+		 * changed any time from userspace without dropping into
+		 * kernel. Any address search in VMAs will be done with
+		 * non-versioned addresses. Ensure the ADI version bits
+		 * are dropped here by sign extending the last bit before
+		 * ADI bits. IOMMU does not implement version tags.
+		 */
+		return (addr << (long)adi_nbits()) >> (long)adi_nbits();
+	}
+
+	return start;
+}
+#define untagged_addr untagged_addr
+
 #include <asm/tlbflush.h>
 #include <asm-generic/pgtable.h>
 
-- 
2.20.1

