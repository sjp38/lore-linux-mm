Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13C0EC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D193C22DBF
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D193C22DBF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 812856B000C; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794CD6B0010; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664FA6B000E; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0199.hostedemail.com [216.40.44.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4215A6B000A
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id E996D8248AB1
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:40 +0000 (UTC)
X-FDA: 75842860800.09.wash16_118cff25a3222
X-HE-Tag: wash16_118cff25a3222
X-Filterd-Recvd-Size: 2484
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0C75ABD0;
	Tue, 20 Aug 2019 13:18:38 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	stable@vger.kernel.org
Subject: [PATCH v2 1/4] mm, page_owner: handle THP splits correctly
Date: Tue, 20 Aug 2019 15:18:25 +0200
Message-Id: <20190820131828.22684-2-vbabka@suse.cz>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190820131828.22684-1-vbabka@suse.cz>
References: <20190820131828.22684-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

THP splitting path is missing the split_page_owner() call that split_page=
()
has. As a result, split THP pages are wrongly reported in the page_owner =
file
as order-9 pages. Furthermore when the former head page is freed, the rem=
aining
former tail pages are not listed in the page_owner file at all. This patc=
h
fixes that by adding the split_page_owner() call into __split_huge_page()=
.

Fixes: a9627bc5e34e ("mm/page_owner: introduce split_page_owner and repla=
ce manual handling")
Reported-by: Kirill A. Shutemov <kirill@shutemov.name>
Cc: stable@vger.kernel.org
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/huge_memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 738065f765ab..de1f15969e27 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -32,6 +32,7 @@
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
 #include <linux/numa.h>
+#include <linux/page_owner.h>
=20
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2516,6 +2517,9 @@ static void __split_huge_page(struct page *page, st=
ruct list_head *list,
 	}
=20
 	ClearPageCompound(head);
+
+	split_page_owner(head, HPAGE_PMD_ORDER);
+
 	/* See comment in __split_huge_page_tail() */
 	if (PageAnon(head)) {
 		/* Additional pin to swap cache */
--=20
2.22.0


