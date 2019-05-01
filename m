Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 822A4C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27C212089E
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 16:07:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lhopa3nn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27C212089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9116C6B0003; Wed,  1 May 2019 12:07:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89B086B0005; Wed,  1 May 2019 12:07:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 762C66B0006; Wed,  1 May 2019 12:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA2D6B0003
	for <linux-mm@kvack.org>; Wed,  1 May 2019 12:07:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z12so11156840pgs.4
        for <linux-mm@kvack.org>; Wed, 01 May 2019 09:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=BmsOCWOL+giQZS37PMaeMlSUUcjDPMjoPtCe2tkT52w=;
        b=Zqt/2eyR82mqVagnC5N7f1Rm8SUhe42ijRx9fpJL55eNQVkeiDrRbj/SLG4ou0U8ff
         1xlLINuXkzjj0V8dXLZQPPSxgUObuiLLMYNpz5VOLAU6hB6WWtNz8VVVxi1o+n17lPf6
         fROytcJwXnD02fusp5T3RuKz3E/ddqLZJdiaDSDyyvgbyRJZxOEiOxhkACt81j5tCyzm
         vwg87E1mO+1/RLN2KA5YUn9CxSz88cloyqODwkyETjHdSdbWkxKufQPArpKeVWWHYaWu
         iNQM704M1Uyo+n9xOeYz6n3tIsmu4AE9Hsm41HOWGJ9YLBBOGQCJyW7VM6C0I8su2iN4
         B+kQ==
X-Gm-Message-State: APjAAAX3h1dizzO20SG72U6fRl4zpK0e8xcbJ0WVTNwbnSJIKHOxbB5m
	Sui/TevtIuMgm39QtlmrkXcrv1ft2DY0yQpA6pRDZg7Z0n3S7+i+zB8DYjP/7+6pkUB/o/+Z/MK
	+Iz+PpyLkyTmo/5M9ovzUmrZBnAqCWwEWQmTtGKAUGzri4+7No+VMg9gCGEOQ0VY=
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr80009361pld.25.1556726839904;
        Wed, 01 May 2019 09:07:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqws5efjH6lMEnf/c0vRgTmEc7tt+RVWg/rY/C+qbE/PuriPCmEwkpPIv8bNSDl5X5aAkZGL
X-Received: by 2002:a17:902:4101:: with SMTP id e1mr80009255pld.25.1556726838857;
        Wed, 01 May 2019 09:07:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556726838; cv=none;
        d=google.com; s=arc-20160816;
        b=UHmEdbk9/8Pw0zRcLTNAsCJ9d6yMhCn7grmmNLIudV2EAP40YcoEhYWEPJRLC2DYuP
         hkCM/QAiWKNrP+fnogTKYeJtj6z/8rE5od+uhJiKPtavI9eyUzaUvMSi1YSnAxkcoua6
         7WyqT39OkyGG0VMftkDFtOrbPBwWTGTYTdWjb96I81hnwO1I/EupOOKocQqcGOyICvJ9
         m2V8itqusb+lCG0oV8XMSTKHYdaMzeXVAsUjQAxMoJbO5pArUjR3c2tCmse2VZVxPBx0
         czpsEbT+mxxMSnTSzKyRKzHlIUFw9nLanvXckxPpJdYh3lgYxqRpZJxHFN7tDzlqBg0B
         gQpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=BmsOCWOL+giQZS37PMaeMlSUUcjDPMjoPtCe2tkT52w=;
        b=WQ4lmzPShnDLxIGREOYN43hGuAyzXvA5h2iLX6xZRvrNLggw2WVv8+fClIxHs3oepS
         NmamizmCPugPjxl2zCdg1SR1cCHGZh/2H/5UvyHNjL3ejMQOdDGq2TEexQiDmDnjAwiy
         DdXnVgOWhx9aUGRelGbeI6RkzkVZKr1LjRFVEhia1Jhim3poiTpBG4Xns3JWY07+jo2W
         UNs0aSoQXlf+KZU0hT2Twcshymzx+Z2s0VKr4svC+gUwSTI1O+9ozOAIckxT9CUEP79G
         mND2r2rSAFVCMgzTUdalftLOE3ynXxROMQPnxXsftrdem4oWs7Ry/V+OeQdcN8JZpBBu
         XgHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lhopa3nn;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a11si12969835pgq.180.2019.05.01.09.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 09:07:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=lhopa3nn;
       spf=pass (google.com: best guess record for domain of batv+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+fbe6eae7536a933b5243+5729+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BmsOCWOL+giQZS37PMaeMlSUUcjDPMjoPtCe2tkT52w=; b=lhopa3nnuzOqrafzg9Kkz+1vj
	zRcrs1JNVduVklckswJUOJDeGXueBDJQqfe1bSXKFFYz+EsgYkSK7QTDiq3dyTN5Zu8rRkrb/ofe5
	iy9J+NYQ3/g3/e7Zat5sBySIWPF6fPyuj2jZ6mPvZrOwkVDcX0us/ysxTVD3wQzLoAtP/7/+Ys2/w
	pPThqLdy0UCS/EfbjlATohXf8BTo98B+eFvbYkSIsp0MfV8tc20cD0hvWpavUXG2l7N44tjLh3AQv
	JF2JvKvOFoXfDZCheLkQDFGqx0qyb9unfIa7+drB+xOUy2K53E4eWNNsYhLcV5F7gFtvRxhMTTIhR
	NT/oC7BdA==;
Received: from adsl-173-228-226-134.prtc.net ([173.228.226.134] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLrlJ-0008Km-QG; Wed, 01 May 2019 16:07:14 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: fix filler_t callback type mismatches
Date: Wed,  1 May 2019 12:06:32 -0400
Message-Id: <20190501160636.30841-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Casting mapping->a_ops->readpage to filler_t causes an indirect call
type mismatch with Control-Flow Integrity checking. This change fixes
the mismatch in read_cache_page_gfp and read_mapping_page by adding
using a NULL filler argument as an indication to call ->readpage
directly, and by passing the right parameter callbacks in nfs and jffs2.

