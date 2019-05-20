Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F373DC04AAF
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EBD120815
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 05:58:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="E++Ia8pj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EBD120815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43DF56B0007; Mon, 20 May 2019 01:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EEBF6B000C; Mon, 20 May 2019 01:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DDB96B000D; Mon, 20 May 2019 01:58:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA8376B0007
	for <linux-mm@kvack.org>; Mon, 20 May 2019 01:58:29 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id f7so8477016plm.15
        for <linux-mm@kvack.org>; Sun, 19 May 2019 22:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=jGTww2FTm6wjbIUY6D49ZjWpoiq21E9raY62orB2tKA=;
        b=HZjlIRABxHkQC0bJRY6EL3aOx+kSSUOktkaik1801Ci+c6wQotg9J3597ZX/Ej9KqT
         Hb6+HUiKaNtsMILFweqHdDrLI6fQ25Cb6iKqV/NziqGXiFpTVVsSDaIYuAFL5ehdtq5T
         9AZ0EgK5VSiGMATpt8ugMHj/JyxwzBYUvXjvw0h35q9/Z28Fr/LJ+a3XXyxvF6mbJn7H
         VRlufrAw/w71tiyZUhwUB/MCNPL8+ih0AFFB6oWAXlX0/FDdGJwp7goegs/s9yWO52gA
         JUWuniIh1oKaEK7xwtriEBFL0tPTrOpx8lRJGYcPGF/S1+niyv4E+DnDqVAMhg8gcQS5
         954g==
X-Gm-Message-State: APjAAAWvNgQ5xTdw5gtoq2ZQjb7/kpCp99yQm6PPKbPeUcDU2WkBWd5F
	oPXScZHEpRq2X4cY5MLDmkNoku/fJMGZWJCKqAfx5frc6DmfIBbxpF/Y8Mqsy26hnntLTuslLEI
	jouuBypUAovihlGiNUsmJP4y6PnnLmL9W7Eaif3IL31lzd6zgBmxI5m8hloLCaBw=
X-Received: by 2002:a17:902:294a:: with SMTP id g68mr48659835plb.169.1558331909641;
        Sun, 19 May 2019 22:58:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNhtcKpFQYwFnMiy8FCTJBqD/x6SPxQGJCyd52Cn97Gim7RD1tF/hMEgcwNF9D9YB6prWW
X-Received: by 2002:a17:902:294a:: with SMTP id g68mr48659793plb.169.1558331908911;
        Sun, 19 May 2019 22:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558331908; cv=none;
        d=google.com; s=arc-20160816;
        b=qgXOv8U1sGBYuJW8aQN20KsT5BIKzE54isBuFpyEq7YYycjDO+FAHwI7KN0aTzVl8q
         GDLEy2gM2wGTvH2H1JmwfEeV2nSGjTMQT9XIBQmFA3r5mCDInhCRFKinIFYM96aTffrj
         g9vZcQ/yOsd8wScDfFfYpjOGBFuIMNPkcJJJOyANijcWC5AW+UxTrV7m97m/nTe1lR2T
         36KnuGbYIuNAdeQwEgVQryNtYsdxEi2qiBL2XnhxvUKA+0kwlTkiILiJCRmYflbHQXPJ
         /3uV3pOo7p3HaLf6cH94hYvVFpCZ41JZD+wTPq3V8yR0JcNLQzZ6iLmknzQUe3KJbuMH
         jKyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=jGTww2FTm6wjbIUY6D49ZjWpoiq21E9raY62orB2tKA=;
        b=qId7igLD3qss5dlOENYruZD2ne5MmdAXtPg0zswL1cSa5eb9v2nfwbFEm0eJZ/Irr4
         j7kke4oV9PnJkfCZHKzkcXcgm2ekszfblYmD6yfqgQnw1A1PDeyg1VurhQI1D524rmdQ
         ALfmu0RRYdk2VyHmC9JKtRnxsNBDolOpyciQD0TgYw6rFIpj8LcUuN9/J7CZSF+u5WmH
         S4Gu06P3f18OXCdrOHeYpTlfZuqfVyD4QQh5bfHF4/WS1NRa2orn2ZwO2Dzw32rsi7rk
         8yANt2Kkv0nEUSrKGMALUxxisoaTRe8je3TiRx+jd+Os+TRPbV5ZfweKxRYxEo7h2HEx
         lD9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E++Ia8pj;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l22si18679884pfb.153.2019.05.19.22.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 19 May 2019 22:58:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=E++Ia8pj;
       spf=pass (google.com: best guess record for domain of batv+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+dfc7240828d5493a4f00+5748+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jGTww2FTm6wjbIUY6D49ZjWpoiq21E9raY62orB2tKA=; b=E++Ia8pj+gBgCi43NyPE2MPeh
	Zq6NmIBTQmvgWzeS0EQ9KqMUsZ17eo2vwCRLCF64hVZVZIWIuHx4GAO0Ryyc8fDevPlfliA4WFobz
	HQp44q1A3PVRJQgqwnbhKm6SFVi8lSBmolbpXhfGc8LSEOIW92QWh1KL4WtepfxJDfKTHNJMBUz6j
	Q7nom0JqHFMTN4CWQwPAA7FfP3BNdzfoVp+ORN8f+36EMh9ySRdEjtstN4Kv767jJ69OW2XBmaSDk
	bVZkcPvLylFeecs/qBgxPAfmAQBCDBqEKXN9igzWleFMqyjSFgsNg1JSOZiSwS66URY44LHm9jWal
	RR3LBF7LQ==;
Received: from 089144206147.atnat0015.highway.bob.at ([89.144.206.147] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hSbJY-0006DS-7G; Mon, 20 May 2019 05:58:24 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org,
	linux-nfs@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: fix filler_t callback type mismatches v2
Date: Mon, 20 May 2019 07:57:27 +0200
Message-Id: <20190520055731.24538-1-hch@lst.de>
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

Changes since v1:
 - add the 9p patch to the series
 - drop the nfs patch that has been merged

