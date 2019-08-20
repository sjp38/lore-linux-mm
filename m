Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4881AC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17F3D22DD3
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:18:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17F3D22DD3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C53FF6B026A; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3E056B026B; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 807EE6B000D; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0221.hostedemail.com [216.40.44.221])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3296B000C
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:18:41 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0410C181AC9C4
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:41 +0000 (UTC)
X-FDA: 75842860842.01.river76_118b2b1800c39
X-HE-Tag: river76_118b2b1800c39
X-Filterd-Recvd-Size: 4873
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:18:40 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DA972AC8E;
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
Subject: [PATCH v2 2/4] mm, page_owner: record page owner for each subpage
Date: Tue, 20 Aug 2019 15:18:26 +0200
Message-Id: <20190820131828.22684-3-vbabka@suse.cz>
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

Currently, page owner info is only recorded for the first page of a high-=
order
allocation, and copied to tail pages in the event of a split page. With t=
he
plan to keep previous owner info after freeing the page, it would be bene=
fical
to record page owner for each subpage upon allocation. This increases the
overhead for high orders, but that should be acceptable for a debugging o=
ption.

The order stored for each subpage is the order of the whole allocation. T=
his
makes it possible to calculate the "head" pfn and to recognize "tail" pag=
es
(quoted because not all high-order allocations are compound pages with tr=
ue
head and tail pages). When reading the page_owner debugfs file, keep skip=
ping
the "tail" pages so that stats gathered by existing scripts don't get inf=
lated.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_owner.c | 40 ++++++++++++++++++++++++++++------------
 1 file changed, 28 insertions(+), 12 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index addcbb2ae4e4..813fcb70547b 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -154,18 +154,23 @@ static noinline depot_stack_handle_t save_stack(gfp=
_t flags)
 	return handle;
 }
=20
-static inline void __set_page_owner_handle(struct page_ext *page_ext,
-	depot_stack_handle_t handle, unsigned int order, gfp_t gfp_mask)
+static inline void __set_page_owner_handle(struct page *page,
+	struct page_ext *page_ext, depot_stack_handle_t handle,
+	unsigned int order, gfp_t gfp_mask)
 {
 	struct page_owner *page_owner;
+	int i;
=20
-	page_owner =3D get_page_owner(page_ext);
-	page_owner->handle =3D handle;
-	page_owner->order =3D order;
-	page_owner->gfp_mask =3D gfp_mask;
-	page_owner->last_migrate_reason =3D -1;
+	for (i =3D 0; i < (1 << order); i++) {
+		page_owner =3D get_page_owner(page_ext);
+		page_owner->handle =3D handle;
+		page_owner->order =3D order;
+		page_owner->gfp_mask =3D gfp_mask;
+		page_owner->last_migrate_reason =3D -1;
+		__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
=20
-	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
+		page_ext =3D lookup_page_ext(page + i);
+	}
 }
=20
 noinline void __set_page_owner(struct page *page, unsigned int order,
@@ -178,7 +183,7 @@ noinline void __set_page_owner(struct page *page, uns=
igned int order,
 		return;
=20
 	handle =3D save_stack(gfp_mask);
-	__set_page_owner_handle(page_ext, handle, order, gfp_mask);
+	__set_page_owner_handle(page, page_ext, handle, order, gfp_mask);
 }
=20
 void __set_page_owner_migrate_reason(struct page *page, int reason)
@@ -204,8 +209,11 @@ void __split_page_owner(struct page *page, unsigned =
int order)
=20
 	page_owner =3D get_page_owner(page_ext);
 	page_owner->order =3D 0;
-	for (i =3D 1; i < (1 << order); i++)
-		__copy_page_owner(page, page + i);
+	for (i =3D 1; i < (1 << order); i++) {
+		page_ext =3D lookup_page_ext(page + i);
+		page_owner =3D get_page_owner(page_ext);
+		page_owner->order =3D 0;
+	}
 }
=20
 void __copy_page_owner(struct page *oldpage, struct page *newpage)
@@ -483,6 +491,13 @@ read_page_owner(struct file *file, char __user *buf,=
 size_t count, loff_t *ppos)
=20
 		page_owner =3D get_page_owner(page_ext);
=20
+		/*
+		 * Don't print "tail" pages of high-order allocations as that
+		 * would inflate the stats.
+		 */
+		if (!IS_ALIGNED(pfn, 1 << page_owner->order))
+			continue;
+
 		/*
 		 * Access to page_ext->handle isn't synchronous so we should
 		 * be careful to access it.
@@ -562,7 +577,8 @@ static void init_pages_in_zone(pg_data_t *pgdat, stru=
ct zone *zone)
 				continue;
=20
 			/* Found early allocated page */
-			__set_page_owner_handle(page_ext, early_handle, 0, 0);
+			__set_page_owner_handle(page, page_ext, early_handle,
+						0, 0);
 			count++;
 		}
 		cond_resched();
--=20
2.22.0


