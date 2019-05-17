Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2118C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 11:42:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1688F20815
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 11:42:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="ZeBCvFex"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1688F20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F0F66B0007; Fri, 17 May 2019 07:42:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97B726B0008; Fri, 17 May 2019 07:42:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81DE06B000A; Fri, 17 May 2019 07:42:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 126FA6B0007
	for <linux-mm@kvack.org>; Fri, 17 May 2019 07:42:27 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v18so997964lja.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 04:42:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DuAu62W6AZc9BLNWjfPvq/8pURNd6AGdCvHd+9yn0vQ=;
        b=djmpnLLxRzL9NXoao1WIsGzyWlCxM/16mLzSzZ4Wm5KGScSSmB2FJmavuWhjfXb8k1
         lA/1oWz+BZP17wysotZ8a8Jl3Hym7WwxoLuO52ko24T//cFGvROK4thbpG8rFaYl47+V
         h2JroW/1pWx242xnKhaDCP5/5sPagxLeNA6+XvwaW5g4qtOzLgg/PVGw/V6ws/F+4XX3
         YqzZOyXP/Gxb+wWUULEhtZCfigsx16JXGlhziTegfzYLoOtu1YguYvkQ0fjf/dPum/2t
         6QHJkBBMwA7Cn4GgjVoveWBf0IIx1swrfJAG2kfzaDTkxj6oqrLQ6s5xfOguGe5mO2zF
         wFqA==
X-Gm-Message-State: APjAAAX3f5KocWuiaSpAFjXxeNATdYv8F/pG7g/FFrR58fmOj9GbtWDQ
	IOPyj3/K8hd66i6WWMoTMNvJnhOl2xHAC/KlNaM8o7zhM3rsNstWFKDpZ4vxihhngp7wRJEztkC
	akkLyExGP8io3QPaPAf43vckeWenmYJSOIpMLkH+gUvQJiOdiCB+z1gKMp5G7eGG46w==
X-Received: by 2002:a2e:994:: with SMTP id 142mr19414955ljj.192.1558093346421;
        Fri, 17 May 2019 04:42:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhuk7tARSvASQ1WV+VkwO5/rGOb7b3pKPs8pVpeiFf4RsSN97DdAUq7kl25cR4Vr3/p1TO
X-Received: by 2002:a2e:994:: with SMTP id 142mr19414911ljj.192.1558093345546;
        Fri, 17 May 2019 04:42:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558093345; cv=none;
        d=google.com; s=arc-20160816;
        b=ZbEj1wlsLiAjwSRP6skcumIP9kDKAybXNy73NAtqKsDPVpmdfVkw9OpO9A3djZwJto
         eSzQ5iWzx3ARJrXRojHQ8BAvWASSn4S6PC5J3LNEodAD806sEAnEGN2n6/V8kf0ebGHt
         BvqQ2fTyKTleqj+rm/Qdge3FoR/Bfk7XeAlUkjviL1KYqkGmWmoVUYDaYit50urmkqZ9
         zOHUAnfW0DbTZhkFo7JDEpu3s4k1NSw4IcZZ5xSe+zfauRdDdJqKFjTP1IKS7fH7xujv
         +BohkDmYu2dJtYSSkdKP6ikjY3GbJ2+CDNhiuqqj/tBSuYJ2C4WOm6BNUTjA2kP62dF7
         CtvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=DuAu62W6AZc9BLNWjfPvq/8pURNd6AGdCvHd+9yn0vQ=;
        b=CUCVYwKSqR+lCLCC98vBAiOn6KJM8sFL0t38qRbCLKcHsOVqq/baeGsloYeYSPrWhJ
         424ypP6I8oaRd4DJccuPA3LeJGkKfT5Aa38ixEYWyipUGP86wbQpUtEohkhQL4tfCCOS
         ZD1IcvRBvv5CdsN8p1qTndgmpfXEg318iFgvVSoTuNi7XCWrtaHXIcp5NzVWTNjV0aue
         rXQ9jpqT8ZkNJnfXlhGamUgLb9gxfNLGhDSvCJ1ksf1X7WO63scoiqv3jhC1p78IrbzM
         j97XFx/uRCgSf7G8SgeL0wV6grFVmtwhNVhzoUKJ5Z8WYJllDEKfd03XbiqZVviT19IL
         ZHfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=ZeBCvFex;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [2a02:6b8:0:1a2d::193])
        by mx.google.com with ESMTP id t21si5606867lft.122.2019.05.17.04.42.25
        for <linux-mm@kvack.org>;
        Fri, 17 May 2019 04:42:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) client-ip=2a02:6b8:0:1a2d::193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=ZeBCvFex;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1a2d::193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 191932E14DD;
	Fri, 17 May 2019 14:42:25 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id lBau1MQ6yC-gO0uNjAp;
	Fri, 17 May 2019 14:42:25 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1558093345; bh=DuAu62W6AZc9BLNWjfPvq/8pURNd6AGdCvHd+9yn0vQ=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=ZeBCvFexSzy4eK7HnXw2m4E5GbH4MqlmnqC7eg/bDjugORxk6Zg2cuAreDZwKKW84
	 IglY+I/SVtpVb4zGjn7fFOaVikA0ixgEa/Wpe87mU8GxVjh0oByXvhV2GNYkoND1GK
	 U5BObTMXhRqdbNw1ddlNlHde7uX4NKFs+sTewuzc=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:4cb8:ba55:7b16:beea])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id rncTEwRDdX-gOdCPYWB;
	Fri, 17 May 2019 14:42:24 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] proc/meminfo: add KernelMisc counter
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <155792098821.1536.17069603544573830315.stgit@buzz>
 <20190516175912.GA32262@tower.DHCP.thefacebook.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <6bb58fe4-d860-555e-3fb9-17b4ab552da6@yandex-team.ru>
Date: Fri, 17 May 2019 14:42:24 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190516175912.GA32262@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.05.2019 20:59, Roman Gushchin wrote:
> On Wed, May 15, 2019 at 02:49:48PM +0300, Konstantin Khlebnikov wrote:
>> Some kernel memory allocations are not accounted anywhere.
>> This adds easy-read counter for them by subtracting all tracked kinds.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> We have something similar in userspace, and it was very useful several times.
> In our case, it was mostly vmallocs and percpu stuff (which are now shown
> in meminfo), but for sure there are other memory users who are not.
> 
> I don't particularly like the proposed name, but have no better ideas.
> It's really a gray area, everything we know, it's that the memory is occupied
> by something.
> 

Probably it's better to add overall 'MemKernel'.
Detailed analysis anyway requires special tools.

>> ---
>>   Documentation/filesystems/proc.txt |    2 ++
>>   fs/proc/meminfo.c                  |   41 +++++++++++++++++++++++++-----------
>>   2 files changed, 30 insertions(+), 13 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index 66cad5c86171..f11ce167124c 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -891,6 +891,7 @@ VmallocTotal:   112216 kB
>>   VmallocUsed:       428 kB
>>   VmallocChunk:   111088 kB
>>   Percpu:          62080 kB
>> +KernelMisc:     212856 kB
>>   HardwareCorrupted:   0 kB
>>   AnonHugePages:   49152 kB
>>   ShmemHugePages:      0 kB
>> @@ -988,6 +989,7 @@ VmallocTotal: total size of vmalloc memory area
>>   VmallocChunk: largest contiguous block of vmalloc area which is free
>>         Percpu: Memory allocated to the percpu allocator used to back percpu
>>                 allocations. This stat excludes the cost of metadata.
>> +  KernelMisc: All other kinds of kernel memory allocaitons
>                                                         ^^^
> 						       typo
>>   
>>   ..............................................................................
>>   
>> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
>> index 568d90e17c17..7bc14716fc5d 100644
>> --- a/fs/proc/meminfo.c
>> +++ b/fs/proc/meminfo.c
>> @@ -38,15 +38,21 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>   	long cached;
>>   	long available;
>>   	unsigned long pages[NR_LRU_LISTS];
>> -	unsigned long sreclaimable, sunreclaim;
>> +	unsigned long sreclaimable, sunreclaim, misc_reclaimable;
>> +	unsigned long kernel_stack_kb, page_tables, percpu_pages;
>> +	unsigned long anon_pages, file_pages, swap_cached;
>> +	long kernel_misc;
>>   	int lru;
>>   
>>   	si_meminfo(&i);
>>   	si_swapinfo(&i);
>>   	committed = percpu_counter_read_positive(&vm_committed_as);
>>   
>> -	cached = global_node_page_state(NR_FILE_PAGES) -
>> -			total_swapcache_pages() - i.bufferram;
>> +	anon_pages = global_node_page_state(NR_ANON_MAPPED);
>> +	file_pages = global_node_page_state(NR_FILE_PAGES);
>> +	swap_cached = total_swapcache_pages();
>> +
>> +	cached = file_pages - swap_cached - i.bufferram;
>>   	if (cached < 0)
>>   		cached = 0;
>>   
>> @@ -56,13 +62,25 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>   	available = si_mem_available();
>>   	sreclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE);
>>   	sunreclaim = global_node_page_state(NR_SLAB_UNRECLAIMABLE);
>> +	misc_reclaimable = global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
>> +	kernel_stack_kb = global_zone_page_state(NR_KERNEL_STACK_KB);
>> +	page_tables = global_zone_page_state(NR_PAGETABLE);
>> +	percpu_pages = pcpu_nr_pages();
>> +
>> +	/* all other kinds of kernel memory allocations */
>> +	kernel_misc = i.totalram - i.freeram - anon_pages - file_pages
>> +		      - sreclaimable - sunreclaim - misc_reclaimable
>> +		      - (kernel_stack_kb >> (PAGE_SHIFT - 10))
>> +		      - page_tables - percpu_pages;
>> +	if (kernel_misc < 0)
>> +		kernel_misc = 0;
> 
> Hm, why? Is there any realistic scenario (not caused by the kernel doing
> the memory accounting wrong) when it's negative?
> 
> Maybe it's better to show it as it is, if it's negative? Because
> it might be a good indication that something's wrong with some of
> the counters.

Such kind of sanitisation is a common practice for racy counters.
See 'cached' above.

> 
> Thanks!
> 

