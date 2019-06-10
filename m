Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21434C468C2
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D90D820833
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fz34Jtvm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D90D820833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7246A6B0007; Mon, 10 Jun 2019 00:41:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65C1A6B000A; Mon, 10 Jun 2019 00:41:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D6CA6B000C; Mon, 10 Jun 2019 00:41:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 083D06B0007
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:41:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l184so6100651pgd.18
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:41:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=hJ710Nece9JdDCt+W2M5u9CutQXF450XDxzyXKmRa0k=;
        b=lpaGLZ1NtnZHq+DRjGNUaaPjOTl6PRd3fVdNuIgCAMfloc2eRCioeDunVmb8t/L/Hb
         OlYyzPRzPbjkSlrHS8KJaAUQRBc/OBwJNmR++oXQ0uaEqOd0ibfVAUhcZKVB5828c2mi
         FKTL9nV8xf0LGUqVcTgagv8F4xE83TE8q3M6i8P0JQmRtu4EucGe8y+OfWTIMPJKCj/U
         oeu5U+1yRJffx0s1IrFaPO9Egfi+9XeJ9qhxZZhB1Qy60BZUM71ltM2rVoQcyT+Igzdx
         cEbyaqudSN+tkMBCR8Hp8Jz3dg6oKJ+y6USu6v1GK0ZeI87HkiP4hPTn/vEC7ckMEkHH
         N86w==
X-Gm-Message-State: APjAAAUGs8BStW2J+8nkDZ33GWuHw/1cBOka7l24cJUj511ie2tw9CU8
	Jm9hGDcfz4IehPePM74kOCGdRrUh3mYWfB8SP2Zkjo3TY5ri/ep23/INl1GgcKG5U+4DDEKZBaG
	TnoaMIKKzbLl0fZGB1rVN7pNR4vKg9k5VeLmmu2T/jjdSkpvE4M2lDhOENPDPIUEuig==
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr19782762pjp.118.1560141665607;
        Sun, 09 Jun 2019 21:41:05 -0700 (PDT)
X-Received: by 2002:a17:90a:a397:: with SMTP id x23mr19782727pjp.118.1560141664960;
        Sun, 09 Jun 2019 21:41:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141664; cv=none;
        d=google.com; s=arc-20160816;
        b=n6DcQ9QDvtm+QXZFHWzq21NPHhAJZQhLwf7dZnj9BTyj98Kw6qAnRdesoWK4Q5wFYi
         wpbybquJjU/ToDtKQazEsbjDs1otNi3ZRaUwOvEHb1OiJ+Ln98HKOMNj252ycLtQHLfU
         sv2BCIay/oBoh1A4OwuQ8tfC9uIvvcuHBGJjynHCfoI56nX4ewlWFK0p4XI+eXE+cfBh
         sISk3ILhGihuKY5qyN2bSKWW5Lejag+IVWA4iBat4v0sOertiJl78nw/wefldEkuH3m9
         m4Em1WOO01Z8+xDbo9hgN8XiTFUR8+8oiQH1f1Zvn3yyuLRvUtIvQdT24mA1KRN/WS9u
         iWfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=hJ710Nece9JdDCt+W2M5u9CutQXF450XDxzyXKmRa0k=;
        b=xAluApz6epsWDr/JMnt7rt5eURZMw4Nk5gxJJzxSvbuPhaKYrOM8jo2pC/gBP68IMQ
         H+HnqOKOzVCUbxUjmcwQpbmqvEw6Dwi59Fmr9Y6EoNxrRUC4FmvuL97OqnwUI2IgUR0g
         jXt9C0AE7hJgUUqDcGpeHnbiqT1o+WXqvKc5tH1f/Q8zotlSvZl7rFAkxRQhtO9gsoca
         lSWAqyEeEt+ujC2iLn5cMeiq2YGeeoUkvfIG9sWQF//U0r5jN2lF8igCF6VEnEkk9ktZ
         L+mHuVlacQ2t7EcbS6HycijYyf5oISqGg3ae7hqzwD1k0dnw1ZrNdRNPFNB0hcePYzG1
         myYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fz34Jtvm;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n9sor8061444pgl.15.2019.06.09.21.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 21:41:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fz34Jtvm;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=hJ710Nece9JdDCt+W2M5u9CutQXF450XDxzyXKmRa0k=;
        b=fz34JtvmsEEbz+uG7YHcmaePdpnvHSrr9OzG0Fob2Vn/ojNW3ILIH/7028H5WbNhf/
         ozwk2iOir1e6dQLEkGP6el5dRxrVSReFLnAqVr050NDHhkui/0LVdt5/hWGRB0Quv5ry
         MwcfC53bLQB5nw6tMMWHl5S2ClvoJ/dI4A6eJN0A4OvoGJ2OS3XhKIou0oDGf9rzwRs5
         jtggh0AqFgaHwYeCfg9cR6kagIuVfcpp+sfjWTqBHuVGTir0il8bOgANLRz3fwgf5tKL
         fn6NFsZYGYRUj/uudTy5p/8SjGhYPJ1jpLuoGku/u7LnyvT35k2ZkTlrj6CU6TrUNbP0
         qpNA==
X-Google-Smtp-Source: APXvYqz9ZBs8sn3RctkWOS+ZWyR8ZuOTeqNvx84zu+AkZf7kx8BtX4P+3MbV3oNpSvArhcN856sjFA==
X-Received: by 2002:a65:4544:: with SMTP id x4mr14322154pgr.323.1560141664470;
        Sun, 09 Jun 2019 21:41:04 -0700 (PDT)
Received: from bobo.local0.net (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id l1sm9166802pgj.67.2019.06.09.21.41.02
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 21:41:04 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH 2/4] arm64: support huge vmap vmalloc
Date: Mon, 10 Jun 2019 14:38:36 +1000
Message-Id: <20190610043838.27916-2-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610043838.27916-1-npiggin@gmail.com>
References: <20190610043838.27916-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Applying huge vmap to vmalloc requires vmalloc_to_page to walk huge
pages. Define pud_large and pmd_large to support this.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 2c41b04708fe..30fe7b344bf7 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -438,6 +439,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
 				 PUD_TYPE_TABLE)
 #endif
+#define pud_large(pud)		pud_sect(pud)
 
 extern pgd_t init_pg_dir[PTRS_PER_PGD];
 extern pgd_t init_pg_end[];
-- 
2.20.1

