Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0473EC3A59D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACBCB22DD3
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 00:30:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Huw1B8AM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACBCB22DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C3026B000C; Tue, 20 Aug 2019 20:30:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 06BC86B000D; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4E526B000E; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0118.hostedemail.com [216.40.44.118])
	by kanga.kvack.org (Postfix) with ESMTP id BA5AC6B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 20:30:51 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 662AB180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:51 +0000 (UTC)
X-FDA: 75844554702.02.jeans73_419ddb2691353
X-HE-Tag: jeans73_419ddb2691353
X-Filterd-Recvd-Size: 3016
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 00:30:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oeVOANfId+UFajzaQ2gzW3c9xEV2b0FiX63evlEKZv0=; b=Huw1B8AMREhrx9XNmoNt4deM9
	XSwL/uolvP12oF8bakTOb7gFvccAgSYatlSvv+RwOvuBI9BK82q1JqugmsueqUJgDGNHLUBBc4DCm
	sD3r5M8F6HJoy0IXcPqibA1BqVjt4yjo1S6wUcbb/zFH87Nyk+JwaiDp52ecZDxywdLagHBjD2JaT
	OC6kJF8BHpxkJJOgIInWAPbzOUoPkTHbJUFKR7UjSKlhvoGTygIQr+ld7CoqaF4P5y1JaxTw7sRcA
	LVKoZsjeg24PM2/zpg7HAOCev4FNVrKKIlJo48lA2VKZV1aNJASlHIaQsoaHn2HP23USgRMtBCwmD
	zOdQErHLg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0EWQ-0003HO-6R; Wed, 21 Aug 2019 00:30:42 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	hch@lst.de,
	linux-xfs@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v2 0/5] iomap & xfs support for large pages
Date: Tue, 20 Aug 2019 17:30:34 -0700
Message-Id: <20190821003039.12555-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

In order to support large pages in the page cache, filesystems have
to understand that they're being passed a large page and read or write
the entire large page, rather than just the first page.  This pair of
patches adds that support to XFS.

Still untested beyond compilation.

v2:
 - Added a few helpers per Dave Chinner's suggestions
 - Use GFP_ZERO instead of individually zeroing each field of iop
 - Rewrite iomap_set_range_uptodate() to use bitmap functions instead
   of individual bit operations
 - Drop support for large pages being used for files with inline data
   (it didn't work anyway, because kmap_atomic() is only going to map
   the first page of a compound page)
 - Pass a struct page to xfs_finish_page_writeback instead of the bvec

Matthew Wilcox (Oracle) (5):
  fs: Introduce i_blocks_per_page
  mm: Add file_offset_of_ helpers
  iomap: Support large pages
  xfs: Support large pages
  xfs: Pass a page to xfs_finish_page_writeback

 fs/iomap/buffered-io.c  | 121 ++++++++++++++++++++++++++--------------
 fs/jfs/jfs_metapage.c   |   2 +-
 fs/xfs/xfs_aops.c       |  37 ++++++------
 include/linux/iomap.h   |   2 +-
 include/linux/mm.h      |   2 +
 include/linux/pagemap.h |  38 ++++++++++++-
 6 files changed, 135 insertions(+), 67 deletions(-)

--=20
2.23.0.rc1

