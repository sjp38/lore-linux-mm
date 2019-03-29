Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEA99C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:43:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B0A52183F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 14:43:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B0A52183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E89D6B026A; Fri, 29 Mar 2019 10:43:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397C26B026B; Fri, 29 Mar 2019 10:43:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25F666B026C; Fri, 29 Mar 2019 10:43:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 01B2E6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:43:03 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 77so1953747qkd.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 07:43:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=HihZu04+jHdkzViq+p/HLyEzDw4jRx+mopo/N+qb8a4=;
        b=gSlvwgf0TVooLADKjclaopmtsvAe/BgmgrbXgpzwqyJNc+K8iN/hdExOg5GUjGlL/g
         TuxdpO+JBnSIEu3tH6Ab+m5K9l0aVKnYdyA3Fz+xBlgl5DkOEzPnroZ6ZuWt/jtxclqm
         JrvEAR32hX6PXAmgpLwwgrGNy8zndVC1cMQj0kTlzta11Z01c1vX9lPhhI65XSNGGWLt
         Hglwt/uLRnVEqEq74snV6ziP+7Ckdzlc3nbJMt2e5x8jIZlvvN9VrsL/CK9oSzQGenae
         fdVyA1NA9SMZPEh6sdTiqHpmQtj8weoBORkCrUHfPahq0V+aMdgAY4rXv0M/2GTSAk5t
         dDZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW6VxBBemISFGuCyQ5nT0TSrqdWIO1vqn7eBP6/P0yYuHQvj8tY
	JH4fsvYpmcgfiDfgQgkyhX9DzfVN/G9wO2X7MKdts421t6hWbUaWB3deqXp8914IVTO3BYBYWFF
	2o5RejLGFT742ijTvjLXzUqmmsNpmUPM2At1fpSsK9OitjVro4GiDSlMEGqm6Ozy5CA==
X-Received: by 2002:a37:6fc5:: with SMTP id k188mr38274140qkc.24.1553870582767;
        Fri, 29 Mar 2019 07:43:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPIQlgEW0IWNGi30170Dr6cNKIuHKeDARWD01p3yCoTfiFLrhrdFlxSBhUu5q6AoKiNYqW
X-Received: by 2002:a37:6fc5:: with SMTP id k188mr38274058qkc.24.1553870581496;
        Fri, 29 Mar 2019 07:43:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553870581; cv=none;
        d=google.com; s=arc-20160816;
        b=hftHWFy7pXQcUSENBzjC/u0eWaH8S4V7aVAzsWRiPro2+i3qogZjFstMFYr4zBwPia
         6bLwmdzvcwfhnM2WMfN8b4+1zNdYktOk3uBU0FA8QkLkcj8ZyHLIE+eTHQXWVdgHRrls
         yGPmR16lGIuNni5ug6/yzbrsQZrkWwkC0lxI6fvO3n/sDH3mpCmdGSdhn2aLuacCWmh8
         2a1nJ7LRJFpBWqZthipNx8N0bGPFdqoHVwEGx2ZTwMDke+8/ZgEat9hAcZ9wb1v18dZZ
         +bdkj5a19h01yPiHVav72qHhwxNlsPfP84zp1ZivgdCnhNOnBM7vXLT/UllElykQtZ4B
         pJyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=HihZu04+jHdkzViq+p/HLyEzDw4jRx+mopo/N+qb8a4=;
        b=xaPLEh5p5SfLvRwK88JTbZbd9ivaN+5CJlnKEBHs6NN9ebTbexKUMV/ewvZSVpNB0X
         Go37Qsj+7OSyxIzAzXgw6fKID9Hnap2KWgv4JrezCyc3jst7I6+Xcsp5/vUhcFweW6p1
         roxGbtfYvSCF0YfuNB+6OyIeAAixaLcIJGwOg1LaU+YrYpJTXF8vSkrOOxmq9QBqurur
         Lp8ubqKph8Y0ApZujYpS5rNV33O0dKHUj3X0xecPKo4/cTQIMD04AHGP41L5YMT0NmLc
         MtLrHdKGiN+f+IN7Fc44sz3nr9EDGgG9tsPA8g0WmcknXxPR1UAVMK8t70AWkktPwGcG
         k5hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h14si1217608qvc.98.2019.03.29.07.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 07:43:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BE4523086207;
	Fri, 29 Mar 2019 14:43:00 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6DB9E5C226;
	Fri, 29 Mar 2019 14:42:56 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	akpm@linux-foundation.org,
	willy@infradead.org,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v4 2/2] drivers/base/memory.c: Clean up relicts in function parameters
Date: Fri, 29 Mar 2019 22:42:50 +0800
Message-Id: <20190329144250.14315-2-bhe@redhat.com>
In-Reply-To: <20190329144250.14315-1-bhe@redhat.com>
References: <20190329144250.14315-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 29 Mar 2019 14:43:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The input parameter 'phys_index' of memory_block_action() is actually
the section number, but not the phys_index of memory_block. This is
a relict from the past when one memory block could only contain one
section. Rename it to start_section_nr.

And also in remove_memory_section(), the 'node_id' and 'phys_device'
are not used by anyone. Remove them.

Signed-off-by: Baoquan He <bhe@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
---
v3->v4:
  Remove useless parameters in remove_memory_section().

 drivers/base/memory.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb8347500ce2..d9ebb89816f7 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -231,13 +231,14 @@ static bool pages_correctly_probed(unsigned long start_pfn)
  * OK to have direct references to sparsemem variables in here.
  */
 static int
-memory_block_action(unsigned long phys_index, unsigned long action, int online_type)
+memory_block_action(unsigned long start_section_nr, unsigned long action,
+		    int online_type)
 {
 	unsigned long start_pfn;
 	unsigned long nr_pages = PAGES_PER_SECTION * sections_per_block;
 	int ret;
 
-	start_pfn = section_nr_to_pfn(phys_index);
+	start_pfn = section_nr_to_pfn(start_section_nr);
 
 	switch (action) {
 	case MEM_ONLINE:
@@ -251,7 +252,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 		break;
 	default:
 		WARN(1, KERN_WARNING "%s(%ld, %ld) unknown action: "
-		     "%ld\n", __func__, phys_index, action, action);
+		     "%ld\n", __func__, start_section_nr, action, action);
 		ret = -EINVAL;
 	}
 
@@ -738,8 +739,7 @@ unregister_memory(struct memory_block *memory)
 	device_unregister(&memory->dev);
 }
 
-static int remove_memory_section(unsigned long node_id,
-			       struct mem_section *section, int phys_device)
+static int remove_memory_section(struct mem_section *section)
 {
 	struct memory_block *mem;
 
@@ -771,7 +771,7 @@ int unregister_memory_section(struct mem_section *section)
 	if (!present_section(section))
 		return -EINVAL;
 
-	return remove_memory_section(0, section, 0);
+	return remove_memory_section(section);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
-- 
2.17.2

