Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD948C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:43:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9965D21850
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 17:43:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0KPNMSd1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9965D21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A2EC6B0288; Thu, 23 May 2019 13:43:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 254006B028C; Thu, 23 May 2019 13:43:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11C2E6B028D; Thu, 23 May 2019 13:43:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D04076B0288
	for <linux-mm@kvack.org>; Thu, 23 May 2019 13:43:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g5so4647660pfb.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 10:43:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=GPbTqA3sKULGXvYjOTM7gfPZ7s4y9WwkUm1EREZ84Ec=;
        b=uawt0WP/egYAnE+sAU5EJNZREQesRuUC57yhdWxEBPUXM6PmrU8DEnD5YCTUvNdkyB
         MUTsDdBXxRqK1M36JmzIjle+QDMTYbDHj19btc7hvdT9PIbjsEYuBDWjFtgEnwwJdtNt
         zqjLtT5AOsKwsJpKMhAfvop0QK/d9esyVoyYdPxS7lhVLkE3XM51tbH9EgYu2MGmZgwA
         ZoSIhzZPz4W80bSB4oQ9WCMuPJO+/KlRhGJIYn1+zpfXwEJK0L23G08QyMk0ZX1LUJCl
         DS8mZWzwoKtNqS4ZG/6EI1fW9bALs7zDXROOTbndv4WcAeP6NxSdLDgL3dm2VPH0d6TY
         Gzcg==
X-Gm-Message-State: APjAAAUqWsf8aTJ4X+8KHgRy0hKmzvme3zO8vnz2NDkxr+KbFkTSnz0b
	WPt/dtG0xa6deeWeu95CWTsXY8eLy8ibn4tBtXk0Xbb9E8CiQjiJ//QTAL1ygkW+ZAWBZk3pXqz
	WKGgqBosArNsH9PQvKH9JRL5wDoj0N8EdpU8gn00ryBlz8/YOsBi4r4MRavyT/4id9g==
X-Received: by 2002:a63:ed03:: with SMTP id d3mr98745311pgi.7.1558633438379;
        Thu, 23 May 2019 10:43:58 -0700 (PDT)
X-Received: by 2002:a63:ed03:: with SMTP id d3mr98745271pgi.7.1558633437593;
        Thu, 23 May 2019 10:43:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558633437; cv=none;
        d=google.com; s=arc-20160816;
        b=okrnPamrtloXxZSjTs7AC8uCNNS6OBdMZMsKSVc8RZ6NnVYTiTwbbnbFDG9RjnHfwU
         Uz0zF32N24/QSrDSMLUd+Hh4JNePNJm9QaumJArpjbScyNqRnh9fC33H/Bu1VPC0FIwe
         Dtu+nFDWP8TUl34cCAO/sywHM1hQlrpQnzo8PiWdP/SeBzGJixRRQ+bTmyb9ZolQ8lon
         xl7p4jwYElpQ6flQgFq7GPSWHx161GVJO0FXE7/UjZ0t/xNZBj7N+MngC+xlqVTwr/U8
         3//qCRQcZQTDRy2rI9BCcdIpwJhRhU9Hdpd3HgetwnHxpVnbhbkDQ2MJM1m1xGQMuWE/
         Ei2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=GPbTqA3sKULGXvYjOTM7gfPZ7s4y9WwkUm1EREZ84Ec=;
        b=XiShpxcKtydy6hsxZK4h43oeC2VGUW0JhJrMLXG8j9ulNomGi1Nn3uUBjP4fp/ylSr
         4xcManAIRS5t4yFRZ+2a0ArYMVlHQKcTK9NITPUGgjzItIEeJpqIkmk/PpvfLkLIStGY
         cZOg+gwkAdgpcVZVuNdIlA3nUNyZhpc/GIjSCIHEl9jgp2mU/e43YHVBMZ8ztOtWcwgP
         hztKM+cFpBFM7nsRUyZsLO1xrTybBJ8CNeuYz13RMBPyhWzvbe/Dy5QJEFhEVUHV1Ip0
         2l/JN4b+rqCIczc+n3q7q7A1a5/hs+YIEawlxsnuHQP/SKzNGHagWFp75UgQcOjRsSYD
         E3Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0KPNMSd1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor28886820pfr.30.2019.05.23.10.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 10:43:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0KPNMSd1;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=GPbTqA3sKULGXvYjOTM7gfPZ7s4y9WwkUm1EREZ84Ec=;
        b=0KPNMSd1e/ZShlAg1C25np34O9KMTbLFWMGEN4hhgcEhVyzmdg5tjbCMiFs1aybHC6
         Qpem7qqPH7wZ4Y1fpd/on//UTqYR/TJz2wC3p8mAuf4EPSJ+zqxXdvq+cUPYsMcx/dRk
         EJrnBOUKqsEexPUnDc9t4pjTsVMOc/DoL+jt8v9Wyf/nNMNpk+KmMOurhckcCiuYo8aP
         tWxIVyTzlRevLlnAIJgCTLQ7i0JTkhGkeIzFcoQPfXmExNfoNOaGDETbyV6xKsyeqkXF
         EHjzKM3rmL85wy3SZurcNLO0/Vg8m4xth9v1V0hD2M/S/tFuQf+P5py04XOUCNByiOKB
         7fwA==
X-Google-Smtp-Source: APXvYqxxNUBl2ALbzC/oRGpRc2/4PfBhkyFvL2USl2iASHWmjwWhqOT4E5ch4yBkBNmaWJBlon5wXQ==
X-Received: by 2002:a62:4118:: with SMTP id o24mr74875817pfa.17.1558633431910;
        Thu, 23 May 2019 10:43:51 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:a988])
        by smtp.gmail.com with ESMTPSA id h18sm13255pgv.38.2019.05.23.10.43.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 10:43:50 -0700 (PDT)
Date: Thu, 23 May 2019 13:43:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: xarray breaks thrashing detection and cgroup isolation
Message-ID: <20190523174349.GA10939@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I noticed that recent upstream kernels don't account the xarray nodes
of the page cache to the allocating cgroup, like we used to do for the
radix tree nodes.

This results in broken isolation for cgrouped apps, allowing them to
escape their containment and harm other cgroups and the system with an
excessive build-up of nonresident information.

It also breaks thrashing/refault detection because the page cache
lives in a different domain than the xarray nodes, and so the shadow
shrinker can reclaim nonresident information way too early when there
isn't much cache in the root cgroup.

This appears to be the culprit:

commit a28334862993b5c6a8766f6963ee69048403817c
Author: Matthew Wilcox <willy@infradead.org>
Date:   Tue Dec 5 19:04:20 2017 -0500

    page cache: Finish XArray conversion
    
    With no more radix tree API users left, we can drop the GFP flags
    and use xa_init() instead of INIT_RADIX_TREE().
    
    Signed-off-by: Matthew Wilcox <willy@infradead.org>

diff --git a/fs/inode.c b/fs/inode.c
index 42f6d25f32a5..9b808986d440 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -349,7 +349,7 @@ EXPORT_SYMBOL(inc_nlink);
 
 static void __address_space_init_once(struct address_space *mapping)
 {
-       INIT_RADIX_TREE(&mapping->i_pages, GFP_ATOMIC | __GFP_ACCOUNT);
+       xa_init_flags(&mapping->i_pages, XA_FLAGS_LOCK_IRQ);
        init_rwsem(&mapping->i_mmap_rwsem);
        INIT_LIST_HEAD(&mapping->private_list);
        spin_lock_init(&mapping->private_lock);

It fairly blatantly drops __GFP_ACCOUNT.

I'm not quite sure how to fix this, since the xarray code doesn't seem
to have per-tree gfp flags anymore like the radix tree did. We cannot
add SLAB_ACCOUNT to the radix_tree_node_cachep slab cache. And the
xarray api doesn't seem to really support gfp flags, either (xas_nomem
does, but the optimistic internal allocations have fixed gfp flags).

