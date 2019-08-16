Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 816D9C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473BB21655
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 06:54:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PpvYvAH+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473BB21655
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F9086B0007; Fri, 16 Aug 2019 02:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A9DC6B0008; Fri, 16 Aug 2019 02:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59B966B000A; Fri, 16 Aug 2019 02:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 307FB6B0008
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 02:54:50 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D3370181AC9AE
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:49 +0000 (UTC)
X-FDA: 75827378298.21.twig97_4739b0ab4471d
X-HE-Tag: twig97_4739b0ab4471d
X-Filterd-Recvd-Size: 2448
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 06:54:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=GereEEuIF570EiKueg45SrscGAcsm53Jmc8D7sejksY=; b=PpvYvAH+KP58nV6izstqduOxt
	6xZbDzbpIZtPEsO9CQjgqucxq7ocLr0SIseaBoGaJY4NFwkG+IubSesgQwLQBlyQE3QsLPmjVLVfY
	GmuBb7lhlEtEosRF0w8bMzrYlcr4QdtE+hmgmB54j6YH/sFwlDhne3pDBbJ/V4GtymNSSSbJVKDdF
	pelq9A1cESIRK5Y7ix33Fs7hOIYdzquVSs7ZiqG/uL2n4RaGVkxFDL4C94ertZYqFI3nEFVCoZA7F
	Y6FcG+haPB/P3GUmrdK2i7hzOmUO2/m5N1zpZf9U/PzEfFf4snYbd23glYY5wlJvTPC7/fEyFlLeX
	t8QFPJsVg==;
Received: from [2001:4bb8:18c:28b5:44f9:d544:957f:32cb] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hyW8D-0008H2-1p; Fri, 16 Aug 2019 06:54:40 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: add a not device managed memremap_pages v2
Date: Fri, 16 Aug 2019 08:54:30 +0200
Message-Id: <20190816065434.2129-1-hch@lst.de>
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

Changes since v1:
 - don't overload devm_request_free_mem_region
 - export the memremap_pages and munmap_pages as kvmppc can be a module

