Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4897EC06511
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15FDC218A4
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:45:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="m8HcPZ2y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15FDC218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100E78E0016; Wed,  3 Jul 2019 14:45:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0616F8E0001; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E91DF8E0016; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF8E68E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:45:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i13so2108459pgq.3
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=UYUSkq3MaywALpKQmbkqpd/XlsTvFn81MlHwxqWXibw=;
        b=H7xswSShLCCY9stYQkuqU9zFQ5YD/dIwO9dEOzFbxfuJ/+6IE2QOhmK5+4zVzgzfad
         aV4l4E9ekO8+S5wVYdsXKi6ax5jAWliqcf7hUyLgbJatu5P+bfMdzAdOdlbWxAFQVXm6
         4ogyX2FtYOBW/dTdUStnnZ7Tkke2D/qyg7o7PDqjmbsphro43HYidvZeBQJigMYRgEHv
         ISoOfAwOo8G2GAgIeBCxvoPhJXtx4iT+MZknKaMMZgrBeKgdHW8rJjywfA5cHEtPrIpU
         BqxHyw1Z9kBHyk9w8UpeG1Dj0wxon5nEEkugbwWupK32VsCPCEyUbInoZPsOqKOTGniw
         FmXw==
X-Gm-Message-State: APjAAAVVMcgWcRcJE/S8Y8wEYA0xuPqOCEUao+5qPPtDqlAexflQ1DYE
	SWMWCxDCo5UdXp1Z55lYWoIHFrjoNrf0Nd2dvVsIPQYjW+dqYLTTvdUS+DDijb19LFx3QyhsQh8
	mLWt0uHc9rLOqeP2qYMite6Zv53yTrO8m+Rg1ZntQedVtYNo/E+E1FSctfCT/zjc=
X-Received: by 2002:a17:902:b186:: with SMTP id s6mr43970343plr.343.1562179509351;
        Wed, 03 Jul 2019 11:45:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZGgZbZpaH7h/Noasd3ozYygn4g3FzYOydudJ4AV5U03B/vhbgcWRzH6pUqS7fLEFC49ld
X-Received: by 2002:a17:902:b186:: with SMTP id s6mr43970260plr.343.1562179508460;
        Wed, 03 Jul 2019 11:45:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562179508; cv=none;
        d=google.com; s=arc-20160816;
        b=OIIwBB+ZoLbWUEot8vhhJdD2LoMPODCVq4iWX/egz/LiMEe+8+dMUgLCATdIg092yR
         WAX5x6sKKPLnmcuRTPut9i3zMgPyx/JDrXwlvh/my+Ff1thb9WYzIAXCVCQ42P0MFIic
         YI2E9bd8QX103hMgPF64I3D6x32eEPsVEERvRO7kcnnPtAGt6GQ5b0Z+pZBFNiisgUnf
         BrxknXprvAeZ2V52wvwzJcc2jFx7rSVql7e9EiFyCXSvaUeh7VhpdM8ubMkIsqU5qhpC
         2oW3Xm+YSVCuNO1iQyumv8XHwjqu57eeyocpYOJbz09VKEat8LrKkdtVaiWu3YQHIYVw
         SuCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=UYUSkq3MaywALpKQmbkqpd/XlsTvFn81MlHwxqWXibw=;
        b=qSvOKWZGCxXAs3F9OR3Qy3RHllw9Pzr1Oyy2K1u1FEqomaUftro8rjGzMLv0ZE5FjR
         xPJTpzM2PRI+LiOgdelAYlNYJgje5+R+lQfQIwz/T0bkWKNCn9XwzY+EHuh1wZST41vT
         FO16tIA8NyXxk8rQ/co2l2EECY7e73F7S0j+bhgvOmUzrr0MSLvy1nDUmDt4cb00TjMK
         rSPErqECFYQjfsBaMGeXmDA2qoIx+GU5SHVYAWg3ljIqTtqPBPXTT8fcsUWjNi4YwtZF
         rKVRDW9+XdFqnApqWCWkBa+BERI80ZDIh2hmWGZlAdMzz5i8Iyf0EcTXRlhvdSVn4faG
         cKLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=m8HcPZ2y;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d6si2962579pjc.7.2019.07.03.11.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 03 Jul 2019 11:45:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=m8HcPZ2y;
       spf=pass (google.com: best guess record for domain of batv+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+f19a2f3755a5a2fb7ec3+5792+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=UYUSkq3MaywALpKQmbkqpd/XlsTvFn81MlHwxqWXibw=; b=m8HcPZ2yeJKhNSw16f2U4gwi8
	VaTgheKcvNfXeBOBmB/SsYKOJeJUuVqHvJ0+uwDyysD4GPpY3lM+PzTEkWhtLBBoggskp9VkHUsIk
	UyGPHDBv6lN6uVl40S7pfVGSDzMGXP3klgrtrx8i65i7XXeXSanBjwMihL5tpASfXcWHKK8049WC9
	4COYj4vK4P48hgNN3U8YbS8v6zZFinYOWgiAEjZk+THHb3vMXSTjZKjFTltedrmFPS6mdsp2vG2Cv
	lBShDGZVA77KiqJ0Ogl95z9sCHe597CJXw4e4rhrDdE12lmFKK4fpGmHckcPOwKSG/n3t9UTbQVja
	DEmxCAQ0g==;
Received: from rap-us.hgst.com ([199.255.44.250] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hikFa-00079g-W0; Wed, 03 Jul 2019 18:45:03 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: hmm_range_fault related fixes and legacy API removal
Date: Wed,  3 Jul 2019 11:44:57 -0700
Message-Id: <20190703184502.16234-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jérôme, Ben and Jason,

below is a series against the hmm tree which fixes up the mmap_sem
locking in nouveau and while at it also removes leftover legacy HMM APIs
only used by nouveau.

