Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E16CEC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:37:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABA7D2173C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:37:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABA7D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CF486B000E; Fri, 29 Mar 2019 05:37:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47F6C6B0269; Fri, 29 Mar 2019 05:37:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 394CB6B026A; Fri, 29 Mar 2019 05:37:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18F5F6B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:37:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c25so1251841qkl.6
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:37:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=x4XFv0lAbFU+Kaq3neb+AXZEKl0x+MJ7O2RdbVpDmiQ=;
        b=JXyzSN9MoXa3dyD/w8zBnE3rpfToDKDZqCj4pEoK56ELuQszwxkiAsBnMr4P1QDELJ
         r6OgbyAVdGSxcLERSAWYWoXlk7drUPYuX1BcpHvvIodMs5Ol+PWDzQoBG0ZLWdz3xueq
         /iDrjegwTibOtacUctXfMwH0FUOTrFPU/vc4ayWnHQ4qHpoVIdqzwW783lTDhnvC3zoc
         V3STST5vikkjLcfDFW16ov2NZiJUTrUb1Wrpav2o9sb2bX3+7Mvxb3MJ5SLGpTXy8eIp
         Q/Lprx3x6KEex+Qj7dl/pl6YLVX4vQGOExyNxUOjrAiPCxK1Fvhwd72zz2CD3M41xTDx
         qtTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5OOvBcE6ZFp9ihPAO8rBjFpYhVJRAfk/CVGQ2DEJ9FOErX+N/
	YwlVXQ8dajKJhiiwk7tK4T6qZoB0y0SIAKBSjM4To8EWlyoeMFZQzjn50RVWmsd9waWOY9epNnh
	5LsdEcBinLL/eR0QcRncn9H64/tpL7a3lYVgdeoM82Dfc0rVnVv6W/FFFme7u7J5EaA==
X-Received: by 2002:ac8:1908:: with SMTP id t8mr40805424qtj.347.1553852224877;
        Fri, 29 Mar 2019 02:37:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCEDmkOMSXPNDFWR4AQ4WuvD+B/LszpaGDDXbrRHXVbuBZYU6+J69k7A7LoXzp5eNskY2P
X-Received: by 2002:ac8:1908:: with SMTP id t8mr40805391qtj.347.1553852224350;
        Fri, 29 Mar 2019 02:37:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553852224; cv=none;
        d=google.com; s=arc-20160816;
        b=hDik6ZOIgq7+6nReuuy4d7rEyvdymIniTOuAcfZtyNV7WpxSKgE/+mISa4cZwg0rW4
         R7SK7sBjsJJIR2qR7gCNBnbExXCfd2AYYwW8PNtJWTdG9gzonIEZdhz/QlXkJK188Qsf
         ZlVgL9QjgVFZCWtq9EX4TxVhm2Z+X/gOecs4qxbtrKIkmjCTqh7NJspS9IxT6pisF5Ug
         B51XIPRFlQztDY6uldDeIQzUnjbuYtfxy8/nMCKbkowEHr0pepdN/vHLSed/zlnYzCCe
         UtIv26q29LIfnYRvwFdTthXdxxmoGy9W0UziOUDO/a1hA7tlzcQ6p9vWW8CsS5/ODsNs
         ovLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=x4XFv0lAbFU+Kaq3neb+AXZEKl0x+MJ7O2RdbVpDmiQ=;
        b=EHcNhy40m57o2vxFrtwt9A64SBslrmrvcQY0LfmbRzVGoTC03yuwn7CXBG3USV4t4i
         +58inllKE9rp/4n42/hnR11KK3pyoPU4eaGDrMsd/WV8meX/VZUtdwvrSmOxPgMVVwjH
         yVS10s2+E4bd4JgxaUWiPnx8OHnCzZYycaD6hIb4zFN/Lb7AG9h28UiVm4lxXutiDfmf
         2e57yAc8gFL1EFKJiMknodJ/msEA2fR1x1JxpCZV3dxXgUGG5kdM3xDC8XWdiPsBtGBR
         hQzsA5q6Z2adlnRCqbSGhH/ywa8hdkzhanXw1fyESVbzcJ+nchSFaGwmNi7TexfKnEct
         GLZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q24si847369qkc.190.2019.03.29.02.37.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:37:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 77886307D914;
	Fri, 29 Mar 2019 09:37:02 +0000 (UTC)
Received: from localhost (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C9D3D60BFB;
	Fri, 29 Mar 2019 09:37:01 +0000 (UTC)
Date: Fri, 29 Mar 2019 17:36:59 +0800
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rafael@kernel.org, akpm@linux-foundation.org,
	mhocko@suse.com, osalvador@suse.de, rppt@linux.ibm.com,
	willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: [PATCH v4 2/2] drivers/base/memory.c: Rename the misleading parameter
Message-ID: <20190329093659.GG7627@MiWiFi-R3L-srv>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329082915.19763-2-bhe@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 29 Mar 2019 09:37:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The input parameter 'phys_index' of memory_block_action() is actually
the section number, but not the phys_index of memory_block. This is
a relict from the past when one memory block could only contain one
section.

Rename it to start_section_nr.

Signed-off-by: Baoquan He <bhe@redhat.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 drivers/base/memory.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb8347500ce2..9ea972b2ae79 100644
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
 
-- 
2.17.2

