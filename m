Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B584C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C348720675
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:55:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oQCvYs9j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C348720675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B25A6B0003; Thu,  9 May 2019 09:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A736B0006; Thu,  9 May 2019 09:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2B6456B0007; Thu,  9 May 2019 09:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA5066B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 09:55:36 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g36so1572162edg.8
        for <linux-mm@kvack.org>; Thu, 09 May 2019 06:55:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rj8sR0p1Edqa94H02tBjaXnEUtoaRjwEJVzZPumNj1g=;
        b=N4hOA6PUPm7CHitOsH4TFbOTrRMwFYMhFD995Aw5sbIusMZcucze0/m34EtLZj63bh
         ltCg9eqw0hrVilgLeawTJK8gaEjCRCubu5HQ0pyM5eAmT5+xufuCNlkdKxElSzSp+svP
         70R0VZCGt9hWVysNlkafg+WuykXebTKLCX1xxTUM8Vzwq7RUwsAgLcey48SuBW8qZ8f5
         ZE7iwxPnq78xbKke7e2gAPBRsJufsCjaT2CEegowld0gUaIZukl8SvW/ssQY07S7Xjox
         zh1Vm2KdXjtlNS/EwWXVq1RBxdijcuCLmkOpXcyaFEuKTHE5QCAn6/ApYGCimTDs3w7J
         oREA==
X-Gm-Message-State: APjAAAUNwoGMbB8Yb+NKuut9tVTf/Zd3Jpys28TumV1g3JatIezsUGI+
	oAunKXoi2LyDma8BdfmDsYVqrsGR6M4pHAYP/0hREehptqMLhfvQtBFMAwTlmaM6hLTaSk1q6he
	D5dBJb6Sy0Em02itVWjkbWqB41krvaRoxqGs+iyN447iyc1N+WjCZqyN0ELGH0BiarA==
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr3420922ejm.185.1557410136257;
        Thu, 09 May 2019 06:55:36 -0700 (PDT)
X-Received: by 2002:a17:906:6408:: with SMTP id d8mr3420833ejm.185.1557410135046;
        Thu, 09 May 2019 06:55:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557410135; cv=none;
        d=google.com; s=arc-20160816;
        b=0Qc+yHl4a1KSGiQTfMDivRNAjQ9HOLzO3vH/t93pwVpAR2hE+/4beYt4qU1u5IoYFq
         Xj8K50BT/ddG9Hihmm6I6jDwn/kiJn9NZcSXbJsxtoiWCpBaQpN/HqacS6dF0sUHNyZf
         g5GGXq0ICpCcTZ7HwhVdgQVJdHfrQH+mtCKCqBi/2V2TH1aFnCecPWGfMK0qUBJNCZIK
         YCPY8MVLu+Rg6gSPDfeRNGjeBX8ub9hyTmP2UqJjFRuSjGOu92cUk0VDPiULPpMsA2oW
         AgRW1k5dh9H3+Qwg/cO2bB8IJi9q4mh35NRdWalrNn5eOV3LY8YLKXApveWC9nwR+Ou8
         QhDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=rj8sR0p1Edqa94H02tBjaXnEUtoaRjwEJVzZPumNj1g=;
        b=sYfcrHpSx95UiX5cgtg2wJJiEblIMM5J6H37KSLW7Vyg/680Hjvlta+isq4UYuJCeB
         t5EThrtGVoRonEbFFZn3qzmCHNVIVI0eOwyIOGJGpWk+bNacnIXEoztnqB/zqy4RZiSn
         JDuTnF2GCRXnfeQ0asQVsKfcRbE+ae4jrtrSpJXS8ELV8/r/mxstjjs3Nita7qUZtVlN
         ytgsfblzQ0Jq1iLr7l8cmXqsda+j+EBjW4z5Qpa56kE0MgAogrnb/bY26aRt/I5UkUzu
         7wb+Os3V3USEX9T0NIyOFAUxOQg0kpK0q5JytV3Lj7Clwh9WoNrB86l3qecHwYjufrok
         sUjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oQCvYs9j;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k18sor2103097ede.0.2019.05.09.06.55.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 06:55:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oQCvYs9j;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rj8sR0p1Edqa94H02tBjaXnEUtoaRjwEJVzZPumNj1g=;
        b=oQCvYs9jZqA0mKZRzCMWu05oFj2Zz17/PVNd4bwpPPpxmMr0K+ZQCs7yxqlPtfjuMy
         8OjUA2czA5H6SB9uPKPi/jS92gskpNjvYeYP/Q4yo9+o9Xrd9/e5lEK5NKwBomh3Cy8d
         txu9rR8KNjutQFiKex2oKNITF45PZElb82I9QA/6KUxfMCLsrY1lDcu5LtawuUioBTcj
         C363GL59Zdaxz2o8wF08BTrzO41fdEKqPgs6o4QzXc1PYVqQv9UpbOEWVkNzzqcmKdVj
         852r0xVwgC3ApDh6OJFtIWvfw2X6OVJBAUv3KUKUNUdncpeZkAmD/cq2XxXLjQEZfw5F
         hPxg==
X-Google-Smtp-Source: APXvYqyqamcbXYaLythnIDnP0cKrQ7Jqxn1LlTAxYUXRdkLE65y8UJdLAseURDgvrzBfIKf7YsPB9w==
X-Received: by 2002:a50:a5b4:: with SMTP id a49mr4299981edc.30.1557410134597;
        Thu, 09 May 2019 06:55:34 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id j55sm611135ede.27.2019.05.09.06.55.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 06:55:33 -0700 (PDT)
Date: Thu, 9 May 2019 13:55:33 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190509135533.6xok3v7rxxaohc77@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>Only memory to be added to the buddy and to be onlined/offlined by
>user space using memory block devices needs (and should have!) memory
>block devices.
>
>Factor out creation of memory block devices Create all devices after
>arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>because it is now effectively stale.
>
>Only after memory block devices have been added, memory can be onlined
>by user space. This implies, that memory is not visible to user space at
>all before arch_add_memory() succeeded.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
> include/linux/memory.h |  2 +-
> mm/memory_hotplug.c    | 15 ++++-----
> 3 files changed, 53 insertions(+), 34 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 6e0cb4fda179..862c202a18ca 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
> 	return 0;
> }
> 
>+static void unregister_memory(struct memory_block *memory)
>+{
>+	BUG_ON(memory->dev.bus != &memory_subsys);
>+
>+	/* drop the ref. we got via find_memory_block() */
>+	put_device(&memory->dev);
>+	device_unregister(&memory->dev);
>+}
>+
> /*
>- * need an interface for the VM to add new memory regions,
>- * but without onlining it.
>+ * Create memory block devices for the given memory area. Start and size
>+ * have to be aligned to memory block granularity. Memory block devices
>+ * will be initialized as offline.
>  */
>-int hotplug_memory_register(int nid, struct mem_section *section)
>+int hotplug_memory_register(unsigned long start, unsigned long size)
> {
>-	int ret = 0;
>+	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>+	unsigned long start_pfn = PFN_DOWN(start);
>+	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>+	unsigned long pfn;
> 	struct memory_block *mem;
>+	int ret = 0;
> 
>-	mutex_lock(&mem_sysfs_mutex);
>+	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>+	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
> 
>-	mem = find_memory_block(section);
>-	if (mem) {
>-		mem->section_count++;
>-		put_device(&mem->dev);
>-	} else {
>-		ret = init_memory_block(&mem, section, MEM_OFFLINE);
>+	mutex_lock(&mem_sysfs_mutex);
>+	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
>+		mem = find_memory_block(__pfn_to_section(pfn));
>+		if (mem) {
>+			WARN_ON_ONCE(false);

One question here, the purpose of WARN_ON_ONCE(false) is? Would we trigger
this?

>+			put_device(&mem->dev);
>+			continue;
>+		}
>+		ret = init_memory_block(&mem, __pfn_to_section(pfn),
>+					MEM_OFFLINE);
> 		if (ret)
>-			goto out;
>-		mem->section_count++;
>+			break;
>+		mem->section_count = memory_block_size_bytes() /
>+				     MIN_MEMORY_BLOCK_SIZE;

Maybe we can leverage sections_per_block variable.

                mem->section_count = sections_per_block;

>+	}
>+	if (ret) {
>+		end_pfn = pfn;
>+		for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
>+			mem = find_memory_block(__pfn_to_section(pfn));
>+			if (!mem)
>+				continue;
>+			mem->section_count = 0;
>+			unregister_memory(mem);
>+		}
> 	}

-- 
Wei Yang
Help you, Help me

