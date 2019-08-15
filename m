Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6799CC31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 05:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0791A2086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 05:44:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="apltKDRH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0791A2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80A726B0007; Thu, 15 Aug 2019 01:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7918A6B0003; Thu, 15 Aug 2019 01:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 631DD6B0008; Thu, 15 Aug 2019 01:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0170.hostedemail.com [216.40.44.170])
	by kanga.kvack.org (Postfix) with ESMTP id 389656B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 01:44:58 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DBE4C8248AA5
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:44:57 +0000 (UTC)
X-FDA: 75823573434.17.shoes46_829454f0df528
X-HE-Tag: shoes46_829454f0df528
X-Filterd-Recvd-Size: 12183
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:44:57 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7F5ifAn081332;
	Thu, 15 Aug 2019 05:44:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=dlm4IMwcu1FxVIA0+SVfFtkrho7IgF1gzVMbTPsccNA=;
 b=apltKDRHXbR6SjdIAugb6+hjqJG3BA9FJtr/TI//MrOJJ4iwhfdGTQz1Z5g91fN3gqpP
 JaAMlIh8dximND8sW8H6OeJ6rF3ZcM1eKWFrBrZFxb2jFeq842191nc5WSykjycDRCl0
 VrWS5W3XX4sz7xHlgf3XkKyQeF94c7mNKlEXn/CP3YX++2otJXlTjx6632MJgeQXIvtS
 LN9rzQjNhoFrPNa6UJSaQES4rf6Br+YIzXAo15W/bkRxDT+v/gUBxt7roDx3ozG7WbTi
 B7++Z3nGpqEcp1fWwykQMZWrPHczRvEWFxite6WYgOEKOoHMy7NPgLLQId/YJQaFvLS/ 6w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u9nvpgyau-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 05:44:41 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7F5iT8Q057426;
	Thu, 15 Aug 2019 05:44:41 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2ucpys17sn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 05:44:39 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7F5iNm7010837;
	Thu, 15 Aug 2019 05:44:23 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 14 Aug 2019 22:44:23 -0700
From: William Kucharski <william.kucharski@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        William Kucharski <william.kucharski@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 1/2] mm: Allow the page cache to allocate large pages
Date: Wed, 14 Aug 2019 23:44:11 -0600
Message-Id: <20190815054412.26713-2-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190815054412.26713-1-william.kucharski@oracle.com>
References: <20190815054412.26713-1-william.kucharski@oracle.com>
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908150059
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908150059
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add an 'order' argument to __page_cache_alloc() and
do_read_cache_page(). Ensure the allocated pages are compound pages.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Signed-off-by: William Kucharski <william.kucharski@oracle.com>
Reported-by: kbuild test robot <lkp@intel.com>
---
 fs/afs/dir.c            |  2 +-
 fs/btrfs/compression.c  |  2 +-
 fs/cachefiles/rdwr.c    |  4 ++--
 fs/ceph/addr.c          |  2 +-
 fs/ceph/file.c          |  2 +-
 include/linux/pagemap.h | 10 ++++++----
 mm/filemap.c            | 20 +++++++++++---------
 mm/readahead.c          |  2 +-
 net/ceph/pagelist.c     |  4 ++--
 net/ceph/pagevec.c      |  2 +-
 10 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index e640d67274be..0a392214f71e 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -274,7 +274,7 @@ static struct afs_read *afs_read_dir(struct afs_vnode=
 *dvnode, struct key *key)
 				afs_stat_v(dvnode, n_inval);
=20
 			ret =3D -ENOMEM;
-			req->pages[i] =3D __page_cache_alloc(gfp);
+			req->pages[i] =3D __page_cache_alloc(gfp, 0);
 			if (!req->pages[i])
 				goto error;
 			ret =3D add_to_page_cache_lru(req->pages[i],
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 60c47b417a4b..5280e7477b7e 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -466,7 +466,7 @@ static noinline int add_ra_bio_pages(struct inode *in=
ode,
 		}
=20
 		page =3D __page_cache_alloc(mapping_gfp_constraint(mapping,
-								 ~__GFP_FS));
+								 ~__GFP_FS), 0);
 		if (!page)
 			break;
=20
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 44a3ce1e4ce4..11d30212745f 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -259,7 +259,7 @@ static int cachefiles_read_backing_file_one(struct ca=
chefiles_object *object,
 			goto backing_page_already_present;
=20
 		if (!newpage) {
-			newpage =3D __page_cache_alloc(cachefiles_gfp);
+			newpage =3D __page_cache_alloc(cachefiles_gfp, 0);
 			if (!newpage)
 				goto nomem_monitor;
 		}
@@ -495,7 +495,7 @@ static int cachefiles_read_backing_file(struct cachef=
iles_object *object,
 				goto backing_page_already_present;
=20
 			if (!newpage) {
-				newpage =3D __page_cache_alloc(cachefiles_gfp);
+				newpage =3D __page_cache_alloc(cachefiles_gfp, 0);
 				if (!newpage)
 					goto nomem;
 			}
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index e078cc55b989..bcb41fbee533 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1707,7 +1707,7 @@ int ceph_uninline_data(struct file *filp, struct pa=
ge *locked_page)
 		if (len > PAGE_SIZE)
 			len =3D PAGE_SIZE;
 	} else {
-		page =3D __page_cache_alloc(GFP_NOFS);
+		page =3D __page_cache_alloc(GFP_NOFS, 0);
 		if (!page) {
 			err =3D -ENOMEM;
 			goto out;
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 685a03cc4b77..ae58d7c31aa4 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -1305,7 +1305,7 @@ static ssize_t ceph_read_iter(struct kiocb *iocb, s=
truct iov_iter *to)
 		struct page *page =3D NULL;
 		loff_t i_size;
 		if (retry_op =3D=3D READ_INLINE) {
-			page =3D __page_cache_alloc(GFP_KERNEL);
+			page =3D __page_cache_alloc(GFP_KERNEL, 0);
 			if (!page)
 				return -ENOMEM;
 		}
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c7552459a15f..92e026d9a6b7 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -208,17 +208,19 @@ static inline int page_cache_add_speculative(struct=
 page *page, int count)
 }
=20
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp, unsigned int order);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp, unsigned int or=
der)
 {
-	return alloc_pages(gfp, 0);
+	if (order > 0)
+		gfp |=3D __GFP_COMP;
+	return alloc_pages(gfp, order);
 }
 #endif
=20
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x), 0);
 }
=20
 static inline gfp_t readahead_gfp_mask(struct address_space *x)
diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..38b46fc00855 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -954,22 +954,25 @@ int add_to_page_cache_lru(struct page *page, struct=
 address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
=20
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
=20
+	if (order > 0)
+		gfp |=3D __GFP_COMP;
+
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
 			cpuset_mems_cookie =3D read_mems_allowed_begin();
 			n =3D cpuset_mem_spread_node();
-			page =3D __alloc_pages_node(n, gfp, 0);
+			page =3D __alloc_pages_node(n, gfp, order);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
=20
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -1665,7 +1668,7 @@ struct page *pagecache_get_page(struct address_spac=
e *mapping, pgoff_t offset,
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &=3D ~__GFP_FS;
=20
-		page =3D __page_cache_alloc(gfp_mask);
+		page =3D __page_cache_alloc(gfp_mask, 0);
 		if (!page)
 			return NULL;
=20
@@ -2802,15 +2805,14 @@ static struct page *wait_on_page_read(struct page=
 *page)
 static struct page *do_read_cache_page(struct address_space *mapping,
 				pgoff_t index,
 				int (*filler)(void *, struct page *),
-				void *data,
-				gfp_t gfp)
+				void *data, unsigned int order, gfp_t gfp)
 {
 	struct page *page;
 	int err;
 repeat:
 	page =3D find_get_page(mapping, index);
 	if (!page) {
-		page =3D __page_cache_alloc(gfp);
+		page =3D __page_cache_alloc(gfp, order);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err =3D add_to_page_cache_lru(page, mapping, index, gfp);
@@ -2917,7 +2919,7 @@ struct page *read_cache_page(struct address_space *=
mapping,
 				int (*filler)(void *, struct page *),
 				void *data)
 {
-	return do_read_cache_page(mapping, index, filler, data,
+	return do_read_cache_page(mapping, index, filler, data, 0,
 			mapping_gfp_mask(mapping));
 }
 EXPORT_SYMBOL(read_cache_page);
@@ -2939,7 +2941,7 @@ struct page *read_cache_page_gfp(struct address_spa=
ce *mapping,
 				pgoff_t index,
 				gfp_t gfp)
 {
-	return do_read_cache_page(mapping, index, NULL, NULL, gfp);
+	return do_read_cache_page(mapping, index, NULL, NULL, 0, gfp);
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
=20
diff --git a/mm/readahead.c b/mm/readahead.c
index 2fe72cd29b47..954760a612ea 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -193,7 +193,7 @@ unsigned int __do_page_cache_readahead(struct address=
_space *mapping,
 			continue;
 		}
=20
-		page =3D __page_cache_alloc(gfp_mask);
+		page =3D __page_cache_alloc(gfp_mask, 0);
 		if (!page)
 			break;
 		page->index =3D page_offset;
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 65e34f78b05d..0c3face908dc 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -56,7 +56,7 @@ static int ceph_pagelist_addpage(struct ceph_pagelist *=
pl)
 	struct page *page;
=20
 	if (!pl->num_pages_free) {
-		page =3D __page_cache_alloc(GFP_NOFS);
+		page =3D __page_cache_alloc(GFP_NOFS, 0);
 	} else {
 		page =3D list_first_entry(&pl->free_list, struct page, lru);
 		list_del(&page->lru);
@@ -107,7 +107,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, s=
ize_t space)
 	space =3D (space + PAGE_SIZE - 1) >> PAGE_SHIFT;   /* conv to num pages=
 */
=20
 	while (space > pl->num_pages_free) {
-		struct page *page =3D __page_cache_alloc(GFP_NOFS);
+		struct page *page =3D __page_cache_alloc(GFP_NOFS, 0);
 		if (!page)
 			return -ENOMEM;
 		list_add_tail(&page->lru, &pl->free_list);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 64305e7056a1..1d07e639216d 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -45,7 +45,7 @@ struct page **ceph_alloc_page_vector(int num_pages, gfp=
_t flags)
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	for (i =3D 0; i < num_pages; i++) {
-		pages[i] =3D __page_cache_alloc(flags);
+		pages[i] =3D __page_cache_alloc(flags, 0);
 		if (pages[i] =3D=3D NULL) {
 			ceph_release_page_vector(pages, i);
 			return ERR_PTR(-ENOMEM);
--=20
2.21.0


