Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD606C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:08:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87D652173B
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 09:08:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ur9iGQGu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87D652173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06F666B0008; Sun, 18 Aug 2019 05:08:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01FF16B000A; Sun, 18 Aug 2019 05:08:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4FE86B000C; Sun, 18 Aug 2019 05:08:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id BD81A6B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 05:08:18 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 58B5A440C
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:08:18 +0000 (UTC)
X-FDA: 75834972276.17.soap38_2b5eb525b5342
X-HE-Tag: soap38_2b5eb525b5342
X-Filterd-Recvd-Size: 2539
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 09:08:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=e+O2aoiz2diKfBtl4/embp/7xoIG/bN4LQJcAaqtku4=; b=ur9iGQGu6Vzub7Y28WrS1GrmE
	h2bcrFZdf+/QZFVZSFVD5pMssp6nEp/2wEareZZi0Ai57s+tDhJWb2pJZ/gXZEW5tQCanP7WCM0O7
	Y11YAjqCGerBkBuJg2AAMLD9Ba4lGzNm455GLTzqZ1HGKUOPUBORPcRvRaED42z3W26iZnqQ+V7c0
	h1RRlLhQ4mX3tM8momBg/QozzGt19/KJjfIFDyD598N88YXl2cVT2knYNo//MyXcWc/N3JX9pmGqa
	E6lXYnUKANKf3rBlJrXDedPP34cNwckV3gfAtnQ5FG/x7olCrhEX1E4AJJssD39b0qgF6uLUMy4NR
	j0DPXbc3g==;
Received: from 213-225-6-198.nat.highway.a1.net ([213.225.6.198] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hzHAX-0004ow-3h; Sun, 18 Aug 2019 09:08:09 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: add a not device managed memremap_pages v3
Date: Sun, 18 Aug 2019 11:05:53 +0200
Message-Id: <20190818090557.17853-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dan and Jason,

Bharata has been working on secure page management for kvmppc guests,
and one I thing I noticed is that he had to fake up a struct device
just so that it could be passed to the devm_memremap_pages
instrastructure for device private memory.

This series adds non-device managed versions of the
devm_request_free_mem_region and devm_memremap_pages functions for
his use case.

Changes since v2:
 - improved changelogs that the the v2 changes into account

Changes since v1:
 - don't overload devm_request_free_mem_region
 - export the memremap_pages and munmap_pages as kvmppc can be a module

