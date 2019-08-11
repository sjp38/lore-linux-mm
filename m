Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C16C8C0650F
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:12:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68E9C208C2
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 08:12:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="jausoYlX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68E9C208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D37B66B0003; Sun, 11 Aug 2019 04:12:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE5DE6B0005; Sun, 11 Aug 2019 04:12:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BFB096B0006; Sun, 11 Aug 2019 04:12:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89C0F6B0003
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 04:12:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x10so64455495pfa.23
        for <linux-mm@kvack.org>; Sun, 11 Aug 2019 01:12:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=duSr/7/isMOllSiQdJtuYj1CP9drRkouK4Y/GwmPE9E=;
        b=BFeH+2s/JWmAGET8lbryj4UGHLQg5PIh+gnhccgwwo7Fr+qa96LbId1JD/rQ1y/x/i
         O3SS0MQ5/YrntM8y+vKnhOAOTGx/41RQcpcFY7Eh7WAp+2SmdiLEQ/Xp7GC/IGwY7Iev
         2T6ZI/spsj3/mgas/M2fz5aOuTYp6MkqzFoNHiiL/MXqEZMY4Zt92NljCSK1pwjKp9a+
         aaU6TrUFIeXSRlMmielkl48mD1ef4y0foWG3Ps/UhipLxHpCWjWwidCSk0v4jaLEifZC
         xFec39enIvqoigzjXnyKaA4Qg3mdfpJTEWeC7Ypnqgfa/vTHWXWearM7mCucIeWtc0tk
         f2tw==
X-Gm-Message-State: APjAAAV3szCI5xEjCYZoh7zsa79pxvXJDd2mG+XBboeibYHbIW0DngA6
	2df3WmKyupIbeZGUQX2u4KcXPq3G7RF7WQJZJhqCc8qk5Jh08RG6yEdLRqv7vwvc0VrRE1NjRDC
	WTwbBN48N39ti3NKcUpWXj9hQ9foRjQYbQ0UackIaPLtkOYIFpAsvje99oyLigB4=
X-Received: by 2002:aa7:9146:: with SMTP id 6mr29375883pfi.67.1565511174030;
        Sun, 11 Aug 2019 01:12:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOwlrBhRvyEAOBFGDBRKooCW7fJMI5TT/rxuK+3jb2HHX0gYi6B5rwGGYH/wKX61Wf3nkR
X-Received: by 2002:aa7:9146:: with SMTP id 6mr29375852pfi.67.1565511173215;
        Sun, 11 Aug 2019 01:12:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565511173; cv=none;
        d=google.com; s=arc-20160816;
        b=rrOPdZ80S5BnnQ1POb4cjmp/Fs4VihNOxrQPpB5U2+wiAFcxrhEI10KrhOxx3f3xYd
         Kd64Z1//wvBlqzeddopfff5AazK0SDUr2v91bRMqESbfRZPC8IKmU/vDoG/dzuoD3PnY
         JGvnuvPzUub3bHqd5AksYYgqiz7llLh5jPIrQEeSZEYirUBN10CTvOTvyUN9BizJ38nr
         ksFuR7HiCoFiNYjx7yT6AjGQ8FOk02yrT+oK4E7zvRwiRgMRtQxN7STcqnFPGnGlCW8T
         HrSOtHh++8RQ7ONYIckjGN8pDsBwsevCa75SUdXCuWThOVlXgOsuhNzVOFwZ/9RnvLeH
         4XJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=duSr/7/isMOllSiQdJtuYj1CP9drRkouK4Y/GwmPE9E=;
        b=Vd11/Q6DJh5/pdLzZ/HuSCg+Zi3lHDhU3qG1kkLU4yKZ0Cyumh+wYXl/b6LSahKnHw
         gbu6Uh+kFiQOXqVotMWs2HxROtDzpsfKr4CJWvDs9bOMDfE2WQ1Bl8O1kcuY+e0ZVdEa
         pNjJqZzQGGjnuIj0LvFvUoM941YFXa9SPWTsWweIAsvq8Y9+gTtkfltnAQnP74kvArTZ
         CR+XgtHU4aKiBR+70mIuBjHHgi4rGSE0tcVkAG0A/Wudxbnrn549gqgpdHtjpWkfGU6u
         ogYWBiB4ZqW5stxTAwLi+0qZNkOflYtddgp+/mBkVXpkORYALaKdtll5DPz3DiOHjEWJ
         eL5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jausoYlX;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n187si63044121pga.165.2019.08.11.01.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 11 Aug 2019 01:12:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=jausoYlX;
       spf=pass (google.com: best guess record for domain of batv+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ae155d32c5e98ef18dee+5831+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=duSr/7/isMOllSiQdJtuYj1CP9drRkouK4Y/GwmPE9E=; b=jausoYlXofSB6fNPgltUVfKwO
	6u1d10UxCCDGkunYpexGn7ariKsfdVq5MMOrJ8+xUmsui3PRCPjLtcDqlhnk4H94uWAIfYVj0x0/X
	Y47lQw1ooEct2Q6hG1lyiKwTD5jkeB5tOPONHD+F7gW4dvLBVGX1+Rzzo8DhyNMuTJtCZzP6fTNfM
	5wCEUVJlCUBIoil8nqLRnPv8KTxoARl3gE9o2JN9JHPLnljViWNtgoxbiu6A3xpj1FPzVWEzeO8dm
	0981hJotdh4htrXntHclw1A5T1UspEkzRJoBDqKXRL8Si6jPvLLBsSJw4Ggn3MeffzO5KR2hQ11y0
	wanviGajg==;
Received: from [2001:4bb8:180:1ec3:c70:4a89:bc61:2] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hwiy9-0005CR-Q5; Sun, 11 Aug 2019 08:12:50 +0000
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Cc: Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: add a not device managed memremap_pages
Date: Sun, 11 Aug 2019 10:12:42 +0200
Message-Id: <20190811081247.22111-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
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

