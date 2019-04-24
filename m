Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32765C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F126221773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 10:25:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F126221773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23D156B0008; Wed, 24 Apr 2019 06:25:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CDDB6B000C; Wed, 24 Apr 2019 06:25:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC1B76B000D; Wed, 24 Apr 2019 06:25:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C443E6B0008
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:25:43 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t67so10206163qkd.15
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 03:25:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sstr/K0HceJCPLq+MhzSzTpSmFovLaEMCGEENQ8I26Y=;
        b=Y3t1sShMXfhDhJ9Gao9GtLePmNMkE5oAAJZaAZ7F5nzE1cuSnI8dKsOdN7QnrCeZ/N
         4DO2h4AjaWr6mG6DYo7WQtU3SB4QmL0eDd2oG2Z8lXRcsBRcPAsXwLH6wRub3G9EJKmC
         45mnM3kRMV2CyjOpfRzM5QRxFB8SMs/oD36v+xfO1wJoLAQ3A9OVSN9+KTafIg73gN7V
         /pKZr9fgpnTuEVluCgZqFzi0nL/jerVRFtaH1PZVV3FMMY0eSYqiQNqjKSyunak0/uq7
         E4Yo6JPstzX5BVTInn9GzPB9VQNW78rRB7QuIAGsab8nRcT8yJ0vS4prXqhu7j9zXxw6
         //Wg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUSbd/MPDrBVmNP74ZMaMXrSsLdyv/aXyaPOrtvPKzS5n5kw5sZ
	vKMnM7+nJ/c9miRMeOsmPSvz/8OSkTE77ghKArji8Fv4zQgimD6f8Ejk1ulACCebJW6mYju0Rvm
	JmrskqqRW68J5KXlGJUKkClzpdZkDI5oiac7pxELKUY5lqiBp2t1sT3fKicc8LMIU7g==
X-Received: by 2002:ac8:74d6:: with SMTP id j22mr5135052qtr.144.1556101543583;
        Wed, 24 Apr 2019 03:25:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx64zuXMgoeTF83FCEa5ZmbEVOjuJzIVFNxwHgDZuvW3jAXEEjW15E0g212YPwys2UeH6Qb
X-Received: by 2002:ac8:74d6:: with SMTP id j22mr5135012qtr.144.1556101543004;
        Wed, 24 Apr 2019 03:25:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556101542; cv=none;
        d=google.com; s=arc-20160816;
        b=OVI8mQ1fpCGR5yIgdgFP9fqxj2y3YdUZ8gE6pWvd/C5SpBHgf7vc1b1bOOxM40iZPk
         bMgZI2t9Onn1hNIKgaXHCp52sBGk4p/QjQcmMh5e1UCrAl1q+uXzhHsvML8mlxmpDhGl
         aQhndjX/z8hXKcEDqNjztl+13zX9tYgS9xzMuppDngCropgWEmEVidXevGfwOtV7m03T
         M1bqQktDbtiRMV+/dcaBt8VjqaRRB/U4aX8ik8l/1KlKwBEB1CQHRcMvXtLksU2jcp20
         7rOXw8vm+oX1WQz6jlCRVmEwfqS5k7Ih9By+l6IkJq2CIZ2GePeA/XOFaWfJn2hyuLGP
         enJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Sstr/K0HceJCPLq+MhzSzTpSmFovLaEMCGEENQ8I26Y=;
        b=Z6MV9KiHtq3CiZFzAFfaNhqffqn15PsgOWfGZWLj/M7XFCNB/Z/B+4OOYZVbpt9IQk
         +dGmMMzv/KkYUe1ASgXeaja4bJ5pA2B1/evACrDXtK2mEdQDHoDqrS8dC8nARTBYiisO
         ZczvyxuA1xjaMnMhzKOU03cPj+EZKO6Lu1jSrphpP4gljcDfXCVKipQyVHBnPtHMSoYv
         i8uHxCrPd33BZGzVQQT9BDLt5q89TV4ySerIuQjiXORYGqcJexr3u46bFI2D97UFcOmC
         tWHeLqklF141y5898127TsvSa6UVrD9c240IsdBe1FSI2g8ehw+i7Tmif8SiIeLiMjtA
         bL7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si4814226qte.102.2019.04.24.03.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 03:25:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2D2062D6A11;
	Wed, 24 Apr 2019 10:25:42 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-116-45.ams2.redhat.com [10.36.116.45])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6357E600C1;
	Wed, 24 Apr 2019 10:25:39 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	David Hildenbrand <david@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: [PATCH v1 2/7] s390x/mm: Implement arch_remove_memory()
Date: Wed, 24 Apr 2019 12:25:06 +0200
Message-Id: <20190424102511.29318-3-david@redhat.com>
In-Reply-To: <20190424102511.29318-1-david@redhat.com>
References: <20190424102511.29318-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 24 Apr 2019 10:25:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Will come in handy when wanting to handle errors after
arch_add_memory().

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Oscar Salvador <osalvador@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/s390/mm/init.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 31b1071315d7..2636d62df04e 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
 void arch_remove_memory(int nid, u64 start, u64 size,
 			struct vmem_altmap *altmap)
 {
-	/*
-	 * There is no hardware or firmware interface which could trigger a
-	 * hot memory remove on s390. So there is nothing that needs to be
-	 * implemented.
-	 */
-	BUG();
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct zone *zone;
+
+	vmem_remove_mapping(start, size);
+	zone = page_zone(pfn_to_page(start_pfn));
+	__remove_pages(zone, start_pfn, nr_pages, altmap);
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
-- 
2.20.1

