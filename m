Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0210FC46460
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A321226E92
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:50:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QqGdORxj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A321226E92
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 071526B0006; Sat,  1 Jun 2019 03:50:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02EB36B000A; Sat,  1 Jun 2019 03:50:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5DA16B0008; Sat,  1 Jun 2019 03:50:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABDE66B0006
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:50:50 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y1so7854722plr.13
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=nAchHLAOVHdFoPNNnyopipE14yM9+t7QnHg4qct0fhU=;
        b=gLrm8ozo90BGs+i6UvO+dyMaQhQskCfbWz+n8/+ljoF56YOtsIQz0vgu6fjnCYRWUm
         LlGs/fHP0qpRMmhIF8BQMrcdzU1h79vUfSEX54DDNKuPVJ2Jr5G8qufXI47fD1AAM1W1
         d0efOvz2eeaTW/C5I/WWntXT2hNgYvoVj8L05SVzY1Em9jrtUWuiKzvfbToblhuoenOE
         NgAEJ3szKTKtn4r47P+0Yv8nC2tTR5R59on+Ub7HGdYJWyqHreXt43aU9Jm4jwmiF1aB
         OeNvdI7YtumJrKo+qZOprvNNXiMBCql7s8A6C7MXGvlQW3gcSRV6BwvZJDmvKEt2ArdC
         VELA==
X-Gm-Message-State: APjAAAW4rOCLwW3Pzkv7opyE12d0eHkeCNTxYKtUeNYYh1vIj9vDUWC5
	AfIqNgHJsm/8SlpAb9Zj1RVjpLGdmLSX1jHm9p874JxgosrYP6jpzPm1YsXUN+iA7E9hXnpGERW
	+B2D67iOZUEEuMMkiyFxsCnUtwQFbUf/PKnRq4eh5V7HqmbaVX12nd1jWQI7H3oQ=
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr14803676pff.238.1559375450369;
        Sat, 01 Jun 2019 00:50:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBBi2LT0Qd1Myak2jF38EW3rth9KEbx5bw1RXDEIU8MO6IO7l+hl4S9Yl6YE7ZSX+1v2gc
X-Received: by 2002:aa7:93ba:: with SMTP id x26mr14803633pff.238.1559375449536;
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375449; cv=none;
        d=google.com; s=arc-20160816;
        b=h4zTjpQFXQB9/FVpULD3F2Fftto0LKQVnjzLeocMc8/RFuUwWjychlzslbsnE79QP5
         oSSgtYyN2EENOv3GMKw1FkGyNCG3hiNYPd3fIXn+PfW8HRidAcBF9P3r0B5MzX/4oCi2
         aFCYs59mBWlRBOqqipywrvxN3+2urlp+x35/jgEWcrbV+W2FnXKjdwZfBmQbPUM4Mzt2
         W9Dk90t92BZhQ5BGGgEciX4gC5BSFARRDrbrU/8qXqi5wqMdjGmCijQzVsL7rlxP0kII
         HrDtLIpw2dmey1qYofES+9VSsy3yDl1s+Zq5Wk62bOHvK/b1LD61+nfkiARGrR0OUjCw
         ioSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=nAchHLAOVHdFoPNNnyopipE14yM9+t7QnHg4qct0fhU=;
        b=oBM5HDq6fquunRQqjofZfnNDMx2Xj+w+QPfAOMzkLc3yfuhKcMZ7w4cvWA0SBXmRiN
         eNnOHF15UwN93KY+ISCdoyF/jX38Hbb1KKzITxpjcLxKBmjKDyCpgkvL5VZOl4TkLg42
         /eXtcPowxSAondPB0fpAL/AVpburOBIGPcAiRvs1vWaAemAP+dVLgg5IBoaLYSox0IuY
         VUpuuvfV3/Fr0L82tNSqsb0dNXgOiRFFFQMiL2f1YQCOiRb8Ps83hbLHaY20thdJEFOk
         UoXlHDpT6PIWAbzbTuVGwX5LmB2TYtoFaqd2QtAlY8akMo8+YK8slsq2b3u2hDHubW8R
         v6XQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QqGdORxj;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b8si9414521ple.370.2019.06.01.00.50.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:50:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QqGdORxj;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=nAchHLAOVHdFoPNNnyopipE14yM9+t7QnHg4qct0fhU=; b=QqGdORxj6XlyglD2qdBUbBeIC
	Hy9buW+DsGPqJvsy3MedAvC0mtPN4yHL26eoAFhkNqNsXptjXmU5b9kH7NGdosN/HhHbcY1Un3x7Y
	Zi2U2o4Svrck8PnJXs3W2TxGi/SZ6nmSJSaNBkN2hHjRGPitl4T5txr4URQ5p6rEFlj0iDLukMJHe
	ulVUfwf/ovXUOTsjn7hQ6WoovhDPSy3WgHlCw3R27BWoDOACfrUKCWaewFjdzd043EoSTTT2+7hhY
	0scSt6R73eF616n6eG7oIaSrfUKql5GXpxFJdfERUiw+gXjckSCuSy9wVbhVqUtaEDY49jEeylkMu
	5Nq5UuaoA==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWymA-0006ZV-Pz; Sat, 01 Jun 2019 07:50:03 +0000
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
Subject: RFC: switch the remaining architectures to use generic GUP v2
Date: Sat,  1 Jun 2019 09:49:43 +0200
Message-Id: <20190601074959.14036-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus and maintainers,

below is a series to switch mips, sh and sparc64 to use the generic
GUP code so that we only have one codebase to touch for further
improvements to this code.  I don't have hardware for any of these
architectures, and generally no clue about their page table
management, so handle with care.

Changes since v1:
 - fix various issues found by the build bot
 - cherry pick and use the untagged_addr helper form Andrey
 - add various refactoring patches to share more code over architectures
 - move the powerpc hugepd code to mm/gup.c and sync it with the generic
   hup semantics

