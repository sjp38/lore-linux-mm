Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C89CC04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C76D2146F
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 11:12:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C76D2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058236B027B; Mon, 27 May 2019 07:12:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02E4A6B027C; Mon, 27 May 2019 07:12:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E87C66B027D; Mon, 27 May 2019 07:12:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C12416B027B
	for <linux-mm@kvack.org>; Mon, 27 May 2019 07:12:56 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id r78so5294456oie.8
        for <linux-mm@kvack.org>; Mon, 27 May 2019 04:12:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=81dv9FTnNj/7LyZAowjAA1AFW7W3zsQkqaihczv2Mls=;
        b=NyDgsQfJOs/nunWdg/FgnpAl9yMjvQ7tsUqOIYFchgtJ+veJfl6DojOK6BWkaXaJMg
         vxodkWdqTJ2ezvQc5aKKJRtbM3i8+Pig/babnwAqjFQTGy8jfPGgpC/gs4nooy2C2VFb
         UT4WvovNZmlPSmaO24B2AaNlLNrqNIgWkJlRKA2CszW6PCB6bROLqixt+yNndyPNkVXz
         Cm9jKUqI5vCXJlyLc2ZOTGbeOIxbNcOc205UY6VLi55gmq2204sPD5FW039CzlKK3TQ/
         FSl4y4DPfp9u5pdibKWxc0N0dAn33dt3d88hpXhzemmsWcTMuAzESmifWNrxNQwkGFVK
         uBGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW4OEcYoxTlxpLPfRcDdUB6XfMVmBP3XLQjyGLo1NgqUTz5r/d8
	feF9wzooCgQZ6OT+9bA7ZOLH098XydF9pWTFY1L34zQZ8M473dZ2HpGDirs4P4oP3lT/0YipWYL
	WT++31sQkWUzBWN6MR9KDyXjuGG+QTvt0LaxWcleXD1zAFJOHeH/R7+PMwAE7uKjQaA==
X-Received: by 2002:a9d:6848:: with SMTP id c8mr13823597oto.200.1558955576492;
        Mon, 27 May 2019 04:12:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTSPBumoyEsoXtZziU5oHnr3auxY7q5CLU8DiZyFOGvhu4xqR3C5LpNCst69B3NM7PfgtT
X-Received: by 2002:a9d:6848:: with SMTP id c8mr13823573oto.200.1558955575986;
        Mon, 27 May 2019 04:12:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558955575; cv=none;
        d=google.com; s=arc-20160816;
        b=ixV6IXkseNy3vf6b2A2sknRzRmp0GNA8rCErlvhGUN2p+GSxKoK3i6CHrxa+wAStK7
         xG7N8cHB8m3EApuItXWafuB5zb3KMcgBPYk80WBu9hHC5nmL/8UJhXl6M5VWi+W//p/c
         cCfw2eOGVNzjmSXEPEUmJ7lmd8/nDYw0//SzfPW0vhwVkbhcKaFZ9Tg9dDnmiyLemitW
         G6/kXupfES51OPGNbg2CWN/oHBmpCiqNVbaoOubxCSZxP0V82YLtcT+4p/G8scNvBsBf
         Chy/HQwhX9ynmvY8RUVMADhRtg6dicYgOWYxYw53RqYt2t5rvv2CjzHFHPP09rcBlRGO
         m6yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=81dv9FTnNj/7LyZAowjAA1AFW7W3zsQkqaihczv2Mls=;
        b=MGhk233lzyJeLOV6neZNGN0KWE+VODghNqEAJw4LBpbIO6qPQ0m3d/1XwB9DrS8mN2
         jrXU8Ji9AmaMZaOl/UwPL3qclAg3SwW+1ZtmYQ6YXXhqdj+l3L7HZ97r+f5lDH5SZmEN
         nl+NWgT+yw6hNETpAEH6p+AdpzuqjVybmwJfZO5BYXpGZibxqYwvrtdZGplCXxOevovs
         2wSeDjNh78tgtQtgWWMEFOgHsy7jjga1IAqRAdDs80NPDqolSHrqFuUsosGPL5jVFATb
         fbDHq8hxL4O080GW9JZMR2NC0aYu2Y7aQXxtor+bTBwuDwDTya/vRnUkqidz+kyFu+Ju
         9PPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c3si5628089otm.117.2019.05.27.04.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 04:12:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 19FE3307D855;
	Mon, 27 May 2019 11:12:55 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-89.ams2.redhat.com [10.36.117.89])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9F3D72AA82;
	Mon, 27 May 2019 11:12:51 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	David Hildenbrand <david@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v3 08/11] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Date: Mon, 27 May 2019 13:11:49 +0200
Message-Id: <20190527111152.16324-9-david@redhat.com>
In-Reply-To: <20190527111152.16324-1-david@redhat.com>
References: <20190527111152.16324-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 27 May 2019 11:12:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer needed, the callers of arch_add_memory() can handle this
manually.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 include/linux/memory_hotplug.h | 8 --------
 mm/memory_hotplug.c            | 9 +++------
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 2d4de313926d..2f1f87e13baa 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
 extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
 			   unsigned long nr_pages, struct vmem_altmap *altmap);
 
-/*
- * Do we want sysfs memblock files created. This will allow userspace to online
- * and offline memory explicitly. Lack of this bit means that the caller has to
- * call move_pfn_range_to_zone to finish the initialization.
- */
-
-#define MHP_MEMBLOCK_API               (1<<0)
-
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 		       struct mhp_restrictions *restrictions);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b1fde90bbf19..9a92549ef23b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -251,7 +251,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		struct vmem_altmap *altmap, bool want_memblock)
+				   struct vmem_altmap *altmap)
 {
 	int ret;
 
@@ -294,8 +294,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	}
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				restrictions->flags & MHP_MEMBLOCK_API);
+		err = __add_section(nid, section_nr_to_pfn(i), altmap);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1067,9 +1066,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  */
 int __ref add_memory_resource(int nid, struct resource *res)
 {
-	struct mhp_restrictions restrictions = {
-		.flags = MHP_MEMBLOCK_API,
-	};
+	struct mhp_restrictions restrictions = {};
 	u64 start, size;
 	bool new_node = false;
 	int ret;
-- 
2.20.1

