Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B893BC3A59B
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 429BF21874
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NMXv/Hkl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 429BF21874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 884A56B0003; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8351D6B0006; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 722FA6B0007; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0251.hostedemail.com [216.40.44.251])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDB96B0003
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:24:11 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id DF599824CA27
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:10 +0000 (UTC)
X-FDA: 75889444260.03.apple40_246dc9c566f0d
X-HE-Tag: apple40_246dc9c566f0d
X-Filterd-Recvd-Size: 12179
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:10 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829No4B102322;
	Mon, 2 Sep 2019 09:23:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2019-08-05;
 bh=CvxGa17zlrewWtTiiXNio45lgb3xu2E1GkqKPweuYWI=;
 b=NMXv/HklJi1nCAAX0lN/21cevOjOfy9LqWLeZ64imHNjuh2+B8CxpMxOywzg05PnHfHe
 x6oJsDun/lc3G9MHccW8BbX/9JL12cRN7qYORvBnbNn2v/RIYVaS18GxCqCWzYKbu50q
 r7L/iKIWqJBWDhHwz55gFflRvt2nXXrrx+pRS/LXo2cqQyuv1wMrmb3Mo5NgkMQ/NgsH
 f/+4eTlPGNE6QzUmfrRjHM9RAdgt17vfYs042QEDwhExw+hqnlNItMdrTMx725UVw0L4
 GqVUDt1tUNceSHRcrhxZ34DmuDpxm3bcFRFGqcy5EbTMCLeIZ7El50hm25OyF6JFPhew hg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2us0b4010n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:55 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829NNP7080397;
	Mon, 2 Sep 2019 09:23:55 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2uqg82wtg2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:55 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x829NotB010894;
	Mon, 2 Sep 2019 09:23:50 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 02 Sep 2019 02:23:50 -0700
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
Subject: [PATCH v5 1/2] mm: Allow the page cache to allocate large pages
Date: Mon,  2 Sep 2019 03:23:40 -0600
Message-Id: <20190902092341.26712-2-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190902092341.26712-1-william.kucharski@oracle.com>
References: <20190902092341.26712-1-william.kucharski@oracle.com>
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909020107
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909020107
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
index 139b4e3cc946..ca8f8e77e012 100644
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
index b3c8b886bf64..7c1c3857fbb9 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1708,7 +1708,7 @@ int ceph_uninline_data(struct file *filp, struct pa=
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


