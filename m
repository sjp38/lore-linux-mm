Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4B67C31E59
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB9762084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 12:27:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nRxanBbF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB9762084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F96E8E0005; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22AE08E0003; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1184E8E0005; Mon, 17 Jun 2019 08:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3D288E0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:27:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so6950523pfm.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 05:27:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=IiaLcJALEKaB7Li7OAHwGVaUV7J5HHtfGyRFzVhVT5I=;
        b=Ri2GYLTNKsXoRlrp5qJrTTCYv3xD3Fifvagy9H/K/2g1sDA/kELoHrjV6eDg8ZP5dV
         gaQjK2PsgBTuZCkLUl4sBEfcGze1ySrKHsm8n8j1GPMs3vj7KXpOaPNIVYW5uz+7kwfU
         ERjHUnMhgv32DRQHGJjotkunwPOdrwP+woLDmlHg/IE0cGup1njroStMVW6AwAT/TmMI
         UXB6JmPDXfV0zMCS/asEIciLyeO3jP2O0Bf49jWRteDFCych7cFe5A7Mina09XGJ8OiB
         yoWdqsI3tFjdVPT9gvlh20VAA+uLGEOc0Yjm2jsPovEKtvkZnXtGRRWltJZoH7BFQrr/
         eHtg==
X-Gm-Message-State: APjAAAWjyjmWBxfaKuvvmKADsXosJy0IAO+vLtbn58V/raokUnThdFBQ
	GdKNOpGxJ/2DXj0qWNvOL0nVS4yh8Q0nzuuihcooSDwo+CTlFVQCufwe9fQMI1o8cC9Q7rjiOuj
	LMp+v2T+/BpxlNnS6+QisCEWGuRzBewl9wyQRSjjjGy/Lu0qJd2VaVaEMh/JA5p8=
X-Received: by 2002:a63:158:: with SMTP id 85mr49963186pgb.101.1560774465168;
        Mon, 17 Jun 2019 05:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJiNd9z71u5FQ4vBAY+USdeeLDgSbMyoRFUMFGRnpCdGhIKQBZQLWc+Ot9aad8k5jf/M0T
X-Received: by 2002:a63:158:: with SMTP id 85mr49963146pgb.101.1560774464443;
        Mon, 17 Jun 2019 05:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560774464; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCEbrZf0YOvWGkFN3WO0itQD4wOCfXi3v/jabsPMM6vK+Zjw5LXMwL9BAUgwOuTOKA
         w8A9g9QT5nF3m3qOFDzMpDRUw1j1IMvNHWjOk0wekoPe+d9fELIHvxvBNzFoYIqfBaQk
         vsUlIhb+16YYGMLD14cjcF86dwwVBz9slgCuWGB6vZDb+6B16KK43Z3liI9ZLmzLhMtg
         hjAOnDGfpjsKXh8Jzsbcv7J7ox6RdvOhpJXo//yHSclIXlVPSMKV7bQqqSNQiG+NnTW5
         fUEyw2o32ezB+sGpfj+QhmFFtZRhJFMKE0ODT/N/MlPvkFzWXQlqFE63lCibq7m1XhfD
         gP6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=IiaLcJALEKaB7Li7OAHwGVaUV7J5HHtfGyRFzVhVT5I=;
        b=nTy4peX0JSIXkRxU8/6PNOXrvtUTYiFSKsEVU9J4Ih/t5YA8MQd2SSFdVYzb6hBQnm
         PhGfuPE/W/7nAg5jiRc97k3IgKQNqFa8/8IIYAGZ6OZdWkp+Sfm07jhsbM4KNtA1SzhX
         bKKg6hHbU7Os3QDPEITwOmOPjdzxRD7xkakEqvhokOLsj6hiwtE9B8Q6ZC0gddGdd8B9
         Df5VWdB2LrTNn/hsWcB9sSW9LJTgyZov/1KgePmYlaJdzeyTDGA0A+UtMUG+qTQGpgVf
         6gVYZoSx8JUkmiHvFdogK68SCCJwxl1z0DK2DKjSEKRYCcHncge5oUNM8WfQGCfxhhCa
         7W1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nRxanBbF;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r71si10712494pgr.518.2019.06.17.05.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 17 Jun 2019 05:27:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=nRxanBbF;
       spf=pass (google.com: best guess record for domain of batv+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+a9ecd0bfb5b639be820a+5776+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=IiaLcJALEKaB7Li7OAHwGVaUV7J5HHtfGyRFzVhVT5I=; b=nRxanBbFaXKRrfonPCdCK8x8a
	H13NLWpT/FYGEMhPawtjpKXuuFd5AsVGls0FU/bFblMxeQyfmVpGkj8pGsbrVCCWMJWTllTMnGpqR
	lLvHY6XYJAnUlu8naiV+ey/kfflUSIzdOe46iLEfPoDAcpWQgUXfY+Hmls32zlkAUygawRFXkMCHP
	wYZFnLlYcqST58xEgFnwklfAMQdGemLG8MCW+sf8MPt5vq44TqtytxlspPlDutukXjQTeeXjgmomc
	DBnAvx70XsOhTxq4s1gUZqpsTkLMt1yioXaF7KDQUOS+v7Psp7YyIakjW17TKDyANImlYyLvulA8s
	Kdy4HvCiw==;
Received: from clnet-p19-102.ikbnet.co.at ([83.175.77.102] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hcqjZ-0008K6-5z; Mon, 17 Jun 2019 12:27:37 +0000
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
Subject: dev_pagemap related cleanups v2
Date: Mon, 17 Jun 2019 14:27:08 +0200
Message-Id: <20190617122733.22432-1-hch@lst.de>
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

Note: this series is on top of the rdma/hmm branch + the dev_pagemap
releas fix series from Dan that went into 5.2-rc5.

Git tree:

    git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.2

Changes since v1:
 - rebase
 - also switch p2pdma to the internal refcount
 - add type checking for pgmap->type
 - rename the migrate method to migrate_to_ram
 - cleanup the altmap_valid flag
 - various tidbits from the reviews

