Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CAC3C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 13B1820830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 09:02:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 13B1820830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4D946B0008; Tue, 26 Mar 2019 05:02:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD4DE6B000A; Tue, 26 Mar 2019 05:02:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ECE76B000C; Tue, 26 Mar 2019 05:02:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 743AD6B0008
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:02:44 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so12853831qty.12
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 02:02:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=7yUWtnQBiOqibJD3lCqD4KEusMHS1CkdLBfN5ckvauo=;
        b=frDdUQAXE6UMJ210oq+eRemneOhpn67hQ+K0pxwLtOgIn9zaI2rwyzqK8NnekNqA9N
         RjDTOy/2r8J/HaWRwDP28wO9azC2ZCfgyTGLAScuqoXgjKGPGVh8FHU0euE98v6F7JhE
         TrBP/MU0jkvIK/U4IgcUhZuc6MY/k5uOJIVM7ALOPSQDV6rSGHfe31DFpwdkdTt03haw
         qvCIlmS40YDQUZzst1MZGLEN4rAZ0N8MF3k1tDpB6ik3L8Dv1A+QiuQexOAh3lNafbbN
         lyrgxDhIETLBHXej4jJDBW+G/dkw7tVNiEeYZeNvoBfOmTniSIixNsiuTPT9mRZh+uPf
         RkSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWGNI0xfU+cuNKM6pDSvkw4tC1ItJ+bedwuHzi+1u34RvcyAfuT
	yfZkjWq4iFI9aShU0zp4gQpKsalLmcFtdjGQVwf06IthZ73styikoqMMtjTxlpjkYsnmMDjQeCo
	IF81ZfPXuSot3e+q3q3h8eNo4d25Wy/pQTlu9ppt7UkgEvqC7/c7uQLogsTPGBZHnSw==
X-Received: by 2002:ae9:dec2:: with SMTP id s185mr22321286qkf.107.1553590964273;
        Tue, 26 Mar 2019 02:02:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaqCGg86U0v8D4y4bjCSehWz2tCNvi30aT2Ql9ixduCRBnjmP0i/epFj9wG4pk6blodZ6n
X-Received: by 2002:ae9:dec2:: with SMTP id s185mr22321236qkf.107.1553590963569;
        Tue, 26 Mar 2019 02:02:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553590963; cv=none;
        d=google.com; s=arc-20160816;
        b=zjGj+xWZN2VsOPmpRWZW91+0UkIFjfxKtKA00RSWtAk+kbj8ZJXPOCFnu1K9/Up488
         zr059U+um7uQG/SgMF9LwGYj+pNnGxG29634an103dUX8WjhS4GHLhp+7QKSzZoH/rAf
         HJ4M41tpfRoUVqnyALJfDEDeIBS5eo+bz2DfqYdzKiNDbL+elbn3F0UijTWhe9EL9HJW
         kq8kiHZYt0FNczNgoSW7E7vT26koim9/ep+mvI4hy5t7ScmYgGqbMGpqsVvcju5wzkUh
         dHNJb4Rn2aRO6BSVvi9rytVvasiIJk2zybGp5cWIKARrKyO/Ss8TjbTjE4AdhkReAvik
         9Slg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=7yUWtnQBiOqibJD3lCqD4KEusMHS1CkdLBfN5ckvauo=;
        b=Fo4McRit/u+0YSZt9H6PRCbq1JWYyfL72HtmV5nE05ONEZxKRkZ4GsXWJ5sRf/15FC
         Vs9I7C2aTsB6lj1ffopxuJUMUqKykUJQnyiGfDx5fDFn66YpSWTMBCwaHK43hmo6rHHO
         s+5o5ld8dcuO7U0ae/SdZuJooASt/kLoo6AFSotNVtBronRjuhPiZ0rz8iD8mPB4977a
         wsZwN7csgO5TYwaZUcKEj/0IyXxMD+b1tI1jf9KtDJhlKzgFVrEyKOHPwthR9rp0ndgs
         rVJdkJjFGNBhPsrS1pVg96R5oIYPx1FjqApxOHypD14p+r+w0nTw1sMRMYOkR56sUS50
         cWFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h50si448638qvd.87.2019.03.26.02.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 02:02:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C1AF28762B;
	Tue, 26 Mar 2019 09:02:42 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D91EE80A3F;
	Tue, 26 Mar 2019 09:02:38 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	rppt@linux.ibm.com,
	osalvador@suse.de,
	willy@infradead.org,
	william.kucharski@oracle.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Date: Tue, 26 Mar 2019 17:02:25 +0800
Message-Id: <20190326090227.3059-3-bhe@redhat.com>
In-Reply-To: <20190326090227.3059-1-bhe@redhat.com>
References: <20190326090227.3059-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 26 Mar 2019 09:02:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Reorder the allocation of usemap and memmap since usemap allocation
is much simpler and easier. Otherwise hard work is done to make
memmap ready, then have to rollback just because of usemap allocation
failure.

And also check if section is present earlier. Then don't bother to
allocate usemap and memmap if yes.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
v1->v2:
  Do section existence checking earlier to further optimize code.

 mm/sparse.c | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index b2111f996aa6..f4f34d69131e 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -714,20 +714,18 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
-	if (!memmap)
-		return -ENOMEM;
-	usemap = __kmalloc_section_usemap();
-	if (!usemap) {
-		__kfree_section_memmap(memmap, altmap);
-		return -ENOMEM;
-	}
 
 	ms = __pfn_to_section(start_pfn);
-	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
-		ret = -EEXIST;
-		goto out;
+	if (ms->section_mem_map & SECTION_MARKED_PRESENT)
+		return -EEXIST;
+
+	usemap = __kmalloc_section_usemap();
+	if (!usemap)
+		return -ENOMEM;
+	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	if (!memmap) {
+		kfree(usemap);
+		return  -ENOMEM;
 	}
 
 	/*
@@ -739,12 +737,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
-out:
-	if (ret < 0) {
-		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
-	}
-	return ret;
+	return 0;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
2.17.2

