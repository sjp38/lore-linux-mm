Return-Path: <SRS0=4n/l=R3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F707C43381
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 06:48:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD1902148D
	for <linux-mm@archiver.kernel.org>; Sun, 24 Mar 2019 06:48:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD1902148D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54F976B0003; Sun, 24 Mar 2019 02:48:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D43E6B0006; Sun, 24 Mar 2019 02:48:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39D9E6B0007; Sun, 24 Mar 2019 02:48:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFDF96B0003
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 02:48:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z98so2604731ede.3
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 23:48:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=W/6In+afCK79b2ULZyPSvVvSn9S7i6Db4YqUHTdc8FQ=;
        b=J2MoEWcsEx/kmTn2kc1y0THt6xzbFHDWRn95iOj4hCdaMf1s/bgcY2uWo9bVgTWAdl
         CjFs5+sMMSyKC3AdEz4blfNXYrImc0r8z/M1FMsskDzuFLhtr86ROq9yCqNv7ozhHD2F
         yfv9sZg+PqPpfYH9TaOiSIFpmSO2tpROETxkgAZtMBdSmmO4idRmQAOvF1x+DGVMB2HJ
         hTKfL9Zj034y2wFZr67PyltOKdtKuu2T/MZEtBCa7JFtrNubmNtnsx13oLqRuDw+LI7r
         jGRyk3KON0ftC8Nl5fdMxM0FhfXlIgHl5GNslw4WxxxD32kO9kfpCHHPlcrL+gFVVweh
         zdmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXu2D9XVNqSUwD/DzBtAcjCMtP7GqabbOgsU6QhXjmBmyPkRX0W
	O1OAa6vbm6V/LO1xgmM08x80d3xNsQLYEwK8YNXM//z8ACg+p2x8Ur2qZ2uolDji40orgyW442i
	TPJvzkdHWt+HEE0r2bYgh/weXAnPybl/3/bpLXUgpVtji0oSeYiwEfGFIh6uBrj9PFA==
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr10315790ejb.106.1553410115257;
        Sat, 23 Mar 2019 23:48:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzstJaSCWsekR0YdJcmH9x6jybV2+C11JGIT/Z/NbPGCm852LApSlXjK7LqnOyQbiiXcrQI
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr10315750ejb.106.1553410114117;
        Sat, 23 Mar 2019 23:48:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553410114; cv=none;
        d=google.com; s=arc-20160816;
        b=xQNfqpxkP8G3qLyBixnCzFte3Hiu8za+C4GDW4Zl7qOV3OuwHkdaNn4fEUVVJvHVPC
         V3NwHN6gynkx7S8J7WDg6QbZpSOU03wPgVW+9hRVLTMHL9RmkaSxG0Ba/e1MqipPc/qu
         c6v3qmmbfx/c0VlUcGTyhIinK09xWkSHGdKAPrV6MvuJnWlB9EY1PjpEw3EbgI/1v9m3
         wg29CdHuZAnRQMv/+5eTeNFby6lvoPRers7nVEewMAyu4CF4OAQ2NPDNi+098wM7dcGS
         m/FLY/ZX7JBAp6QQuKSEZ0IRLehrwnHn5GqA+VuRCqE3mi4TXvuyOyl01QDXIizKoItE
         Ij5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=W/6In+afCK79b2ULZyPSvVvSn9S7i6Db4YqUHTdc8FQ=;
        b=vOHZ4PEwz6PQAYb73wFJIKD3BuSN8JC1Rix5Xx8+8Cu/gESBZPmaXGSpaO3HTkievu
         xQz2Vddma+L/g/FJ+8YuTnLQhu6J7pzh3MqpZmNxhWEp3/CXSr0g8JFqxUqoraJW1Ug3
         EgqeySnbKM8X6KMajw46I9pIZDONQ20/NRW1CJkLjvvMl1PsWPK4hMjcwmYbl72i2PBe
         Yumj4oA/zk8uV6v4bGc0PqiNXlq4BnjvfficLb2Nboz96zJAj581o+foyUjy/7Qi42+e
         ItkAjI4QBT9nHtGKIrwwvREmXp8eWbVc52mWa3aLz+hdJFH0o7s7yYpOrlxzcprqt++K
         veRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d8si1609387edb.190.2019.03.23.23.48.33
        for <linux-mm@kvack.org>;
        Sat, 23 Mar 2019 23:48:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 620B180D;
	Sat, 23 Mar 2019 23:48:32 -0700 (PDT)
Received: from [10.162.41.135] (p8cg001049571a15.blr.arm.com [10.162.41.135])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 338E43F575;
	Sat, 23 Mar 2019 23:48:28 -0700 (PDT)
Subject: Re: [PATCH v2 4/5] mm, memory-hotplug: Rework
 unregister_mem_sect_under_nodes
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pavel.tatashin@microsoft.com,
 jglisse@redhat.com, Jonathan.Cameron@huawei.com, rafael@kernel.org,
 david@redhat.com, linux-mm@kvack.org, Oscar Salvador <osalvador@suse.com>
References: <20181127162005.15833-1-osalvador@suse.de>
 <20181127162005.15833-5-osalvador@suse.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <45d6b6ed-ae84-f2d5-0d57-dc2e28938ce0@arm.com>
Date: Sun, 24 Mar 2019 12:18:26 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20181127162005.15833-5-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 11/27/2018 09:50 PM, Oscar Salvador wrote:
> From: Oscar Salvador <osalvador@suse.com>
> 
> This tries to address another issue about accessing
> unitiliazed pages.
> 
> Jonathan reported a problem [1] where we can access steal pages
> in case we hot-remove memory without onlining it first.
> 
> This time is in unregister_mem_sect_under_nodes.
> This function tries to get the nid from the pfn and then
> tries to remove the symlink between mem_blk <-> nid and vice versa.
> 
> Since we already know the nid in remove_memory(), we can pass
> it down the chain to unregister_mem_sect_under_nodes.
> There we can just remove the symlinks without the need
> to look into the pages.
> 
> This also allows us to cleanup unregister_mem_sect_under_nodes.
> 
> [1] https://www.spinics.net/lists/linux-mm/msg161316.html
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> ---
>  drivers/base/memory.c  |  9 ++++-----
>  drivers/base/node.c    | 39 ++++++---------------------------------
>  include/linux/memory.h |  2 +-
>  include/linux/node.h   |  9 ++++-----
>  mm/memory_hotplug.c    |  2 +-
>  5 files changed, 16 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 0e5985682642..3d8c65d84bea 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -744,8 +744,7 @@ unregister_memory(struct memory_block *memory)
>  	device_unregister(&memory->dev);
>  }
>  
> -static int remove_memory_section(unsigned long node_id,
> -			       struct mem_section *section, int phys_device)
> +static int remove_memory_section(unsigned long nid, struct mem_section *section)
>  {
>  	struct memory_block *mem;
>  
> @@ -759,7 +758,7 @@ static int remove_memory_section(unsigned long node_id,
>  	if (!mem)
>  		goto out_unlock;
>  
> -	unregister_mem_sect_under_nodes(mem, __section_nr(section));
> +	unregister_mem_sect_under_nodes(nid, mem);
>  
>  	mem->section_count--;
>  	if (mem->section_count == 0)
> @@ -772,12 +771,12 @@ static int remove_memory_section(unsigned long node_id,
>  	return 0;
>  }
>  
> -int unregister_memory_section(struct mem_section *section)
> +int unregister_memory_section(int nid, struct mem_section *section)
>  {
>  	if (!present_section(section))
>  		return -EINVAL;
>  
> -	return remove_memory_section(0, section, 0);
> +	return remove_memory_section(nid, section);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 86d6cd92ce3d..0858f7f3c7cd 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -453,40 +453,13 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  	return 0;
>  }
>  
> -/* unregister memory section under all nodes that it spans */
> -int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
> -				    unsigned long phys_index)
> +/* Remove symlink between node <-> mem_blk */
> +void unregister_mem_sect_under_nodes(int nid, struct memory_block *mem_blk)
>  {
> -	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
> -	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> -
> -	if (!mem_blk) {
> -		NODEMASK_FREE(unlinked_nodes);
> -		return -EFAULT;
> -	}
> -	if (!unlinked_nodes)
> -		return -ENOMEM;
> -	nodes_clear(*unlinked_nodes);
> -
> -	sect_start_pfn = section_nr_to_pfn(phys_index);
> -	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> -	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		int nid;
> -
> -		nid = get_nid_for_pfn(pfn);
> -		if (nid < 0)
> -			continue;
> -		if (!node_online(nid))
> -			continue;
> -		if (node_test_and_set(nid, *unlinked_nodes))
> -			continue;
> -		sysfs_remove_link(&node_devices[nid]->dev.kobj,
> -			 kobject_name(&mem_blk->dev.kobj));
> -		sysfs_remove_link(&mem_blk->dev.kobj,
> -			 kobject_name(&node_devices[nid]->dev.kobj));
> -	}
> -	NODEMASK_FREE(unlinked_nodes);
> -	return 0;
> +	sysfs_remove_link(&node_devices[nid]->dev.kobj,
> +			kobject_name(&mem_blk->dev.kobj));
> +	sysfs_remove_link(&mem_blk->dev.kobj,
> +			kobject_name(&node_devices[nid]->dev.kobj));

Hello Oscar,

Passing down node ID till unregister_mem_sect_under_nodes() solves the problem of
querying struct page for nid but the current code assumes that the pfn range for
any given memory section can have different node IDs. Hence it scans over the
section and try to remove all possible node <---> memory block sysfs links.

I am just wondering is that assumption even correct ? Can we really have a memory
section which belongs to different nodes ? Is that even possible.

- Anshuman

