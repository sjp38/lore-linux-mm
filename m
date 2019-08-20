Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5D54C3A59D
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72E6B22DD6
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72E6B22DD6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15BF16B0269; Tue, 20 Aug 2019 09:18:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F361B6B0010; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C50BA6B000D; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0029.hostedemail.com [216.40.44.29])
	by kanga.kvack.org (Postfix) with ESMTP id 717556B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 235C78248AB3
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:41 +0000 (UTC)
X-FDA: 75842860842.06.chain37_119559ddf484d
X-HE-Tag: chain37_119559ddf484d
X-Filterd-Recvd-Size: 2388
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0EACAC50;
	Tue, 20 Aug 2019 13:18:38 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 0/4] debug_pagealloc improvements through page_owner
Date: Tue, 20 Aug 2019 15:18:24 +0200
Message-Id: <20190820131828.22684-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.0
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v2: also fix THP split handling (added Patch 1) per Kirill

The debug_pagealloc functionality serves a similar purpose on the page
allocator level that slub_debug does on the kmalloc level, which is to de=
tect
bad users. One notable feature that slub_debug has is storing stack trace=
s of
who last allocated and freed the object. On page level we track allocatio=
ns via
page_owner, but that info is discarded when freeing, and we don't track f=
reeing
at all. This series improves those aspects. With both debug_pagealloc and
page_owner enabled, we can then get bug reports such as the example in Pa=
tch 4.

SLUB debug tracking additionaly stores cpu, pid and timestamp. This could=
 be
added later, if deemed useful enough to justify the additional page_ext
structure size.

Vlastimil Babka (4):
  mm, page_owner: handle THP splits correctly
  mm, page_owner: record page owner for each subpage
  mm, page_owner: keep owner info when freeing the page
  mm, page_owner, debug_pagealloc: save and dump freeing stack trace

 .../admin-guide/kernel-parameters.txt         |   2 +
 include/linux/page_ext.h                      |   1 +
 mm/Kconfig.debug                              |   4 +-
 mm/huge_memory.c                              |   4 +
 mm/page_owner.c                               | 123 +++++++++++++-----
 5 files changed, 100 insertions(+), 34 deletions(-)

--=20
2.22.0


