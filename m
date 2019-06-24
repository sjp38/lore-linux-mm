Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC5F0C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA9E22133F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:43:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="bOJanL5M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA9E22133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31DD56B0010; Mon, 24 Jun 2019 01:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CE2F8E0002; Mon, 24 Jun 2019 01:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 149438E0001; Mon, 24 Jun 2019 01:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D349E6B0010
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:43:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id o6so6694613plk.23
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5S44G7hi9/oDzUjI/c4UDpw03IJ9UksvFQEQlTe28Is=;
        b=Xk+rgskVt1ulw03KNrr3LKMfDtl7xmESC2MA0+aluDJlJ3x/1Fb70IfU+1f/hSIanI
         7JToVRf73GqxjT2l9qPRkKc9b28HaM064ujqSG9GNPPWLacsA65WfIhM2gkuuNFZSW3i
         hSfhHdpuq4U6RaqHY6sqDmFDPOwF47rKAEcadEcI38nt66QCHHvQWvWUULsiL0atiJeq
         h688T1EAFRGBYtA+ulorzA+dWuLPEav+Vj33DWWyWp9dqg9f47ykdfILbuT8hy791EwH
         T1JCAAaoKqwAvDruji5gNSTkRFf8ucgCRVrrsP8RV9zlHOZFEFtEtR+O5Fnaw6CGTLlh
         CMIQ==
X-Gm-Message-State: APjAAAUroAA5+6tnkaJnIvU5S3wmEJmrgpnfYjtGG9AnXBDBPSBajRrL
	MrcNTLjVfaKrtUiASzfs3aqAuZzgDe0jxAKgWXupv2h6bh2pwaX69bdnlu5ewBZOUbMbmjnKL6Y
	1ocfkFOr8nL1Zd2v0zW5xX538K6wnuvAWdcJ3sLfhD5CC3Hkfdmb9i+CI9UlPXvM=
X-Received: by 2002:a17:902:2983:: with SMTP id h3mr102611899plb.45.1561355025553;
        Sun, 23 Jun 2019 22:43:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMujMgF7ixBBjEDnveoRey6DVPpX7Vb9L0sTtvwQHWruZp8u1G0ecL5zXVcPHpOx/vy/ot
X-Received: by 2002:a17:902:2983:: with SMTP id h3mr102611856plb.45.1561355024896;
        Sun, 23 Jun 2019 22:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355024; cv=none;
        d=google.com; s=arc-20160816;
        b=pRRTe8h+FHPBrozCx3LcqSH7Gd6PVaAW0EyfFSqi3/4DZaClvW6j+5tVPLGVNxTj9X
         xcWgDGqf/kiUD3hLH6htUO1NY9FeDs94H5hbwNtlZXUGysM2zCeEBtL3aKZykgElnsTe
         0MgUPJBvS346d6MpGJathA+TWjRmpvlSC8CtbgyR+UXa85OwR+jHrvMMbYccClr20dwV
         O0e+LX2sj+nTcu7YS1HteMi9QUtfrTdDt2PtZovxwCMtUK9zt83V2GaIixfmRC9adkEq
         o77BBwqaym+Awvix+gDk16RHHusYQUngzSfAKnUsE40gn099HvU5VYxAuiWuGyQdZ3It
         oE9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=5S44G7hi9/oDzUjI/c4UDpw03IJ9UksvFQEQlTe28Is=;
        b=nZacdINX93Jq6ZoWwSeinidyAOaBriiRh2nR6kH3HjbXcxTf8TjXm4j90iAq3wqgEz
         rfFVorLZWk80uPPIS4jICHomJuLn5SUXYI8wYjzySvO0rUUwsSg3AyIt87uWKR4P3MUs
         S5cSQboqzBdzXvkQNCHpb0xJt6AeHtd89BtY0hQFDx5DiFOnjg3qwE+aqkZOuV7C6xLx
         JVNBld2GLZbJSCjnONhoV3ZxZMbr07h5LFigDh7v5Jf1gcj57V7Swt2R6LT256TT42OC
         GOFicmRpnje9X9jLhl8pUerc5C91McMwHGVPigiQioUaUOmEFma2fOL09m1Edm86uP0G
         Z9iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bOJanL5M;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x8si9238760pln.298.2019.06.23.22.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 23 Jun 2019 22:43:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=bOJanL5M;
       spf=pass (google.com: best guess record for domain of batv+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+84882ec255bc51113d1a+5783+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=5S44G7hi9/oDzUjI/c4UDpw03IJ9UksvFQEQlTe28Is=; b=bOJanL5MMnc/t7xSRwNl23fs0K
	aeNomPXq+bdVmfGjm7QRaFm9ieHxtd8szKCB8LzF3VBt+56T9bWIcSx3l2sZ3yrFCt8hsBXSUggZ+
	+1vAATxtqrhDYJxKiEsAQfkE+e61DJiYbUXXQTpvfNkDBQWEsG+N6s77wOacZ+peImRSnwjUjAtDn
	OCXkGgA4IVqSHPmT7He01n2msBaxwwg7D79sLkzAgVdMIqYmqCXIl9UKMggE7wL7HO5tpiBlBM7hq
	Ogdeuv7YAqIa7B4iM21XQMBymT3miTYC6nVRevqkNpks/Yd7ZnY34qKnata1FuJIiiypv/Q4OyDxk
	pfsmhyLg==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfHlW-0006Ra-NN; Mon, 24 Jun 2019 05:43:43 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>,
	Paul Walmsley <paul.walmsley@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/17] riscv: improve the default power off implementation
Date: Mon, 24 Jun 2019 07:43:02 +0200
Message-Id: <20190624054311.30256-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190624054311.30256-1-hch@lst.de>
References: <20190624054311.30256-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only call the SBI code if we are not running in M mode, and if we didn't
do the SBI call, or it didn't succeed call wfi in a loop to at least
save some power.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/reset.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/riscv/kernel/reset.c b/arch/riscv/kernel/reset.c
index d0fe623bfb8f..2f5ca379747e 100644
--- a/arch/riscv/kernel/reset.c
+++ b/arch/riscv/kernel/reset.c
@@ -8,8 +8,11 @@
 
 static void default_power_off(void)
 {
+#ifndef CONFIG_M_MODE
 	sbi_shutdown();
-	while (1);
+#endif
+	while (1)
+		wait_for_interrupt();
 }
 
 void (*pm_power_off)(void) = default_power_off;
-- 
2.20.1

