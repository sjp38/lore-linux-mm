Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE54EC41514
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 816BE22CF5
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 14:20:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="m0HDtaH5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 816BE22CF5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983E66B000E; Wed, 28 Aug 2019 10:20:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 935176B0010; Wed, 28 Aug 2019 10:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 825726B0266; Wed, 28 Aug 2019 10:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0112.hostedemail.com [216.40.44.112])
	by kanga.kvack.org (Postfix) with ESMTP id 55EBD6B000E
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 10:20:09 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 09D0482437D2
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:20:09 +0000 (UTC)
X-FDA: 75872046138.25.ball27_14161bdb8b35
X-HE-Tag: ball27_14161bdb8b35
X-Filterd-Recvd-Size: 2631
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 14:20:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=sZQvKKkgBv7RVxq8tsnNgXRW8GAf4XjhXYGu51O59q8=; b=m0HDtaH5Jw2DKV9t1fgm5v3dl
	bvDe+ZS2ajBH52xopxxJMHK7QOkiDyQYSAiPbltkHDNapsJRTQG7RcaRuVQSFk2RchqTP3KtSjApL
	yubTIqSK+c5RsBbxz83rYCW10Q37RBkA8Rk+YoZty3Q8ZCv6XGucvHCteecuHB1QzxR9MxAG96r0E
	+uoHU2j7Bzty5cn2fkR2ApVczM7UeUS8E6JMM251urmA4mW76KccUfrl28wn3sBuU/hNP0xASxCdw
	nFIdMFqiPITtzHqJ44tSxGoTQrqygDaDqGk9OPGWp5uLWo0TvnYME0KvKzn0P7wOQDlTgE6NSYbkR
	MxwC/N5ZA==;
Received: from [2001:4bb8:180:3f4c:863:2ead:e9d4:da9f] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i2ynl-0003yk-Ri; Wed, 28 Aug 2019 14:19:58 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?Thomas=20Hellstr=C3=B6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: cleanup the walk_page_range interface v2
Date: Wed, 28 Aug 2019 16:19:52 +0200
Message-Id: <20190828141955.22210-1-hch@lst.de>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

this series is based on a patch from Linus to split the callbacks
passed to walk_page_range and walk_page_vma into a separate structure
that can be marked const, with various cleanups from me on top.

This series is also available as a git tre here:

    git://git.infradead.org/users/hch/misc.git pagewalk-cleanup

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/pagew=
alk-cleanup


Diffstat:

    14 files changed, 291 insertions(+), 273 deletions(-)

Changes since v1:
 - minor comment typo and checkpatch fixes
 - fix a compile failure for !CONFIG_SHMEM
 - rebased to the wip/jgg-hmm branch

