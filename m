Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E3BFC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:25:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C83032067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:25:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="0Tyhf08s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C83032067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64EC58E0003; Wed, 31 Jul 2019 04:25:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D8E38E0001; Wed, 31 Jul 2019 04:25:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42B228E0003; Wed, 31 Jul 2019 04:25:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D18F8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:25:32 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so74520042ioj.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:25:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dlm4IMwcu1FxVIA0+SVfFtkrho7IgF1gzVMbTPsccNA=;
        b=F7njZDYLyydW52KW8o0FzUQLv5heKUbDy/c044uOMxthn5on8cNjJC7Z6hYaQTTZqj
         t+H7NC3o6XbSUDofx5tbL6b7P9OGOJZ//WCbyqMzMhjiQgx7xtCcVN/0z5F2gg9u/Ly1
         XWaBRWqIn+qTTCM0tSP78wGyVyRTHF+nyjFUtbjjUvbV8tS4z5V7/X2PUtcubEV5ZEmG
         WLZ3dbFS0PnvEQycWxemwKQx0Ug4fTcx3y11Okbpv8SqD8prdQn/MO7/U5arEUlL1S59
         SCrvIV4gBuILjy+SXtoJWQdf1AdPwOa9OnuMVmgxxVLPPqhsktgbvRLgDMGlzMsqd+y9
         ydsQ==
X-Gm-Message-State: APjAAAWlrBBaZmdisqTjRadbyqMzntKBDsqMpsyJTNPOd65Qfl9qjlpC
	MARvf51fuGcbyeU4o+Qu886uR45BMpu6P2NF7a036rPVa+W/mMeS006lAfihSekiUztHY/BE4Tm
	75x2iC9AkL68h/V2WsllGT3ZmoizMkPz2BRgOQnyfiz/vw+33+2iZTs8STLPB6vtN3A==
X-Received: by 2002:a02:300b:: with SMTP id q11mr126665027jaq.54.1564561531733;
        Wed, 31 Jul 2019 01:25:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAeulpTJRcKYzrS1F4RV9Ln3yGyiLaV+L77f676BhT+3tELGlSJP0g7iM6XXeRNlgBHfPc
X-Received: by 2002:a02:300b:: with SMTP id q11mr126664959jaq.54.1564561530671;
        Wed, 31 Jul 2019 01:25:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564561530; cv=none;
        d=google.com; s=arc-20160816;
        b=o6HEjpYwFWw7SUrzP47fYULSo2rovUebevzUaORyxY1c0z09h31o8L710NUA3pA/ps
         uD4h5G3KT5hQ4hGowjuLQ7tCwVrYKHcgpcqzG9kg6wYlvOsAmhhzIgPk5JyUK/2pBctc
         DjJB0Y/4cmyXWF9kQJoAf3B2xryvY/RzC/5adG9UDBtICBSDSAMcqKZwORQf+0APrEJx
         Ro+rjLtAQqs9h2SJT2SG0qKRktXUpO+/xSuBpmVyTH/9+AaXVd7Upv3J2Qlkv5lMPaq+
         vtPc3sWsR6CVDdwLQ6rUuTbIPmOjaTccvqu7Ci9Vehs9VFDhzJEMk287JCxRHudIx0ud
         dCGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=dlm4IMwcu1FxVIA0+SVfFtkrho7IgF1gzVMbTPsccNA=;
        b=wKohz63BXmMnZX1WHn74WEbjWQaIjjTV19XCTfFKbFJMGwMSGsabSsoD8Y02l7jmpx
         iYVXm4tSr74iGCrUG/uDEYzVdvEKWWZ1XudMG3Q4bQQ9sMl+G4pdqb5t+eKxXmgXkSLe
         EUAJTf0/55S/rN+BbtNb2TnQlstOmwXMeDv3xfyQ7jjD7oV9n7KuxqQ3U2IeLxWbOkqP
         If3d9wiL81MQYqkJrN8IlFh81V6q+yYqkkJPPjG7SZ/6PW4YqQ20l3dQqF6PQEtVGD1C
         hMg9SVdKqpinId++Jnpm7PACQi8Dih0yoSyUQpN/Z4BXLmhRG0rRDELQXdPqx0/ufpoE
         OmyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0Tyhf08s;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id d71si84630766jab.10.2019.07.31.01.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 01:25:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=0Tyhf08s;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V8O2OZ081019;
	Wed, 31 Jul 2019 08:25:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=dlm4IMwcu1FxVIA0+SVfFtkrho7IgF1gzVMbTPsccNA=;
 b=0Tyhf08sDxHfFqR5eUvZZxU/u4DZaRv+45gln6nhEolTGpppd3/mRKCInkYQ3fj77IaG
 l0zTcEBwWqrQQvgV7yicefbvYINvmJHAJwtXQvyOsrxaCMXt5YHUTCm6aQWSJgPwzyla
 6uekQ3udyiCB8y+bAJA/moMQFAooTyovgXOuqTStkeOG+rW5iWkue7AX2syiM3inYLjE
 zdfxMM03fn+zFfb0c8rbs5s52tejfvkKd8SPRYZCAbUWuGAqW1uHu6/1gOvyUUAbq7B0
 sTTmImGapTR6aurhTv+WPsVoms5nciunVr+pYADqaiZOtTDQnP38tvUbwmDflWiofhW6 ww== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2u0ejpkkud-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 08:25:23 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V8Mtim055648;
	Wed, 31 Jul 2019 08:25:22 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2u2exbbmhf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 08:25:22 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6V8PKoD008120;
	Wed, 31 Jul 2019 08:25:20 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 31 Jul 2019 01:25:20 -0700
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
Subject: [PATCH v3 1/2] mm: Allow the page cache to allocate large pages
Date: Wed, 31 Jul 2019 02:25:12 -0600
Message-Id: <20190731082513.16957-2-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731082513.16957-1-william.kucharski@oracle.com>
References: <20190731082513.16957-1-william.kucharski@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907310090
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907310090
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
@@ -274,7 +274,7 @@ static struct afs_read *afs_read_dir(struct afs_vnode *dvnode, struct key *key)
 				afs_stat_v(dvnode, n_inval);
 
 			ret = -ENOMEM;
-			req->pages[i] = __page_cache_alloc(gfp);
+			req->pages[i] = __page_cache_alloc(gfp, 0);
 			if (!req->pages[i])
 				goto error;
 			ret = add_to_page_cache_lru(req->pages[i],
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 60c47b417a4b..5280e7477b7e 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -466,7 +466,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		}
 
 		page = __page_cache_alloc(mapping_gfp_constraint(mapping,
-								 ~__GFP_FS));
+								 ~__GFP_FS), 0);
 		if (!page)
 			break;
 
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 44a3ce1e4ce4..11d30212745f 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -259,7 +259,7 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 			goto backing_page_already_present;
 
 		if (!newpage) {
-			newpage = __page_cache_alloc(cachefiles_gfp);
+			newpage = __page_cache_alloc(cachefiles_gfp, 0);
 			if (!newpage)
 				goto nomem_monitor;
 		}
@@ -495,7 +495,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 				goto backing_page_already_present;
 
 			if (!newpage) {
-				newpage = __page_cache_alloc(cachefiles_gfp);
+				newpage = __page_cache_alloc(cachefiles_gfp, 0);
 				if (!newpage)
 					goto nomem;
 			}
diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
index e078cc55b989..bcb41fbee533 100644
--- a/fs/ceph/addr.c
+++ b/fs/ceph/addr.c
@@ -1707,7 +1707,7 @@ int ceph_uninline_data(struct file *filp, struct page *locked_page)
 		if (len > PAGE_SIZE)
 			len = PAGE_SIZE;
 	} else {
-		page = __page_cache_alloc(GFP_NOFS);
+		page = __page_cache_alloc(GFP_NOFS, 0);
 		if (!page) {
 			err = -ENOMEM;
 			goto out;
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 685a03cc4b77..ae58d7c31aa4 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -1305,7 +1305,7 @@ static ssize_t ceph_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		struct page *page = NULL;
 		loff_t i_size;
 		if (retry_op == READ_INLINE) {
-			page = __page_cache_alloc(GFP_KERNEL);
+			page = __page_cache_alloc(GFP_KERNEL, 0);
 			if (!page)
 				return -ENOMEM;
 		}
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c7552459a15f..92e026d9a6b7 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -208,17 +208,19 @@ static inline int page_cache_add_speculative(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp, unsigned int order);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp, unsigned int order)
 {
-	return alloc_pages(gfp, 0);
+	if (order > 0)
+		gfp |= __GFP_COMP;
+	return alloc_pages(gfp, order);
 }
 #endif
 
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x), 0);
 }
 
 static inline gfp_t readahead_gfp_mask(struct address_space *x)
diff --git a/mm/filemap.c b/mm/filemap.c
index d0cf700bf201..38b46fc00855 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -954,22 +954,25 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, unsigned int order)
 {
 	int n;
 	struct page *page;
 
+	if (order > 0)
+		gfp |= __GFP_COMP;
+
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
 			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
-			page = __alloc_pages_node(n, gfp, 0);
+			page = __alloc_pages_node(n, gfp, order);
 		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -1665,7 +1668,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		if (fgp_flags & FGP_NOFS)
 			gfp_mask &= ~__GFP_FS;
 
-		page = __page_cache_alloc(gfp_mask);
+		page = __page_cache_alloc(gfp_mask, 0);
 		if (!page)
 			return NULL;
 
@@ -2802,15 +2805,14 @@ static struct page *wait_on_page_read(struct page *page)
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
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp);
+		page = __page_cache_alloc(gfp, order);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
@@ -2917,7 +2919,7 @@ struct page *read_cache_page(struct address_space *mapping,
 				int (*filler)(void *, struct page *),
 				void *data)
 {
-	return do_read_cache_page(mapping, index, filler, data,
+	return do_read_cache_page(mapping, index, filler, data, 0,
 			mapping_gfp_mask(mapping));
 }
 EXPORT_SYMBOL(read_cache_page);
@@ -2939,7 +2941,7 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index,
 				gfp_t gfp)
 {
-	return do_read_cache_page(mapping, index, NULL, NULL, gfp);
+	return do_read_cache_page(mapping, index, NULL, NULL, 0, gfp);
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
diff --git a/mm/readahead.c b/mm/readahead.c
index 2fe72cd29b47..954760a612ea 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -193,7 +193,7 @@ unsigned int __do_page_cache_readahead(struct address_space *mapping,
 			continue;
 		}
 
-		page = __page_cache_alloc(gfp_mask);
+		page = __page_cache_alloc(gfp_mask, 0);
 		if (!page)
 			break;
 		page->index = page_offset;
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 65e34f78b05d..0c3face908dc 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -56,7 +56,7 @@ static int ceph_pagelist_addpage(struct ceph_pagelist *pl)
 	struct page *page;
 
 	if (!pl->num_pages_free) {
-		page = __page_cache_alloc(GFP_NOFS);
+		page = __page_cache_alloc(GFP_NOFS, 0);
 	} else {
 		page = list_first_entry(&pl->free_list, struct page, lru);
 		list_del(&page->lru);
@@ -107,7 +107,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 	space = (space + PAGE_SIZE - 1) >> PAGE_SHIFT;   /* conv to num pages */
 
 	while (space > pl->num_pages_free) {
-		struct page *page = __page_cache_alloc(GFP_NOFS);
+		struct page *page = __page_cache_alloc(GFP_NOFS, 0);
 		if (!page)
 			return -ENOMEM;
 		list_add_tail(&page->lru, &pl->free_list);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 64305e7056a1..1d07e639216d 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -45,7 +45,7 @@ struct page **ceph_alloc_page_vector(int num_pages, gfp_t flags)
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < num_pages; i++) {
-		pages[i] = __page_cache_alloc(flags);
+		pages[i] = __page_cache_alloc(flags, 0);
 		if (pages[i] == NULL) {
 			ceph_release_page_vector(pages, i);
 			return ERR_PTR(-ENOMEM);
-- 
2.21.0

