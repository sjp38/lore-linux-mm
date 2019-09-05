Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CAE2C43331
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:24:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF98A2070C
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 18:24:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ru0grhHm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF98A2070C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3ED16B0007; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBCA56B000D; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF8C46B000A; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0057.hostedemail.com [216.40.44.57])
	by kanga.kvack.org (Postfix) with ESMTP id 9A2D36B0008
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:23:55 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 3285E180AD801
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:55 +0000 (UTC)
X-FDA: 75901690830.19.cub72_797b8b81b9424
X-HE-Tag: cub72_797b8b81b9424
X-Filterd-Recvd-Size: 4649
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 18:23:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Wv/nfVfHUcEEwLwvWDB143BDF1cy+chJvZKm5OI/UQ0=; b=ru0grhHmHVJaHFm/ZEKyOlN78+
	X3yojMPGb2MTakkInNd8Gs0vdgmL5sdIz7ZAQt2XmZcvCvMva8YL9nqPANMRw6WgXm6W3z3zR16mC
	sHw+e8qWOYBHMAw6Q/qoY87ISI0H0ZkWh0QmlEKtsJ3i67Non71xJ9cppIhuHwm44QAR9z7qiJ4G8
	2UzSSL9xeg3flYfjVOuu06ZRhCfiVtqG611OK0rAKQn5rDQiL591OtBu3vacSCVzir3K2JzHZfv/J
	bL+4/HrdMaifmK44Q7+WUUe5vsFDO7Feubh2w6R069zPYE/yNXn5zgBcM/Wt4wnE3dvhvTQIExukq
	2rPa1FXA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5wQA-0001UQ-N1; Thu, 05 Sep 2019 18:23:50 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Kirill Shutemov <kirill@shutemov.name>,
	Song Liu <songliubraving@fb.com>,
	William Kucharski <william.kucharski@oracle.com>,
	Johannes Weiner <jweiner@fb.com>
Subject: [PATCH 2/3] mm: Allow large pages to be added to the page cache
Date: Thu,  5 Sep 2019 11:23:47 -0700
Message-Id: <20190905182348.5319-3-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190905182348.5319-1-willy@infradead.org>
References: <20190905182348.5319-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

We return -EEXIST if there are any non-shadow entries in the page
cache in the range covered by the large page.  If there are multiple
shadow entries in the range, we set *shadowp to one of them (currently
the one at the highest index).  If that turns out to be the wrong
answer, we can implement something more complex.  This is mostly
modelled after the equivalent function in the shmem code.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 mm/filemap.c | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 041c77c4ca56..ae3c0a70a8e9 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -850,6 +850,7 @@ static int __add_to_page_cache_locked(struct page *pa=
ge,
 	int huge =3D PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
+	unsigned int nr =3D 1;
 	void *old;
=20
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -861,31 +862,47 @@ static int __add_to_page_cache_locked(struct page *=
page,
 					      gfp_mask, &memcg, false);
 		if (error)
 			return error;
+		xas_set_order(&xas, offset, compound_order(page));
+		nr =3D compound_nr(page);
 	}
=20
-	get_page(page);
+	page_ref_add(page, nr);
 	page->mapping =3D mapping;
 	page->index =3D offset;
=20
 	do {
+		unsigned long exceptional =3D 0;
+		unsigned int i =3D 0;
+
 		xas_lock_irq(&xas);
-		old =3D xas_load(&xas);
-		if (old && !xa_is_value(old))
+		xas_for_each_conflict(&xas, old) {
+			if (!xa_is_value(old))
+				break;
+			exceptional++;
+			if (shadowp)
+				*shadowp =3D old;
+		}
+		if (old) {
 			xas_set_err(&xas, -EEXIST);
-		xas_store(&xas, page);
+			break;
+		}
+		xas_create_range(&xas);
 		if (xas_error(&xas))
 			goto unlock;
=20
-		if (xa_is_value(old)) {
-			mapping->nrexceptional--;
-			if (shadowp)
-				*shadowp =3D old;
+next:
+		xas_store(&xas, page);
+		if (++i < nr) {
+			xas_next(&xas);
+			goto next;
 		}
-		mapping->nrpages++;
+		mapping->nrexceptional -=3D exceptional;
+		mapping->nrpages +=3D nr;
=20
 		/* hugetlb pages do not participate in page cache accounting */
 		if (!huge)
-			__inc_node_page_state(page, NR_FILE_PAGES);
+			__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES,
+						nr);
 unlock:
 		xas_unlock_irq(&xas);
 	} while (xas_nomem(&xas, gfp_mask & GFP_RECLAIM_MASK));
@@ -902,7 +919,7 @@ static int __add_to_page_cache_locked(struct page *pa=
ge,
 	/* Leave page->index set: truncation relies upon it */
 	if (!huge)
 		mem_cgroup_cancel_charge(page, memcg, false);
-	put_page(page);
+	page_ref_sub(page, nr);
 	return xas_error(&xas);
 }
 ALLOW_ERROR_INJECTION(__add_to_page_cache_locked, ERRNO);
--=20
2.23.0.rc1


