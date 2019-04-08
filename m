Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94EA2C10F14
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47AD3208E3
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 10:12:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47AD3208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAF156B0006; Mon,  8 Apr 2019 06:12:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E36216B0008; Mon,  8 Apr 2019 06:12:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4B516B000A; Mon,  8 Apr 2019 06:12:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B423D6B0006
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 06:12:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g48so12250730qtk.19
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 03:12:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=c1qEfMhK2jjJVhzLElZ0ixQesqaRds3kjLS7FD8LKgE=;
        b=b4nxzHlLiPmcIY1U8PPDP4mFdv2tbo8CjjbxiLxeVy4t8Av85jeqAyxlXbUn4WN50y
         kHn4nwEXZfjBble+l9H7OaCBaWgQq/Lt8BigLu1TS3l3E8HylW6nQeORn7mhQ6/xbx8s
         Vcxo0jDC5u+cJ2GmYBcwozFbNgqEYApyX8lzMvtr/+/Gh6kIYk59cZGtajYmS4Wi4NrR
         8AqipkKn5XtIGISEVinSMwwhXijCKZFD5NbAQodsBEoD3OVftVMAB6INfUybnM8l262q
         6y5iuToV5rZPT/p/kHKG5OWfIqhPbR/Gdm17drw4sVR312wtmRaEbPMYfp4fH1E3bcTk
         jjZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpfPMUo0H22+6VrggIJvXODd9oHzUt6pGwbJ9S+Cp6qDbdkC4Q
	+WCl+zbb02fJBE42RSGJ/hu2JDVjueaGxU7rUiJMXGnUN3O+eBZqABWnk6DUN/KeCXrCFXGgtlo
	L7LEC/z3kzyM1kBSOA8l5yRiaMLURMjaaryrn/UA4rHN3tFuQNIg2GZKz7jLazVxdAQ==
X-Received: by 2002:ae9:e313:: with SMTP id v19mr20533504qkf.153.1554718360473;
        Mon, 08 Apr 2019 03:12:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxH0u2fLvrbCVq30j31v8hFeWi7Lptuc6KxiLiy4YbHEFjwxX5VP3Ong8IwbsFVYt9tE32b
X-Received: by 2002:ae9:e313:: with SMTP id v19mr20533459qkf.153.1554718359648;
        Mon, 08 Apr 2019 03:12:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554718359; cv=none;
        d=google.com; s=arc-20160816;
        b=N3ENKXUpRabHQA0nRdq/7imWMkOrSsnUQvUaQIq0AgGMJvT6tCnYgu55MfX51o84NU
         Glcv+xYC+ppOIV+AN/pA1wFJ5lxzkDMljUYmCz1fNwpk5x9qcF8D5BLabiSY1U6IQe7P
         Qj561qwScHBpWvhs3oq/223n1sNkvUkckQurw+kQ9AAbxG+3jzEdr5ccmr3CY9qZFPT2
         aACkWKhFrTXJz89nEdjP9nh9yzJUaxZtckkUFL2h1/Pi/NCPl6OHRnILAQ1vcXEgMu9c
         LpsVz7V8awx9Nzg15PyGWz6bRgX+M3jM7Nv7qbChRdynzp4VUdxEeDbpiktF2OfMl5ko
         syYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=c1qEfMhK2jjJVhzLElZ0ixQesqaRds3kjLS7FD8LKgE=;
        b=m1emaikR9pI4XiyCGlyZloDSJN1FKIbkmaNkTcz0iU2IH9lfh0JaR7PyDLB/I0xnEb
         Yp3y4HAIFltHFNJ6IBugN9/MsR5xIR6fY+VDGQx94CT/ukdSj/13+1GQoZ+JTRVA0xDw
         xlGt78R+SrMJpzMF/Ci+mka0GmbJ/vAWViNB/etyWskdcL+M0FgTzqgjblO5cYZUiGv3
         VRjuTidPa7kUB2JVVLPZSnyc5uTjKXyx1z44zp7kcWuosIOpASeoltif41cUQ6QCX6rP
         Wtvi/7xFBNxp0JlmkFjG1HqGR2kp9Iim0byyq2MaV+dQFa1Z+anwITaH+ym1H3uHlHo5
         aoZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q46si295562qtf.237.2019.04.08.03.12.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 03:12:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BB04559460;
	Mon,  8 Apr 2019 10:12:38 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-53.ams2.redhat.com [10.36.117.53])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8293F27196;
	Mon,  8 Apr 2019 10:12:34 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	mike.travis@hpe.com,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>,
	Oscar Salvador <osalvador@suse.de>,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pavel.tatashin@microsoft.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>,
	linux-mm@kvack.org,
	dan.j.williams@intel.com,
	David Hildenbrand <david@redhat.com>
Subject: [PATCH RFC 1/3] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
Date: Mon,  8 Apr 2019 12:12:24 +0200
Message-Id: <20190408101226.20976-2-david@redhat.com>
In-Reply-To: <20190408101226.20976-1-david@redhat.com>
References: <20190408101226.20976-1-david@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 08 Apr 2019 10:12:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

By converting start and size to page granularity, we actually ignore
unaligned parts within a page instead of properly bailing out with an
error.

Signed-off-by: David Hildenbrand <david@redhat.com>
---
 mm/memory_hotplug.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f206b8b66af1..680dcc67f9d5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1070,16 +1070,11 @@ int try_online_node(int nid)
 
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
-	unsigned long block_sz = memory_block_size_bytes();
-	u64 block_nr_pages = block_sz >> PAGE_SHIFT;
-	u64 nr_pages = size >> PAGE_SHIFT;
-	u64 start_pfn = PFN_DOWN(start);
-
 	/* memory range must be block size aligned */
-	if (!nr_pages || !IS_ALIGNED(start_pfn, block_nr_pages) ||
-	    !IS_ALIGNED(nr_pages, block_nr_pages)) {
+	if (!size || !IS_ALIGNED(start, memory_block_size_bytes()) ||
+	    !IS_ALIGNED(size, memory_block_size_bytes())) {
 		pr_err("Block size [%#lx] unaligned hotplug range: start %#llx, size %#llx",
-		       block_sz, start, size);
+		       memory_block_size_bytes(), start, size);
 		return -EINVAL;
 	}
 
-- 
2.17.2

