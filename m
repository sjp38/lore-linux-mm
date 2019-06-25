Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D9C1C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5D15215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E9+L7K4k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5D15215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 288508E000A; Tue, 25 Jun 2019 10:38:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C1008E0009; Tue, 25 Jun 2019 10:38:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03C328E000A; Tue, 25 Jun 2019 10:37:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9A6A8E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:37:59 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so11783025pga.4
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:37:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Uev9P+r50vVpCL7nS/dekiTRo7rXCigRkpG+pJrAUCA=;
        b=edAQLwnUKstZO1SOOg0pPLakg1mxOICzDJ3Uh7AmV4zdFRK9Q/yli7wGYkJoK34fdY
         NHDMdrIILTsmnsa1X/H7hVPMNHgfn9L8GxcwdS0dedI4l0Lq4i4PBOPGLOEddrGFCuqy
         VQ75qOFFaQb9+n3ZaTiua5mhdx0rNr77N0P7UnK1HzjY0x6ql5wbpnhGMa9MgBphpKne
         QW4W3O/qcOBi4vAa6UKGsz0b4TKnVFAY906ru306K4jbqQ9v7f40205NmPj8U5be6170
         fz7OpLKRreXO64cBdcqW1lDQIcvutL2jEjs+49qvsFm7ko9WSCXGoVgL3KMbhIYdVI/7
         CY4A==
X-Gm-Message-State: APjAAAWAkAB3lpo1bRtTVtwT11J6F7Xo986+mTJcd/DG5nnxpfSrA5e3
	OiwPyJdxdRX7Px6fsjv+vE7R9cVfELe/XGnt7DH312hP/G/J/Cvbolvtr34cX7uf/tEQOQk79zo
	62FY+wcU6HA5/1mhp+g/OxYdIKUyKOl11ATTIc2X6JBbE2CNgyz6GjyXdWce8OLM=
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr32371781pjn.119.1561473479440;
        Tue, 25 Jun 2019 07:37:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbQKTBn1lXgHvkFnjgwiLHqGABWR3XLIKs3YXO6ZuyBR+f/ZxiVJZgyamOBY3+6AGsoOg6
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr32371717pjn.119.1561473478711;
        Tue, 25 Jun 2019 07:37:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473478; cv=none;
        d=google.com; s=arc-20160816;
        b=I55PH4tJ6wGMPIJWzxnTw3r5mYaTjLTZ84N2Z8v+9vSpO53hdaJMz7+vBXC5zgBPmv
         3e/1JglH0H/v3PuR0HzKsZoGHJ3BvpVzxDqFNiiEge4K8caprCfvXOLkPnk1tu15TViE
         EvgNgNLlbZ8ZSaqr672ei9foiMG/7gxxBHVTSYTNvpQEjY+TeNSb6xJTKdWTSIRKrkOU
         79doC/FJgCKZQ+keA1GtGQLmPAqVUlfdpKoLEMSod08UDfzRnrFeZxjVYfo/o1u2QNVk
         /WIcFUbOrk3B8uRjJgUcjXJaWFHubJXYfebl79vfErdjM4TppvSDcZ/PanvwwWYXJTpV
         DvAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Uev9P+r50vVpCL7nS/dekiTRo7rXCigRkpG+pJrAUCA=;
        b=oitAY4BcVZ3kFgN6e9zRn231nxgnha5xAGS+p7653K7MLFikn+w4Ye04EemEuVy6gC
         DJOad+FYTSowl3MtL/U3riHiqL9yRSPvKg7AcbnnKdgsdJZY9tScAaSCSUplBs4IWID4
         IGMWwnfnVTit6jmbGUGIFZFizIWrNh2S065iDKBCaSwYx+svW9AVstqB/YsBKUjTCsr1
         T4jbu1tlvBtNBhS30iOInK6ULvgiQzFnmV/IxSX2+yFUVMbHfYwekCIoHvJiPklO20YL
         fgg5pBTo1846+NdMAriitdlAIMzXc91QO/anHtKsC5H3Reg1HpaSDCmQzVk56RXlPR9C
         WeDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E9+L7K4k;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l64si2922088pjb.93.2019.06.25.07.37.58
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:37:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E9+L7K4k;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Uev9P+r50vVpCL7nS/dekiTRo7rXCigRkpG+pJrAUCA=; b=E9+L7K4kE6JTbh7vmfjLu++Bdq
	JFW5Va2G2EXQmw9Ke1E0G6TXfr3GramuNSqnofY+5ruiQC7YMVyKckCqdLDCAejhVvPjjrzmC3s0K
	5jHAOt+PTN56hNY/emDzcT8mibDyCDoxaAOkaMPNE1QZ+kHmuyCglsjWWDNoZG889qMzTCVo7xhQC
	zZPu+39bRGe7M4f49CxIPbGV6KNIgucjuElJ9zwUyvgo2x9WKT9ZGfcD3RhFXEL9DhOFYfLgYbf3h
	mDT0YYG8DgGySjHXpThwmT0xYCmOYqlSMO4BtE80cVWg8pT6o1QKaSG6Q9B6vUTdYj3GyxqYcvc6i
	IGm4eLNQ==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZr-00080F-Ip; Tue, 25 Jun 2019 14:37:44 +0000
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
Subject: [PATCH 08/16] sparc64: define untagged_addr()
Date: Tue, 25 Jun 2019 16:37:07 +0200
Message-Id: <20190625143715.1689-9-hch@lst.de>
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

Add a helper to untag a user pointer.  This is needed for ADI support
in get_user_pages_fast.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
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

