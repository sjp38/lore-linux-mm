Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 322CCC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8AFD2190A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:46:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="D6lBcZ90"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AFD2190A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF9958E0004; Wed, 13 Feb 2019 12:46:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAEB78E0002; Wed, 13 Feb 2019 12:46:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9A68E0004; Wed, 13 Feb 2019 12:46:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFC68E0002
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:46:40 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x134so2408808pfd.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:46:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=3tZ3NHZ1d3bA/70lj6RR5Q5NCXupe66P+A7rmOeDnE8=;
        b=os1XNCDjL744F8K5mUwvKx23Z2L/r250v9V0Zj4am3WYlWqVnI9G5YyJtZyfetKEiU
         XJWajHcXlVlxp+dzUN+eJTsLmPeTx3J/maEmKT+byf4m5GNhmrySTaUE5FU1DoruFhbA
         geL/dRejQ3rl1wgHfNu174OLp3kHwHupmIG0BiBozGWCe8nqQv/qQ++YIxVNDJv3jGr0
         YOfro5UUABrCNaL6XiBnuXTtxh9cezvS+Naub//gM1hnQVI/HqE3Ff0HHg2/0Z01G5zo
         2Yx1tBAvVzYPBlnipN8cdm729g4gyshbXoSiXzNaGBER4nAYge5YNUImmBGbBatX1nX5
         rGgw==
X-Gm-Message-State: AHQUAuYCPeH64BqR8B/LQKuiM6E7HkaQ95Cx6Y/xmkCEQskz3oSviKct
	ablhJvr1WAO2rgNVOWX6KQfD5RsFKgTzgnhQeL0pfHh7Uwck9AZzacw8VMI5pRaB4S/XxBSQfPp
	jaBN6PmXTM+F/74jBKCib17ip7ULXzFqxqf2bWK6Gn/Ek5O6STeNJjgpU04A8cnk=
X-Received: by 2002:a63:4611:: with SMTP id t17mr1482926pga.119.1550080000185;
        Wed, 13 Feb 2019 09:46:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhRAyIIUi9A6S0caMIeVHCc4Z2R7LjLY+O005Ku5N+Y6Dm/QlSR7nvxTlkqgWiL1gZR/tZ
X-Received: by 2002:a63:4611:: with SMTP id t17mr1482891pga.119.1550079999675;
        Wed, 13 Feb 2019 09:46:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550079999; cv=none;
        d=google.com; s=arc-20160816;
        b=SZP1cJv+UUt+Tc/XE7B+0Q4vVTX9XJr/iohDIe1+URxuQUsV2BfEewNkYsSy1uDS5m
         rB7ReAdpBScGtKorCFv5Pl+t8t+kRpJPgHWf4KNiSwtbLgULK5P4AY66sraDzd63UG5s
         JdrKfZknuJMpDplRcwOYS7MxtumCr9WEIAPXRMHflMLOVPBx28+YLVjLvFmpMTu53qVC
         VkZrlYDVBXTsKjWoROOQRxFxUxTLRli4g/UartJZmWZ/h1M41eYfn8GCkExlZyMZW5un
         rKWOLt9FB6CidV782VZop3UD4fjHHOaQenLRAxD6MoSXxk2aEjyIvG3aAuZXVXoKNSTA
         srqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=3tZ3NHZ1d3bA/70lj6RR5Q5NCXupe66P+A7rmOeDnE8=;
        b=ociIlUv//yeWKz6hrHuB/xDGIM+dG/OHR1PKotEjDx+uOs8Uw/xTFgYt+xpjPlExx1
         +X9yM7xqBmM9jIl03s19eFLQH6BEwYlCeAwjhzHoX2lUIHavSMXZvm2RG591D7ZQqtPg
         pvicsILlQLJAAfDo1CP3sZtvB591PiSVJ9HkeCRSrdN5biKGMxxoC+2WNHcD0+0655BS
         zbcU0jb1KfE3BqKIDLf4F1vwnxz7c69atiI/iOwhD7+e7URf2aVt5XXwv/GqvA1oOveA
         +44YPkgg72oADR7g152m8v4M/mGDR7kuk1idD1eY1DO6E/fVtDB123MzcmYErgHPAumc
         yh3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D6lBcZ90;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e192si16338358pfc.28.2019.02.13.09.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 09:46:39 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=D6lBcZ90;
       spf=pass (google.com: best guess record for domain of batv+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+b68490c3fe13e616ccfb+5652+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=3tZ3NHZ1d3bA/70lj6RR5Q5NCXupe66P+A7rmOeDnE8=; b=D6lBcZ90Hp+lGIn/L8UmQVvqF
	Jtw0mI7xsCH9CY0gYLt7fRtXn1XpjpOX3wRshZaCsV1zKN7m+pW+MMKFreQjHyMJBSJU5S6VqlV9X
	suMmeTm/FjafmxU47yuz5E3noPkNFDuGnvwvxJNbIPEfNEe8Aq81S/0JqUbM6BElLZFeq3TMH/eOj
	NraTaSD140I96d3Hqm0q6HSDqDQBKRm312wPUUxtVfUWzFaVeyZPWdEw33FJsCyAGKA+mjgOr5RGb
	lXUWaXTiQ0Ot/I7ElFcJhjMh9GQ5huxp2ri0Xu3OoctbasoJ4RWYnsH+GDPv8zFipw+oUZI7z+Py+
	hzFnNGBvg==;
Received: from 089144210182.atnat0019.highway.a1.net ([89.144.210.182] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtyc1-0006Xf-HW; Wed, 13 Feb 2019 17:46:21 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: initramfs tidyups
Date: Wed, 13 Feb 2019 18:46:13 +0100
Message-Id: <20190213174621.29297-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I've spent some time chasing down behavior in initramfs and found
plenty of opportunity to improve the code.  A first stab on that is
contained in this series.

