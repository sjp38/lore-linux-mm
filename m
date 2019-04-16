Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECA94C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 10:12:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7032206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 10:12:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7032206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 333296B0003; Tue, 16 Apr 2019 06:12:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BEF66B0006; Tue, 16 Apr 2019 06:12:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AC3E6B0007; Tue, 16 Apr 2019 06:12:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA8CE6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 06:12:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o3so3795391edr.6
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 03:12:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=oCE1xoQqbrmaP4N1dyiQ/MVIEEAO7dzGhADbisxHvoc=;
        b=dq4F5AyMBcU6BfCgaoJX6p0CgPXCKdNeU81u3H3sHzUylwZiY29aVAMmvP3+yd0B6Q
         UYXGI7WvukR2BQiQp7qej47nkfu5wkmbK2q1wYe1J3UU7ZSH2H8SKD8m7vvk0dt/saqE
         QPPf0zuxks/XyLxDfRxPzY3AsDExs+sg3BSvkWSChDf0yVVP6qmD+lwldhVAr+8fwWV8
         6ujwvfeJJ7oGTd0hb+S48skHo4hQv79LHowm63jzKXz75lc+SmHv6Plrs4QRGkXDg+YJ
         qYItgF1vLYAc1orsAvMIpcGPeIhwXsY6Hf4F5+QLqMP6gajGnYD06PU3m2iIxM4HCIHd
         DY6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUn7ahBOoaxcs7uhwxVF7NvGBhEuNtUjDVHVulh8VhHUD5pcZwz
	4dYt/EFRZdn3qku44a7TMdBfznkA1+WH1qD4cjknNTOIKj6+AhfOzh2qtCw5Hd0ZVS9cc0annkl
	hMXaRuv/ac9fR6902VU73Y2FGSCdP4QnbAWk+ZC0n/gF04xMyXqhm8ODP/BmxPMEgug==
X-Received: by 2002:a17:906:c9c6:: with SMTP id hk6mr43986966ejb.113.1555409569223;
        Tue, 16 Apr 2019 03:12:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRelgUrxhg9IZCRkFba74LiZ23/ul4eEXQRFJ5JCmlM573vpj2dsMNE0ylHaGJl9zR9nhZ
X-Received: by 2002:a17:906:c9c6:: with SMTP id hk6mr43986889ejb.113.1555409567432;
        Tue, 16 Apr 2019 03:12:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555409567; cv=none;
        d=google.com; s=arc-20160816;
        b=YhLz3EgRSlaYzcwQY2nIWoKggCa74ZOzsDXLT+b65/S3Nsio/+DGJQ06CudylUqgZz
         CruqprDvmMhgPffX85OEIRy7NDcL00DEaqM2QYQ6n/EzLqyLOMtHVkzqY77uhu+sjQW3
         UwDOOFF+7UQQaLpbHXU1R3a1ZqIHcFL9szB7VytAKQhcO+hqK00L11whxtpJa/FpcSyE
         /yKf+pPlyTh56lGXJ7xdHeNu60mWT6noPmOQEmBT1sPY1bAfMfm/DR2+hm+DXjY7ID1O
         QGKyrmbwaJbpz8jmVx3pWS/uizls6iRYbQeyo10rCqdBpxJ5z4c8wSH/QvNGdhc8ZkeO
         q1wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=oCE1xoQqbrmaP4N1dyiQ/MVIEEAO7dzGhADbisxHvoc=;
        b=RCz4EBGU9Lyzfg8zZcU8uR1I/uQAsj3fhw/okaAxrktIKGkKiCFdpAs06azcTnXXK/
         /HT8zCK501no7jO3DG3RdMlH4NsHk0Bxy1f6wUCikdZYmzMhby+PtjpONtBw+cGZSV4i
         dNW8RZsxjaWAFqhyrMmHTyiiiOAZyJ0CzqSZS26S5KSwzV6B+QWuUmfelEZV2XbszUBC
         zAjMU4Gru2DdjJlt/rKwzfBWrg1/Yv3TTYYUS9bd53HTimBXLawhy0l14WlfiSazzl3g
         OBR5AK6b0ovce3ncCiDlyji+YOLdMLfN1NzefRS6FTfjHTl/TPYsLEd6S+Yjj0uAyuEv
         fUQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b12si8476480ejq.331.2019.04.16.03.12.46
        for <linux-mm@kvack.org>;
        Tue, 16 Apr 2019 03:12:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6A49E80D;
	Tue, 16 Apr 2019 03:12:45 -0700 (PDT)
Received: from [10.162.42.238] (p8cg001049571a15.blr.arm.com [10.162.42.238])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1DE703F68F;
	Tue, 16 Apr 2019 03:12:38 -0700 (PDT)
Subject: Re: [PATCH V2 1/2] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
References: <1555221553-18845-1-git-send-email-anshuman.khandual@arm.com>
 <1555221553-18845-2-git-send-email-anshuman.khandual@arm.com>
 <bbca320f-efc6-0872-b4f3-5e1d49fdc239@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <ade861f9-d421-0d56-517c-d5c024870a1f@arm.com>
Date: Tue, 16 Apr 2019 15:42:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <bbca320f-efc6-0872-b4f3-5e1d49fdc239@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/15/2019 07:28 PM, David Hildenbrand wrote:
> On 14.04.19 07:59, Anshuman Khandual wrote:
>> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
>> entries between memory block and node. It first checks pfn validity with
>> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
>> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
>>
>> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
>> which scans all mapped memblock regions with memblock_is_map_memory(). This
>> creates a problem in memory hot remove path which has already removed given
>> memory range from memory block with memblock_[remove|free] before arriving
>> at unregister_mem_sect_under_nodes(). Hence get_nid_for_pfn() returns -1
>> skipping subsequent sysfs_remove_link() calls leaving node <-> memory block
>> sysfs entries as is. Subsequent memory add operation hits BUG_ON() because
>> of existing sysfs entries.
>>
>> [   62.007176] NUMA: Unknown node for memory at 0x680000000, assuming node 0
>> [   62.052517] ------------[ cut here ]------------
>> [   62.053211] kernel BUG at mm/memory_hotplug.c:1143!
>> [   62.053868] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
>> [   62.054589] Modules linked in:
>> [   62.054999] CPU: 19 PID: 3275 Comm: bash Not tainted 5.1.0-rc2-00004-g28cea40b2683 #41
>> [   62.056274] Hardware name: linux,dummy-virt (DT)
>> [   62.057166] pstate: 40400005 (nZcv daif +PAN -UAO)
>> [   62.058083] pc : add_memory_resource+0x1cc/0x1d8
>> [   62.058961] lr : add_memory_resource+0x10c/0x1d8
>> [   62.059842] sp : ffff0000168b3ce0
>> [   62.060477] x29: ffff0000168b3ce0 x28: ffff8005db546c00
>> [   62.061501] x27: 0000000000000000 x26: 0000000000000000
>> [   62.062509] x25: ffff0000111ef000 x24: ffff0000111ef5d0
>> [   62.063520] x23: 0000000000000000 x22: 00000006bfffffff
>> [   62.064540] x21: 00000000ffffffef x20: 00000000006c0000
>> [   62.065558] x19: 0000000000680000 x18: 0000000000000024
>> [   62.066566] x17: 0000000000000000 x16: 0000000000000000
>> [   62.067579] x15: ffffffffffffffff x14: ffff8005e412e890
>> [   62.068588] x13: ffff8005d6b105d8 x12: 0000000000000000
>> [   62.069610] x11: ffff8005d6b10490 x10: 0000000000000040
>> [   62.070615] x9 : ffff8005e412e898 x8 : ffff8005e412e890
>> [   62.071631] x7 : ffff8005d6b105d8 x6 : ffff8005db546c00
>> [   62.072640] x5 : 0000000000000001 x4 : 0000000000000002
>> [   62.073654] x3 : ffff8005d7049480 x2 : 0000000000000002
>> [   62.074666] x1 : 0000000000000003 x0 : 00000000ffffffef
>> [   62.075685] Process bash (pid: 3275, stack limit = 0x00000000d754280f)
>> [   62.076930] Call trace:
>> [   62.077411]  add_memory_resource+0x1cc/0x1d8
>> [   62.078227]  __add_memory+0x70/0xa8
>> [   62.078901]  probe_store+0xa4/0xc8
>> [   62.079561]  dev_attr_store+0x18/0x28
>> [   62.080270]  sysfs_kf_write+0x40/0x58
>> [   62.080992]  kernfs_fop_write+0xcc/0x1d8
>> [   62.081744]  __vfs_write+0x18/0x40
>> [   62.082400]  vfs_write+0xa4/0x1b0
>> [   62.083037]  ksys_write+0x5c/0xc0
>> [   62.083681]  __arm64_sys_write+0x18/0x20
>> [   62.084432]  el0_svc_handler+0x88/0x100
>> [   62.085177]  el0_svc+0x8/0xc
>>
>> Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
>> problem on arm64 as pfn_valid() behaves correctly and returns positive
>> as memblock for the address range still exists. arch_remove_memory()
>> removes applicable memory sections from zone with __remove_pages() and
>> tears down kernel linear mapping. Removing memblock regions afterwards
>> is safe because there is no other memblock (bootmem) allocator user that
>> late. So nobody is going to allocate from the removed range just to blow
>> up later. Also nobody should be using the bootmem allocated range else
>> we wouldn't allow to remove it. So reordering is indeed safe.
>>
>> Acked-by: Michal Hocko <mhocko@suse.com>
>> Reviewed-by: David Hildenbrand <david@redhat.com>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  mm/memory_hotplug.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 0082d69..71d0d79 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1872,11 +1872,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>>  
>>  	/* remove memmap entry */
>>  	firmware_map_remove(start, start + size, "System RAM");
>> +	arch_remove_memory(nid, start, size, NULL);
>>  	memblock_free(start, size);
>>  	memblock_remove(start, size);
>>  
>> -	arch_remove_memory(nid, start, size, NULL);
>> -
>>  	try_offline_node(nid);
>>  
>>  	mem_hotplug_done();
>>
> 
> This will conflict with a patch I posted, but should be easy
> to fix. We should stick to the reverse order in which things are added,
> which is what you are doing here.
> 
> commit 5af92d15e179557143d54bde477f7e45fc5c0fca
> Author: David Hildenbrand <david@redhat.com>
> Date:   Wed Apr 10 11:02:26 2019 +1000
> 
>     mm/memory_hotplug: release memory resource after arch_remove_memory()
> 

Got it. My current WIP branch is on the following. We should be able to fix
it during merge.

git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git for-next/core


