Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B4FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF5D12070D
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 09:42:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF5D12070D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54C988E0003; Thu, 14 Mar 2019 05:42:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FB658E0001; Thu, 14 Mar 2019 05:42:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ECF28E0003; Thu, 14 Mar 2019 05:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D76A08E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 05:42:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y11so2128135edj.20
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 02:42:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=XKDQOyCPg4u3u4gHck04KVDpyJl+PZP4FLQMdNPpRD0=;
        b=N0QCUSDbbE1f2kMog67F2Cu9Mw2uNbmstRknjtf5au2Uby0K9cObiJXE/fesfFt/Rd
         32F1aI5NuW4UqwHdM4rktB1WlfaScxyjC2UiJVS+/MMsOBQj5pjy61NmjdgmAlYKCcfh
         rLsDZwNbYSraC11TO90YFCElJ3XIlNKHyQjbaHVgsS02anvk0ENZYIe0T69pWFuCXoIz
         YluNP6oYAJSwa+8pD+0ohucWqBzCBz7N2wgiK3VPVr8a2Pb/2CWwM7yBoqsRWnzYvY8K
         ob6R6Kf1+GAZB5W84RUNwNkfGIVpsSPiPqcBZtvsgPDy8FEGaDgtsOa4tVT9J9ZUZpsw
         Av7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUcJfZ7UhDaxCFd8ECbK9s5HXYJ/ablF2QORHGAgh/5LER8nIjp
	R36FHWO/l4H5kEc1vxC8R4huImJPlLydu2nHma6C97M0nQPBjI8v0JEqOnt/zEuNnLibau6+dQu
	i4DjHw4jDa4N84FbzYyqOMVQ6XRAdqY5bW/LX8D25DhxlURS/YOIJhuzCMX/xaXeFKg==
X-Received: by 2002:a50:c9c9:: with SMTP id c9mr9100504edi.96.1552556577429;
        Thu, 14 Mar 2019 02:42:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgDZvH95n7IH+V200ZlPtjutLO5UOC3uHpVa00b7LB5Wyw/kyED1yClg0B1h0alyKTVu9W
X-Received: by 2002:a50:c9c9:: with SMTP id c9mr9100453edi.96.1552556576532;
        Thu, 14 Mar 2019 02:42:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552556576; cv=none;
        d=google.com; s=arc-20160816;
        b=lkA2Kzc4W/llxgKnvb3nmpPYRxuUZtjVI2oEUqajU2t6Hl5O03b/uxws40nelU77Bz
         KW0UpZT97kjKLMZ5ibG2SG/ynsFKGeANxOLUQUgGBjEQbw0hoigMSvPILBOViYW95pBq
         0btTlNFtXiCk3vDaRNxO7SRt64KdT9RkoQWuiePoDmgin5VKP0JGKhQ8uRjQZfVFK2Ym
         nFyjzcjFdJjxnKgXaMEbq0M3fNcPfntDKZ+9fzaAG+3jacSxGLFAhcY5/uP2k1Ax+ZHU
         MFileIMFcuKp6oktPBa5pFlT7xXz+eJ9cm9MAzqAKOjXfdGey9QZ+JI0q6VffEGG6uo7
         fZ3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=XKDQOyCPg4u3u4gHck04KVDpyJl+PZP4FLQMdNPpRD0=;
        b=asPKdpRSslQMrKbycIW+H2wpWTyYzBYrySxtOlXaFjDIlz7Y30/hhMB/wwnpi6eetb
         cIJpk8phJdwwqp0GFkkC8Sk+9eYUkX3wuOIuyeAbZLQoebrYdbBZycew0auDtTYcFUqQ
         c2rFH13R3qUk43THhGPHY7CzWxkBdaNxBXEZAEAiqsNf+BfEXvUOeL4nvTPnTpTOvbbS
         4gVxmVObiyYdnVW9p+v5lPRUuVLmpstVHvF1zg3lvfKdsxFe/N5ckf59mRB3WVfsI2Rr
         1bRZ0o67mDVTu5/9bBkOYW02Q+cQzdjpKrJQcuh05BiKXe3YGmwF8nqgNKwx0KIx/fs7
         /0dA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b5si1823628edc.26.2019.03.14.02.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 02:42:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B6E6CAFA8;
	Thu, 14 Mar 2019 09:42:55 +0000 (UTC)
From: Vlastimil Babka <vbabka@suse.cz>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Takashi Iwai <tiwai@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2] mm, page_alloc: disallow __GFP_COMP in alloc_pages_exact()
Date: Thu, 14 Mar 2019 10:42:49 +0100
Message-Id: <20190314094249.19606-1-vbabka@suse.cz>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190314093944.19406-1-vbabka@suse.cz>
References: <20190314093944.19406-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_pages_exact*() allocates a page of sufficient order and then splits it
to return only the number of pages requested. That makes it incompatible with
__GFP_COMP, because compound pages cannot be split.

As shown by [1] things may silently work until the requested size (possibly
depending on user) stops being power of two. Then for CONFIG_DEBUG_VM, BUG_ON()
triggers in split_page(). Without CONFIG_DEBUG_VM, consequences are unclear.

There are several options here, none of them great:

1) Don't do the spliting when __GFP_COMP is passed, and return the whole
compound page. However if caller then returns it via free_pages_exact(),
that will be unexpected and the freeing actions there will be wrong.

2) Warn and remove __GFP_COMP from the flags. But the caller wanted it, so
things may break later somewhere.

3) Warn and return NULL. However NULL may be unexpected, especially for
small sizes.

This patch picks option 3, as it's best defined.

[1] https://lore.kernel.org/lkml/20181126002805.GI18977@shao2-debian/T/#u

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
Sent v1 before amending commit, sorry.

 mm/page_alloc.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b9f577b1a2a..dd3f89e8f88d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4752,7 +4752,7 @@ static void *make_alloc_exact(unsigned long addr, unsigned int order,
 /**
  * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation
+ * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
  * This function is similar to alloc_pages(), except that it allocates the
  * minimum number of pages to satisfy the request.  alloc_pages() can only
@@ -4768,6 +4768,10 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	unsigned long addr;
 
 	addr = __get_free_pages(gfp_mask, order);
+
+	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
+		return NULL;
+
 	return make_alloc_exact(addr, order, size);
 }
 EXPORT_SYMBOL(alloc_pages_exact);
@@ -4777,7 +4781,7 @@ EXPORT_SYMBOL(alloc_pages_exact);
  *			   pages on a node.
  * @nid: the preferred node ID where memory should be allocated
  * @size: the number of bytes to allocate
- * @gfp_mask: GFP flags for the allocation
+ * @gfp_mask: GFP flags for the allocation, must not contain __GFP_COMP
  *
  * Like alloc_pages_exact(), but try to allocate on node nid first before falling
  * back.
@@ -4785,7 +4789,12 @@ EXPORT_SYMBOL(alloc_pages_exact);
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask)
 {
 	unsigned int order = get_order(size);
-	struct page *p = alloc_pages_node(nid, gfp_mask, order);
+	struct page *p;
+
+	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
+		return NULL;
+
+	p = alloc_pages_node(nid, gfp_mask, order);
 	if (!p)
 		return NULL;
 	return make_alloc_exact((unsigned long)page_address(p), order, size);
-- 
2.20.1

