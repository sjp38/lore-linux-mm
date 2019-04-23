Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30EE9C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E241520843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 06:42:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E241520843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=profihost.ag
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 852176B0003; Tue, 23 Apr 2019 02:42:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D8D76B0006; Tue, 23 Apr 2019 02:42:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67B166B0007; Tue, 23 Apr 2019 02:42:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 168DE6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 02:42:51 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id u6so12796996wml.3
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 23:42:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MMY0ApRUeDdkE4j4nyWsTOaQzUutj1zUXePp0yJAXnU=;
        b=POrl/JUO2lCaVv1pkAQ8SpZ7pghnz2zV331WBMK0+N6mkW1KGkOtHRn/vszw67jpdT
         INjflFh18TCSJzoR7ZSqWlLRFy3S3dIMnMYDv6ySkqdD2C9uisxuBdbULC9p/yATj49S
         89EvJupTDGZ+NKzYB4e+smDEWDl2znJHaNK5t7+XF2V16HKqMDlsXubqiXEEtIu1P8If
         MuALGO2aqN5+Kd7ziqIJgYMH9JJQC9o19jFAsecsCnSqJPxMB2DnN/ZSOmi4HVTdkQm7
         UJ8SSVIZwwmLvh4c6shtGB8qo/BPQ8kCuXMIR8DvWfXfgWxyXtiSqJWiii+GFO0U1ycM
         IJ+w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
X-Gm-Message-State: APjAAAWjii87vqm671zG/gB/ALRyKergjzxR06bijKYV65ykd9QXmkaX
	Lg2osw9I4tYW6t8l6PRA8aXYBJSqmSYdCVlMUAYQlY8LfHOi5WcbxmcPhjyHpEOSU4WmJzUGcvA
	lLULEDm3fi79rAAmYsyjh9h8isGYfg5kbISO9tUwwo9MJFrRV+PPwUG+P93HU9/w=
X-Received: by 2002:adf:9f14:: with SMTP id l20mr14507911wrf.240.1556001770635;
        Mon, 22 Apr 2019 23:42:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxe/MDoy+csra0AIspmIV8THkJwdFSnxFgK9toIem1UgHkWPW801CyaGSluCyaHA71HuvRJ
X-Received: by 2002:adf:9f14:: with SMTP id l20mr14507840wrf.240.1556001769367;
        Mon, 22 Apr 2019 23:42:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556001769; cv=none;
        d=google.com; s=arc-20160816;
        b=ab7gUe1qJVNUFLk6+92JCeLlK7aIG/5vlr/yApupYoNivFuWmiEfICZ41cilXrwcOv
         gAwWgm4hWHdL7wipIveH15NTIgzZZFxQCWnn7EANq6ITvXmCYzd02zY0/29REoXPw5sw
         lJDyLYsk1pNPLGNcAWb1iZ+7IS91k8P2N9aKh+3qrloDzOZn2WtMxghp0WNl332HsoIZ
         nCmWBLnzB1GKMq8f1dx4emOfPc/YIJBWkWnkupluo2ifb/KklcObfxYUY2mYsn55si9Y
         LQEuYxSLHLb07mCxnq0lu2SzWABmwy7+yaCnJk/66uP4qMMfRLmIEOE+k5HzAKxp3Z8C
         1tuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MMY0ApRUeDdkE4j4nyWsTOaQzUutj1zUXePp0yJAXnU=;
        b=dx/OC1f13lRcjdC/lIr5OaZNQcnZxMoeFHX4q2FjvVqNqFO1747GtIy7Vu74fTI+Qf
         mM8X5H3EWPH3iIHbwstIVmRMZNGxRKIErJ9XcJ87m8Ayh/VF6yGEDsygHluhbPpcoegN
         xlwvk6jdITYcECL5044VYO/bHy2Niq6xaU2knTa/EBeO+GtcT+nmsxsj7qM/mpM6MqEc
         XElcdEfPuCSaMjGtlNck60JOCTTMLjaV6HMg0K95855cUC+L4DY43QP9B67pWIw7QUPt
         TsYy3h2ZnJvGDUrCdDioM93A0tk2YoHJE18HuR57pptRMW/XlyY0coWfZuapJmaARCYW
         Grpg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: from cloud1-vm154.de-nserver.de (cloud1-vm154.de-nserver.de. [178.250.10.56])
        by mx.google.com with ESMTPS id j6si11534042wrn.331.2019.04.22.23.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Apr 2019 23:42:49 -0700 (PDT)
Received-SPF: neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) client-ip=178.250.10.56;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 178.250.10.56 is neither permitted nor denied by best guess record for domain of s.priebe@profihost.ag) smtp.mailfrom=s.priebe@profihost.ag
Received: (qmail 13401 invoked from network); 23 Apr 2019 08:42:48 +0200
X-Fcrdns: No
Received: from phoffice.de-nserver.de (HELO [10.11.11.165]) (185.39.223.5)
  (smtp-auth username hostmaster@profihost.com, mechanism plain)
  by cloud1-vm154.de-nserver.de (qpsmtpd/0.92) with (ECDHE-RSA-AES256-GCM-SHA384 encrypted) ESMTPSA; Tue, 23 Apr 2019 08:42:48 +0200
Subject: Re: debug linux kernel memory management / pressure
To: Vlastimil Babka <vbabka@suse.cz>, "linux-mm@kvack.org"
 <linux-mm@kvack.org>
Cc: l.roehrs@profihost.ag,
 Daniel Aberger - Profihost AG <d.aberger@profihost.ag>,
 "n.fahldieck@profihost.ag" <n.fahldieck@profihost.ag>,
 Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
References: <36329138-4a6f-9560-b36c-02dc528a8e12@profihost.ag>
 <3c98c75c-b554-499e-d42e-8b9286f3176b@profihost.ag>
 <2b0cd84c-b5e5-033c-3bae-e108b038209b@suse.cz>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <7cc0592c-228b-6e4b-0410-552ea5e08329@profihost.ag>
Date: Tue, 23 Apr 2019 08:42:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <2b0cd84c-b5e5-033c-3bae-e108b038209b@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-User-Auth: Auth by hostmaster@profihost.com through 185.39.223.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Vlastimil,

sorry for the late reply i was on holiday.

Am 05.04.19 um 12:37 schrieb Vlastimil Babka:
> On 3/29/19 10:41 AM, Stefan Priebe - Profihost AG wrote:
>> Hi,
>>
>> nobody an idea? I had another system today:
> 
> Well, isn't it still the same thing as we discussed in last autumn?
> You did report success with the ill-fated patch "mm: thp:  relax __GFP_THISNODE
> for MADV_HUGEPAGE mappings", or not?

No it's not. Last year those were KVM Host machines. These time it's a
LAMP machine. But i think i'll upgrade to 4.19.36 LTS and see if that
fixes the problem.

Thanks!

> 
>> # cat /proc/meminfo
>> MemTotal:       131911684 kB
>> MemFree:        25734836 kB
>> MemAvailable:   78158816 kB
>> Buffers:            2916 kB
>> Cached:         20650184 kB
>> SwapCached:       544016 kB
>> Active:         58999352 kB
>> Inactive:       10084060 kB
>> Active(anon):   43412532 kB
>> Inactive(anon):  5583220 kB
>> Active(file):   15586820 kB
>> Inactive(file):  4500840 kB
>> Unevictable:       35032 kB
>> Mlocked:           35032 kB
>> SwapTotal:       3905532 kB
>> SwapFree:              0 kB
>> Dirty:              1048 kB
>> Writeback:         20144 kB
>> AnonPages:      47923392 kB
>> Mapped:           775376 kB
>> Shmem:            561420 kB
>> Slab:           35798052 kB
>> SReclaimable:   34309112 kB
> 
> That's rather significant. Got a /proc/slabinfo from such system state?
> 
>> SUnreclaim:      1488940 kB
>> KernelStack:       42160 kB
>> PageTables:       248008 kB
>> NFS_Unstable:          0 kB
>> Bounce:                0 kB
>> WritebackTmp:          0 kB
>> CommitLimit:    69861372 kB
>> Committed_AS:   100328892 kB
>> VmallocTotal:   34359738367 kB
>> VmallocUsed:           0 kB
>> VmallocChunk:          0 kB
>> HardwareCorrupted:     0 kB
>> AnonHugePages:  19177472 kB
>> ShmemHugePages:        0 kB
>> ShmemPmdMapped:        0 kB
>> HugePages_Total:       0
>> HugePages_Free:        0
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:       2048 kB
>> DirectMap4k:      951376 kB
>> DirectMap2M:    87015424 kB
>> DirectMap1G:    48234496 kB
>>
>> # cat /proc/buddyinfo
>> Node 0, zone      DMA      1      0      0      0      2      1      1
>>     0      1      1      3
>> Node 0, zone    DMA32    372    418    403    395    371    322    262
>>   179    114      0      0
>> Node 0, zone   Normal  89147  96397  76496  56407  41671  29289  18142
>> 10278   4075      0      0
>> Node 1, zone   Normal 113266      0      1      1      1      1      1
>>     1      1      0      0
> 
> Node 1 seems quite fragmented. Again from last year I recall somebody (was it
> you?) capturing a larger series of snapshots where we saw a Sreclaimable rise
> due to some overnight 'find /' activity inflating dentry/inode caches which then
> got slowly reclaimed, but memory remained fragmented until enough of slab was
> reclaimed, and compaction couldn't help. drop_caches did help. Looks like this
> might be the same case. Add in something that tries to get large-order
> allocations on node 1 (e.g. with __GFP_THISNODE) and overreclaim will happen.
> 
>> But with high PSI / memory pressure values above 10-30.
>>
>> Greets,
>> Stefan
>> Am 27.03.19 um 11:56 schrieb Stefan Priebe - Profihost AG:
>>> Hello list,
>>>
>>> i hope this is the right place to ask. If not i would be happy to point
>>> me to something else.
>>>
>>> I'm seeing the following behaviour on some of our hosts running a SLES
>>> 15 kernel (kernel v4.12 as it's base) but i don't think it's related to
>>> the kernel.
>>>
>>> At some "random" interval - mostly 3-6 weeks of uptime. Suddenly mem
>>> pressure rises and the linux cache (Cached: /proc/meminfo) drops from
>>> 12G to 3G. After that io pressure rises most probably due to low cache.
>>> But at the same time i've MemFree und MemAvailable at 19-22G.
>>>
>>> Why does this happen? How can i debug this situation? I would expect
>>> that the page / file cache never drops if there is so much free mem.
>>>
>>> Thanks a lot for your help.
>>>
>>> Greets,
>>> Stefan
>>>
>>> Not sure whether needed but these are the vm. kernel settings:
>>> vm.admin_reserve_kbytes = 8192
>>> vm.block_dump = 0
>>> vm.compact_unevictable_allowed = 1
>>> vm.dirty_background_bytes = 0
>>> vm.dirty_background_ratio = 10
>>> vm.dirty_bytes = 0
>>> vm.dirty_expire_centisecs = 3000
>>> vm.dirty_ratio = 20
>>> vm.dirty_writeback_centisecs = 500
>>> vm.dirtytime_expire_seconds = 43200
>>> vm.drop_caches = 0
>>> vm.extfrag_threshold = 500
>>> vm.hugepages_treat_as_movable = 0
>>> vm.hugetlb_shm_group = 0
>>> vm.laptop_mode = 0
>>> vm.legacy_va_layout = 0
>>> vm.lowmem_reserve_ratio = 256   256     32      1
>>> vm.max_map_count = 65530
>>> vm.memory_failure_early_kill = 0
>>> vm.memory_failure_recovery = 1
>>> vm.min_free_kbytes = 393216
>>> vm.min_slab_ratio = 5
>>> vm.min_unmapped_ratio = 1
>>> vm.mmap_min_addr = 65536
>>> vm.mmap_rnd_bits = 28
>>> vm.mmap_rnd_compat_bits = 8
>>> vm.nr_hugepages = 0
>>> vm.nr_hugepages_mempolicy = 0
>>> vm.nr_overcommit_hugepages = 0
>>> vm.nr_pdflush_threads = 0
>>> vm.numa_zonelist_order = default
>>> vm.oom_dump_tasks = 1
>>> vm.oom_kill_allocating_task = 0
>>> vm.overcommit_kbytes = 0
>>> vm.overcommit_memory = 0
>>> vm.overcommit_ratio = 50
>>> vm.page-cluster = 3
>>> vm.panic_on_oom = 0
>>> vm.percpu_pagelist_fraction = 0
>>> vm.stat_interval = 1
>>> vm.swappiness = 50
>>> vm.user_reserve_kbytes = 131072
>>> vm.vfs_cache_pressure = 100
>>> vm.watermark_scale_factor = 10
>>> vm.zone_reclaim_mode = 0
>>>
>>
> 

