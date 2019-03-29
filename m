Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47BBFC10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:42:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 106EA2183F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:42:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 106EA2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DAE06B0269; Fri, 29 Mar 2019 10:42:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98A956B026A; Fri, 29 Mar 2019 10:42:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87A9C6B026B; Fri, 29 Mar 2019 10:42:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 653026B0269
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:42:58 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d131so1911255qkc.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:42:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=D7CIhW07mqa0zVxhNFUC8epuJNQqRjcuyIe08QpviYQ=;
        b=Xffgf/Bw1+VDjyFnLyP0lj0e5JxvsR63nLKWVKHnJ3Ujj8cAEZ9rAw0fOIiMUqyKPn
         tofDkqt7SXvEOcmJLdV6VIZqwij5obJRHgPiit/QqlhxKUs+IV+OqKe7KE9BOlTypEwb
         QPQstzkAmTKzxMnQxBknCTa989Mfji2pTcxveQjsNy7LJhD2Ws7RtqeaVBCQvt7j5erc
         8QyiUUJPF4jxNYC3ebh0Mi0j8im8m11zRTNpS8yB3j2SxA+9ta44t0Dh2R8Ja3f2nJbR
         xIJ7MZv5Hg6i7rB9nPcOK9YAn6IaUr49krPdvEKAR8wjhJTMwYii/R/hYx9ShOxgWFEI
         aYZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/MB/r9SSqCdj6a43m8UJcljqVjDvWfOL5LMmX5j526kWlq/2m
	hBW9s8sF+N0ByTVnkhatqZj5I1DuAXHv3csVLtznnwS0EGFka/uugsKh4pWPLSiIxD14CkbD+ol
	l5z6GJMH6YrmbaIlCU2rcqbwv22OLrg2Su2ZRKgL+U+ib3vHOAby2ON5bA0/w++ll3A==
X-Received: by 2002:ac8:3044:: with SMTP id g4mr21395455qte.290.1553870578171;
        Fri, 29 Mar 2019 07:42:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTl9kAiylxAureasMbZ8Gawg1tGlmsY9dXccCrgYGqW30dbYgoPplE6ipollA+8XFLWOxZ
X-Received: by 2002:ac8:3044:: with SMTP id g4mr21395344qte.290.1553870576566;
        Fri, 29 Mar 2019 07:42:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553870576; cv=none;
        d=google.com; s=arc-20160816;
        b=qC8Yf9LiJ//BeXDcZ3ljisMHk6Du6qxM9NJwOT4BSes6s1OjCUeG+KCx3FOC8NoDSX
         c5fCMoueXwzDhMylt7biKsdE6rTgAWwD3FXIKF6tJXKMzcnHwjbP89IYgV8lOhR9x1kM
         cMBfk68QsuBn8S4ynhMpQ0yPC+lAw6OzEzG46cAW5QszWj+LVOrTrB8x8D0If/8E9Yn2
         eKMlHxsOIhkgJeWLcRY8yT4MyL+3wKE31JHILgBEb6gbCqzzyvKfVQ645OCuNtZcd9/1
         p7FG6udYxGvYES7EZo8/yEihjZjf7+/9z54TDr9ZhnZ13B5WS5ZuVPyXQ4nSSdC8hm6n
         2L/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=D7CIhW07mqa0zVxhNFUC8epuJNQqRjcuyIe08QpviYQ=;
        b=iGcfMR3IesLt5s1GdrHBl/vbH6e2QW+VYKOBTx/65ZL5+iIXj7s+kz/yFQcOuDdaeq
         lHpZD7asIAtHm/dPTYx+k+XEzloRnHMlZI3CiMmhnfHcDPCf0OYP0gji30YKPO7vLqb4
         g0A8sXoSS37Xz2IM/5kKWUxPeiR0vOxP5jFbdJLoase5QYpkksJpMfWQ24NNxGHoItmS
         75puF/YN2T8dJlE7iGuRhj5muU/BLyUq9a01QxqFyyvGTHVvfpdWaYJisZhBQKsSFPGO
         DgfOrK9z0hofTB/1r6FPpaBWEznFSlhZTlRt8zTPcKLC7NDoptZ48fFk9JO5Y8w230m1
         58JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m16si98676qtm.55.2019.03.29.07.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 07:42:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D2C96308213E;
	Fri, 29 Mar 2019 14:42:55 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 76C775C226;
	Fri, 29 Mar 2019 14:42:53 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	willy@infradead.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v4 1/2] mm/sparse: Clean up the obsolete code comment
Date: Fri, 29 Mar 2019 22:42:49 +0800
Message-Id: <20190329144250.14315-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 29 Mar 2019 14:42:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code comment above sparse_add_one_section() is obsolete and
incorrect, clean it up and write new one.

Signed-off-by: Baoquan He <bhe@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
---
v3->v4:
  Improve the doc format further.

 mm/sparse.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 69904aa6165b..cb448c8bb46c 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -684,10 +684,18 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-/*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
+/**
+ * sparse_add_one_section - add a memory section
+ * @nid: The node to add section on
+ * @start_pfn: start pfn of the memory range
+ * @altmap: device page map
+ *
+ * This is only intended for hotplug.
+ *
+ * Return:
+ * * 0		- On success.
+ * * -EEXIST	- Section has been present.
+ * * -ENOMEM	- Out of memory.
  */
 int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 				     struct vmem_altmap *altmap)
-- 
2.17.2

