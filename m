Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11D05C04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 17:35:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A69E120866
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 17:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A69E120866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A7236B0005; Wed,  1 May 2019 13:35:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12EE76B0006; Wed,  1 May 2019 13:35:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEEE16B0007; Wed,  1 May 2019 13:35:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE7A36B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 13:35:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id q16so18524603wrr.22
        for <linux-mm@kvack.org>; Wed, 01 May 2019 10:35:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FYD0+O1saS54RtwokFj4HpWLfzD9N+ZLICLPr9lVc/c=;
        b=AdpBjGK0K3/KkuRpQmmlyec52wSNvgqK5bBAWEqAh9V6hTJ8DvOVZbNQow+r0xadX/
         mM6XwlqriAAgzAjKmk1Lh09OKzTFvdShNKipjWEoR7WptMyjJmeZO2Ln2iLjcBt6wfOw
         9xW0YC87gYcF/Y03+eviSAPR/WpUh8Gt3K3gW3acQBAJjW6weDyH1UQfZiZpNN6XNk3+
         H0vei6jIVlgmmCGphybc6XsNP2DqEwzGAeQyWNAbudMgriV1HYpb5CA1es8B0cMfDxMf
         Vkmp8B0Kf5gZpqxtHq3Ps4Dr4Succ2RW68uWJqq0ikB122nV0yBFDTWwnbb6K2IsAfD3
         ypJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUmKIhrjIiU0Vjb39eGZe/vEFXJll6PraebEeEf4qj2zddN1ium
	JDfB+0WTsiQweUAk3dGsmeIFMDX5PnTjtJ1/qofx+jRpajh9t/AuNsL/bhwTG/G4MjMY6skYNWr
	F6lPvV9H5I3Q6Zx+J8sdxeECD7jYs2Ut0bBV50U/WSe/Ki8eG9rQqwbhSIsw+lHomWg==
X-Received: by 2002:a1c:7518:: with SMTP id o24mr7243098wmc.42.1556732100912;
        Wed, 01 May 2019 10:35:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUcrjWVaNcRErc+E/NuE6Botdk8EinKBkUNPJ0Pt5RBzLW8LqE2o0+8UB5gU6zKljuDrwD
X-Received: by 2002:a1c:7518:: with SMTP id o24mr7243067wmc.42.1556732100012;
        Wed, 01 May 2019 10:35:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556732100; cv=none;
        d=google.com; s=arc-20160816;
        b=SMJ7WFFH6JFCi/8jEPvm6adD1LJ02jvqdD0Kib0/GJFWdHkyz4blNSJOdqSNmFAT8q
         qstgdlJWKUCnMvoAxPxc5ZzpOFoEPCNKKnQ1hRTwyOU/FKUwNeSPc2q+u5wiFYH3iiyv
         KT8YbWxbKIh1SbHylUea4Kq77xmvKNYNGytHOFW8bvk0dDxJb79OjWVGPKfQWl0OtWHA
         rvVijcg5220Hm4sPHJsNRrpGWFbtIGCXo4r7TCF7zotzUPRwYx2YBl/j7t5Kunubz8UR
         GR47dhwrBT9IIL+2KMc8vuaqN0M5r1NYeEUbOCQCOKS16p/S2MRUn1rfhND9KOb2CMAo
         kVbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FYD0+O1saS54RtwokFj4HpWLfzD9N+ZLICLPr9lVc/c=;
        b=gW/kSUu1qhWr8ap3DBi6T3425vyhQ7ofInzCM5o4i9AdSycoM8OB2iWtj4HlpXnVq6
         fuwTMYGyrXBJ48gsHnNtvQliANeAcTx9NtM+uezK8rgrsTtZp0ze8k25IvKsZJx/C9zS
         V3xBRfSXMo+RW477eCHMijRwdoaaXCY0jXMm0dylhIOtxllzhVj1qjM/2xPd5U5MQCBL
         EZgDOHbO/hnGaDgM9SAMlKd4ce5/NpH42uJFGGchrYiEjHUSa9CZPRFj/fEdG4ezGLS6
         hrFnqE1byDmFFlml3EQF+H0GBkMvY+z9rOpttVVRraMuWSUPpFC6USDkIIUObB2Y9m+2
         fQ9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k11si3416614wmj.175.2019.05.01.10.34.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 10:35:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 5364068AFE; Wed,  1 May 2019 19:34:43 +0200 (CEST)
Date: Wed, 1 May 2019 19:34:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sami Tolvanen <samitolvanen@google.com>,
	Kees Cook <keescook@chromium.org>,
	Nick Desaulniers <ndesaulniers@google.com>,
	linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [PATCH 5/4] 9p: pass the correct prototype to read_cache_page
Message-ID: <20190501173443.GA19969@lst.de>
References: <20190501160636.30841-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501160636.30841-1-hch@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Fix the callback 9p passes to read_cache_page to actually have the
proper type expected.  Casting around function pointers can easily
hide typing bugs, and defeats control flow protection.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/9p/vfs_addr.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index 0bcbcc20f769..02e0fc51401e 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -50,8 +50,9 @@
  * @page: structure to page
  *
  */
-static int v9fs_fid_readpage(struct p9_fid *fid, struct page *page)
+static int v9fs_fid_readpage(void *data, struct page *page)
 {
+	struct p9_fid *fid = data;
 	struct inode *inode = page->mapping->host;
 	struct bio_vec bvec = {.bv_page = page, .bv_len = PAGE_SIZE};
 	struct iov_iter to;
@@ -122,7 +123,8 @@ static int v9fs_vfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		return ret;
 
-	ret = read_cache_pages(mapping, pages, (void *)v9fs_vfs_readpage, filp);
+	ret = read_cache_pages(mapping, pages, v9fs_fid_readpage,
+			filp->private_data);
 	p9_debug(P9_DEBUG_VFS, "  = %d\n", ret);
 	return ret;
 }
-- 
2.20.1

