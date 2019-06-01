Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99D4AC28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53E4427144
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ZtJlig3V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53E4427144
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1B36B026B; Sat,  1 Jun 2019 03:50:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5781E6B026C; Sat,  1 Jun 2019 03:50:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 469B06B026D; Sat,  1 Jun 2019 03:50:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE5C6B026B
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:55 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d7so6205708pgc.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X2YVbgqGFpTprzpI9hgCNMZIAzqWGH+eXDnTmW0sVJU=;
        b=hhIUSPEzMU251VvWrPKWdY2TCKQSU4cXuJvJRFKcakqRasIlDgMNk9N9tDWqwVXzj7
         sP7c6IcMjhK9BnxC+lGuDpM5CKmzA47vVfcB5g4f9o2rYKltmr8yHHJDBobRnT79HzNM
         eZN7lH2uox+tkZzcNOgruZJUTEeTCNIRZIf1y6D1pkLYzFu8iVMqitxj4xREbaP2d4/J
         CJIu/SFiDujbQOG8iFfoEytLQF77uycDoq6+0woNAHSwRSPLj9fQ6/rxcQQWlmQe3R9N
         7fwY35/9ZfAfURuf6YEukZfXVKDvN6WRXYnrWtKAoslVjdizfN8Twk+JmQRtwshxdW/0
         jSow==
X-Gm-Message-State: APjAAAWgGNsh527k0CKbVDUD92PMKJSCcJbiAa1fH0FtqkFvfvt1vTOL
	7dD5t0g5gK8mEfYIpUBTVyOZBu5vrqBNTuElW0BDtrrRelz3G00k8cpuBwOQF7g6c8NFd68CqoD
	fZpyczFyLLyF2vqE0I9R2ZloHTqKaCDVLxUnWS2AFYqrQSkSSfxX4ZnYEL4upR/0=
X-Received: by 2002:aa7:9095:: with SMTP id i21mr12842671pfa.119.1559375454698;
        Sat, 01 Jun 2019 00:50:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaIDIfX7ie6BNYJs8SNgEpbeSqWSqyKZPTsVIiOL9S3iBopLlSIOmgUodJvXjFrBrI+Hik
X-Received: by 2002:aa7:9095:: with SMTP id i21mr12842639pfa.119.1559375453846;
        Sat, 01 Jun 2019 00:50:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375453; cv=none;
        d=google.com; s=arc-20160816;
        b=a8BLDGjrMaJidgHEmCZ/xFL+VoQd28eD/2696W1iqQnBgpNpWwtwz44Yif0OnPWPId
         MQP4p8quMKThJMtc8Oxtn97SKwxoxUEqIe3+cPskRH3LdXSHilJg5W7C2ECraQYi8XD8
         TtRih8M94YV8jynkv5GF/VIZVeIpS1xQIzjF2GggEvfhDD5ZfZbfFoqTntVOvnXezlwA
         xZkoIXQkhIX/CKN+CUowAqiRKjRB1NEHLzeESCrESGHLVK/pEi53X2DQ0b/s2/Zw626b
         Oxyrnood2A+OF8rBxC8YYAONKXNRPOQgKvLxzPyIoY3ik2U8lFbx+KSLbG7abo0R8w0d
         cdfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=X2YVbgqGFpTprzpI9hgCNMZIAzqWGH+eXDnTmW0sVJU=;
        b=oQ/DvVn67I4t2G91gftCCB1Y8/Vg+8TzFzOW+nyrQv2JpNlllelZJeyZeMVtAyGnCX
         RWUvZlfTp/a2Lqsrr2J7PfPU6pRlvSd1KPEiwPpNBp/8EJLgVoFcfvN7eDBYuKoGRmuZ
         TubqVIRq+l5vAhz+Sj2L3Kcc5CwJL00S1Sjrb0Gg+61JGXBba0Xx11dq1jAldZTKQNRL
         w3m6S8ONkMlj38X9JU6HH3fhHdpKJS1TlkikZKADc8e3OD6XJO/GaoXmgnKshl2Gx1wB
         Mqs/voEJ7NwYqBk/7S606ezJySkdrb0ekMq5QCM5Ih+k8/98Ww1GHmu/2/HWVDhL+8aw
         WepA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZtJlig3V;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n7si8698526plk.435.2019.06.01.00.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ZtJlig3V;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=X2YVbgqGFpTprzpI9hgCNMZIAzqWGH+eXDnTmW0sVJU=; b=ZtJlig3VMwLrE3XBd3epSBCFB2
	cZmqrWkQ/wKi02+ByfE4Vhsmik2Rj5BCC8ZLuKRSHBHIT5Q45EtH0aRHAtFwtRFtRhiDiZrjaAoA4
	8RTsfsQ60cd74rPAkeo/Cn3/XAtwgId2fdhBRwTqwEu6GknlPe5g8YfZ+z77k2gCLpl24hX1VjjIC
	TnCIKT4Hf0cJ2uH1YJfG8fO3GBgKwmBtHVuYNOIMAEhwh3WpgrHqC4Nk44qGMziz/MuA1JaU90A/3
	vFhqt1HRTaKMkCTuh8llBkmIaAlqI9ShNU0aucN01pOF2uvfFOHa+lDOaDgEu+Dn2ZOkDTe/8hAIA
	6Vk5ptvQ==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymj-0007nL-UH; Sat, 01 Jun 2019 07:50:38 +0000
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
Subject: [PATCH 09/16] sparc64: define untagged_addr()
Date: Sat,  1 Jun 2019 09:49:52 +0200
Message-Id: <20190601074959.14036-10-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
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
index dcf970e82262..a93eca29e85a 100644
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

