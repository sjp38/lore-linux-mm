Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D38E8C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4E212070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:23:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="d6WylP3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E212070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCE1D6B0005; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7D896B0007; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1F396B000A; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id 974606B0005
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:54 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 0F50F40C0
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:54 +0000 (UTC)
X-FDA: 75901690788.23.floor54_794f08d336c3d
X-HE-Tag: floor54_794f08d336c3d
X-Filterd-Recvd-Size: 2776
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:References:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=LKUiBNu62lGmhyWv6FBhdsxxt3Gohyu4Oappg0jQS50=; b=d6WylP3ncbyOTDyizq27EEdpE
	D0TxFudh5JMyplHfsisMFB5yciYIFD5ANr268oaWVnBhwn9vfdR7EPsUOyu+mWQv7NycKbIEGPGEw
	+aDmWE00s54BVbTZu1z3XkCrPyKt1y5FA3PQWfHEISoO51DcWnHhHS32qJkZBnMMX1XYBmd82jIIl
	M1xWSHoLlxt8Wpo85IbYl2GoHcfs/WIOcPVGKnrLJw1QVPgC5/NIZcTQT3AaxzUd9GbmQZkmHdIVR
	bUgtYW2BA06zGFeY+ty9x9n16bl2oF47saflW+5XzkY3dm1yruqZU06UolTu8kUJfO5iLcPQxI3o1
	S/53ISTTw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wQA-0001Tu-8A; Thu, 05 Sep 2019 18:23:50 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: [PATCH 0/3] Large pages in the page cache
Date: Thu,  5 Sep 2019 11:23:45 -0700
Message-Id: <20190905182348.5319-1-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Michael Hocko's reaction to Bill's implementation of filemap_huge_fault
was "convoluted so much I cannot wrap my head around it".  This spurred m=
e
to finish up something I'd been working on in the background prompted by
Kirill's desire to be able to allocate large page cache pages in paths
other than the fault handler.

This is in no sense complete as there's nothing in this patch series
which actually uses FGP_PMD.  It should remove a lot of the complexity
from a future filemap_huge_fault() implementation and make it possible
to allocate larger pages in the read/write paths in future.

Matthew Wilcox (Oracle) (3):
  mm: Add __page_cache_alloc_order
  mm: Allow large pages to be added to the page cache
  mm: Allow find_get_page to be used for large pages

 include/linux/pagemap.h |  23 ++++++-
 mm/filemap.c            | 132 +++++++++++++++++++++++++++++++++-------
 2 files changed, 130 insertions(+), 25 deletions(-)

--=20
2.23.0.rc1


