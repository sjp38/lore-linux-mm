Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7628DC48BD8
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24399204EC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 12:27:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e05g33We"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24399204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6BD98E000A; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF3458E0002; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE2938E0009; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 785548E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:27:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s195so1525694pgs.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 05:27:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=YGx69ktqFfd50Mnd66pLKlz3uikDiZWUcfJ3jfUuvQk=;
        b=VRJjl0H1nSdjCIz4E9rc+juFp+Iq2zJ0gygp5SD1qfpjdDOL4VF5cEGA8CrYj/dyn1
         Erg8UnOEg4Xt4TdoDl3BtaoYYpw2zQw6PUSrS5L+GEYERIMMMW/CFDcKPX7I+BrIz/+a
         Ov9LvzYo6YoO1KrUr46wvJ7CFhCJEDhFtpNFhBksDaPQKKixb+4s/qUD743UCCgvZ41N
         3KTfmdVs9j7gIIL8H+GKbI9DSCIRL/vMy0AWl0Bbxck8tluJYEYXrxtOpRHrFa2J2erW
         CeJ3HM6EjQLe+4B37eiMreAzIoW/iHwU1GUlVcTweg9xkysQGeNRhSj27652y9eMsCBD
         Hkvg==
X-Gm-Message-State: APjAAAVlRC0TQzSpl0EmcGAW5nsYmItgFJOi9CMmVnu5T5xbs58rmjHX
	hFBztUfvlIf3FrMO6U3EcossHQ4s68p6R8QULy3FCUCc1c5I6DDTeQuNoHoMDmnqpx1rc0ySPWE
	qOdzcIf4NgrZ4appONmbRvb6AkSvUP8/8WFv7qW4jaVja+ZOG/77YS9DOSUOrPpY=
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr2661490pgr.398.1561552058902;
        Wed, 26 Jun 2019 05:27:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVm2aLyrkH8ZBTudPJsVqZ9CKqKYDiTVhWdCSho9Y2nLm6LRviRANA03wW0NSFAJLONpvn
X-Received: by 2002:a63:2bc8:: with SMTP id r191mr2661435pgr.398.1561552058068;
        Wed, 26 Jun 2019 05:27:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561552058; cv=none;
        d=google.com; s=arc-20160816;
        b=e5oldtijkqhJ+sMqJQGpxlp2FvoW59Z837lcYMEra0xLljfk15Md71S4kEQRHICEvE
         DTUCwTlykDP/1LvV+DLO+ZDd07MRx+T2IkNrjSbfaaF/mogmlMx1uDa7fxY7l8J1gfZH
         4ZbLD1sQH488pS9vxhoqH+wDYuIvA6ZKQCfhROiL7RKlgPkpMQyNW4Cp1vITbZATVcua
         VaQeX9ZLSDZwvByvg78DaWAeBULrT8Ov06/l/eFIaZgrE080ZIWDhnusYlxC1PtBpN01
         7OvuC7xc9fLb/VpLiUal2PxaimJLLF7ak8/li3tu+OqoCGkagFBc//yQz7hb2ky6QpS1
         3riw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=YGx69ktqFfd50Mnd66pLKlz3uikDiZWUcfJ3jfUuvQk=;
        b=Z6Z7Fokvv3rpyHCEJrp8UFMrcon7iltWRt1TwWkttfQTgA5LvzfLtbY70ERiE12feP
         vxOilCHl5t8i/LqQJldHwCOV7T4msJzYnsiJzKK8oyfAiZJyeNoO+h/5Rg9Gcvb7qNaI
         AmrvNcJj+9dDu2Gs14+F7mVaycvgdeGb0wOtyPakdNZ/AhqDAIg4zGX19KZG/uPTo5CD
         93+ZTTYxfJS7aAp8y/z+xIxRLybJ3l/+ZJ0++Yyin7qx9bT6qoBLuWpxG8FoduDo+17b
         Ke0r7Z+Pj5QszErUrIsCQP821yrwbrsdvYOleEPwuzXgsrh5S+XySfrQ1Iubs3SRz8+W
         qBuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e05g33We;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h127si17642740pfe.44.2019.06.26.05.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 26 Jun 2019 05:27:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e05g33We;
       spf=pass (google.com: best guess record for domain of batv+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ab1f803c58217d155be4+5785+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=YGx69ktqFfd50Mnd66pLKlz3uikDiZWUcfJ3jfUuvQk=; b=e05g33Wex+0CQQ9qi04aK+PPD
	72YJJQlOybfiI5HDpvAwNw3qyS9BQ2WnPDw3YMr+fSZN7R9d4Tn5T/Kg6qLvyaoDaHQZ0vlVbYbhx
	sH7r9sk7n9uAVs7ytRQPMUWtpIBu34n75RQsdX09ZN7vTlq63SjgxFL3+W2CGRZnbY4b1uq2QoXC9
	wfCap12FyOEmQpV3o8HSsJ+3sDUypgYRRenguNdBNIJhO4plDWVryg6VP0j/VmweKz3YUcCgDWjkR
	wJkxMMcljSkpHVx1W9E80XqfefYKjbk4v/9jvt3SU/bAHja9Xecuu8HugJFvBvJ02cUDAF0fQb/UW
	LymOmxY1g==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hg71L-0001Kf-Nf; Wed, 26 Jun 2019 12:27:28 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: dev_pagemap related cleanups v3
Date: Wed, 26 Jun 2019 14:26:59 +0200
Message-Id: <20190626122724.13313-1-hch@lst.de>
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

Hi Dan, Jérôme and Jason,

below is a series that cleans up the dev_pagemap interface so that
it is more easily usable, which removes the need to wrap it in hmm
and thus allowing to kill a lot of code

Note: this series is on top of Linux 5.2-rc5 and has some minor
conflicts with the hmm tree that are easy to resolve.

Diffstat summary:

 32 files changed, 361 insertions(+), 1012 deletions(-)

Git tree:

    git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.3

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.3


Changes since v2:
 - fix nvdimm kunit build
 - add a new memory type for device dax
 - fix a few issues in intermediate patches that didn't show up in the end
   result
 - incorporate feedback from Michal Hocko, including killing of
   the DEVICE_PUBLIC memory type entirely

Changes since v1:
 - rebase
 - also switch p2pdma to the internal refcount
 - add type checking for pgmap->type
 - rename the migrate method to migrate_to_ram
 - cleanup the altmap_valid flag
 - various tidbits from the reviews

