Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDF55C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7584920857
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 10:02:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7584920857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12DF16B000D; Tue,  9 Apr 2019 06:02:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DE416B0010; Tue,  9 Apr 2019 06:02:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F12966B0266; Tue,  9 Apr 2019 06:02:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D28176B000D
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 06:02:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q12so15398065qtr.3
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 03:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=WZXpfD7EsjnN1SQ5fEAHTKPSxNkAK91+tRvlhxLuxp4=;
        b=OrLO0RD7lP38aBYK0L7e11lbFguMw+tkE4dYKKTnM1Fn/IZWZ7jmTmUjNHtIssW77g
         GT0MLTMCtbtHKu9XzDKC0zydM4J33YpAR1g120LmXQKIt7hwFfxeIvNvxYE2JjYolw+g
         e1mKR/SP8WH+2nFTt8OEk4qlQwvpUvWtIHONNJwewF92p4uWuXJDD5tmuVfzzXgH/LU0
         K3uRLYOqYjLrJgQyZYrPU8Vw1FRJ0fBDcvUrRq43XZGSPx53kGzwwR4fNJqgGKMryM+8
         HWikoNmJslfbvJrSc1i6uHVt10pVJIgzqK4IbOSQPnSwg7fIqIRUSrzTNMIVVS2b23Qg
         llxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWWq30reG8OZIeGfbCahg5V6rDnTp0o+7nG6DCNmDrBCzBtDayX
	8eYWnk19g0b/Xl4Qy5OT+AGeuDIE4APh9B7oQZ88T3/09pMzKAnth2lvV/TwhKmSaJzgf+2mXBz
	H6YVyplZwLE99aMjHW1Qxe25sJVAEo7pEfXd0Bhfu4tx+zT8/X8URhuq4l7Nd8qIhyg==
X-Received: by 2002:ac8:33dd:: with SMTP id d29mr28897957qtb.320.1554804129343;
        Tue, 09 Apr 2019 03:02:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySvfIWMatmY9RsXJHCKM4kKpRTAgWF3ZPgkD+opWIVZj+zeDilJGnTP+btgh+JuTlEjBbF
X-Received: by 2002:ac8:33dd:: with SMTP id d29mr28897841qtb.320.1554804127943;
        Tue, 09 Apr 2019 03:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554804127; cv=none;
        d=google.com; s=arc-20160816;
        b=sNT2mYZ+V1WhsOXwjDKAdmozSF1SWre8g31QqXADzfNO9XVPTz59zbmchel2wRKBi1
         mlgZQ82eodCnF4xrYv9X/jJr1JVNqNngsNmYXqR/UKQ0JiKAUHPh+ZZ7z7tS+n0BOv8I
         /RpvrOzPo7vR+/ipzsSii1sLNrPqlWN7U2KBXED8+HC0/EwJfps3W0XTXj70n6CMRE5N
         qEXqq8EqCtzvs6zJDbLJGfioK2DR/XgngSzWUN3ZwgAtILRkbTIs/S+fXTDiEJy29ijA
         Lg+hIIc3lutQ1VZ+uLzIE8fdlMEqypkFTCvA9Fbw47qugvw7vnDjAmv3XgGgPrMUuQ7I
         8OCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=WZXpfD7EsjnN1SQ5fEAHTKPSxNkAK91+tRvlhxLuxp4=;
        b=y5BsLKuA3H40Ggr7qzXboQWDUzFJhOEfFFOcxcXAe46k5RbvcOBYh3RV9AEkGzRrja
         DXDk+09iLEc5RFYfH4uE5GCj8hgnBTYarggf/f6QnSHacYlzGMB1kLTypWvXpNlK6QV5
         aG3l2fo/GoRkcsUG9eTWgvaV95hgZLSyXLZKKqo4OO1wZFPZoD0JLAZNdRnK7B8voYV9
         f4YaUvTfIMIT70htBWlyxd+8Rdo2d3CHY5P+fcc7fxBsscFHia2WRYwrz3efTn6GL5lh
         75GQ/GnKgxgFr6eZpeQtf6akZRj1KlE7REylvzgC2SffYFGoULF4vGYA0NrPBVHnZrGK
         5iUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i16si1401059qkk.141.2019.04.09.03.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 03:02:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0441308794C;
	Tue,  9 Apr 2019 10:02:06 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-49.ams2.redhat.com [10.36.117.49])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ED59E5D71E;
	Tue,  9 Apr 2019 10:02:03 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: [PATCH v1 2/4] mm/memory_hotplug: Make unregister_memory_section() never fail
Date: Tue,  9 Apr 2019 12:01:46 +0200
Message-Id: <20190409100148.24703-3-david@redhat.com>
In-Reply-To: <20190409100148.24703-1-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 09 Apr 2019 10:02:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Failing while removing memory is mostly ignored and cannot really be
handled. Let's treat errors in unregister_memory_section() in a nice
way, warning, but continuing.

Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Banman <andrew.banman@hpe.com>
Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Arun KS <arunks@codeaurora.org>
Cc: Mathieu Malaterre <malat@debian.org>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 drivers/base/memory.c  | 16 +++++-----------
 include/linux/memory.h |  2 +-
 mm/memory_hotplug.c    |  4 +---
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 0c9e22ffa47a..f180427e48f4 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -734,15 +734,18 @@ unregister_memory(struct memory_block *memory)
 {
 	BUG_ON(memory->dev.bus != &memory_subsys);
 
-	/* drop the ref. we got in remove_memory_section() */
+	/* drop the ref. we got via find_memory_block() */
 	put_device(&memory->dev);
 	device_unregister(&memory->dev);
 }
 
-static int remove_memory_section(struct mem_section *section)
+void unregister_memory_section(struct mem_section *section)
 {
 	struct memory_block *mem;
 
+	if (WARN_ON_ONCE(!present_section(section)))
+		return;
+
 	mutex_lock(&mem_sysfs_mutex);
 
 	/*
@@ -763,15 +766,6 @@ static int remove_memory_section(struct mem_section *section)
 
 out_unlock:
 	mutex_unlock(&mem_sysfs_mutex);
-	return 0;
-}
-
-int unregister_memory_section(struct mem_section *section)
-{
-	if (!present_section(section))
-		return -EINVAL;
-
-	return remove_memory_section(section);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
diff --git a/include/linux/memory.h b/include/linux/memory.h
index a6ddefc60517..e1dc1bb2b787 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -113,7 +113,7 @@ extern int register_memory_isolate_notifier(struct notifier_block *nb);
 extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
 int hotplug_memory_register(int nid, struct mem_section *section);
 #ifdef CONFIG_MEMORY_HOTREMOVE
-extern int unregister_memory_section(struct mem_section *);
+extern void unregister_memory_section(struct mem_section *);
 #endif
 extern int memory_dev_init(void);
 extern int memory_notify(unsigned long val, void *v);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 696ed7ee5e28..b0cb05748f99 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -527,9 +527,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
 	if (!valid_section(ms))
 		return ret;
 
-	ret = unregister_memory_section(ms);
-	if (ret)
-		return ret;
+	unregister_memory_section(ms);
 
 	scn_nr = __section_nr(ms);
 	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-- 
2.17.2

