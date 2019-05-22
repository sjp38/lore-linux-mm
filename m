Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA94C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 902A720868
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:30:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="XRudIStP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 902A720868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 394826B0006; Wed, 22 May 2019 11:30:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 344CE6B0008; Wed, 22 May 2019 11:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E8D06B000A; Wed, 22 May 2019 11:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2D66B0006
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:30:27 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 17so516089lfr.14
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:30:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=AARDsc+qKR1tiSZQnznuyXjsYF8+lb0Jab821k1urZ0=;
        b=c4Lh0z+4He0/2zqfSkiDwt+8ETrHUfErOI0ySP6jY3N5607oWBD0ThdobMhrEr1H/e
         ljETl1TIfP1f8wNCWwj4EhHwYqLN9LEQunmr4Fl3aCR8HqOzWKl8ydm+cA24gRUxywze
         T7BkjFhonDVM8h4B/I8ZehEYkr3hQtq61c6RxDfccT5UeXThA/OvRWieBR1wtojQGKv9
         4bCN2T3Aqx3YoZxh8FSDwYvj3ed3tRbG7ePn3fiC1vN9PSc2Rwv4ORukpUYPdVMtYa+k
         +gw/K8lUudN6IeplBKfh7ULnzrNalQYnR4ymVxayqC6ICH8fGv08QbYxgUEePNghyMj1
         JXtQ==
X-Gm-Message-State: APjAAAVmyyKIyDAQ/BF+ZJZhbSHOJ6w7ALDPDLY0KQw+E8HYhBLPkZY8
	AUkOvrJYVVtU8BOCgWCbWM19qgbmqEq+x4bDTzdlz7T/CEw8TwWJ7wmVSuT9t+V2WnF3zNxC3Re
	yEXUrGzA+sVRU0BBVKIDVF14YjkbanHiuvD963VDmrTK7WANOOq62+dIBzUVwwfVWNg==
X-Received: by 2002:a2e:860a:: with SMTP id a10mr2536644lji.158.1558539026817;
        Wed, 22 May 2019 08:30:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFanNBZbww2o1iMz/s2M/ucSPJK9WYDG79tRq/OsS5jQ0RGMlwM9QTVX2LblEk+BoVq8gy
X-Received: by 2002:a2e:860a:: with SMTP id a10mr2536581lji.158.1558539025770;
        Wed, 22 May 2019 08:30:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558539025; cv=none;
        d=google.com; s=arc-20160816;
        b=PBFkGjo5qP8OZ6D48rxlJ+8w3wpYpptZle6Y3oKjeWQHYV3FGfiRM34ximsagKVCt+
         zZrLx+C7oizZHpDK7DbXFV8DQAi2DHVotii5wlGyjJqs31YSUHBpb1mcmpKLlGIiwBRf
         ut+whDRraDa9wSJWOnj55DW/rxTe5ysYzp8u4uwSgycwCYd5KEDXKiqi8cJDipnh069I
         EJq4byo1C5/BXM8S08n5zI8a6kD9o1/HT7RMdam6omNOp7CVHOaCtR6ZD1vrMhAcDt+K
         xvhYsxCvdiDBO3QnZwgLMyHSn6NiA0McrH6zjnOJ59aapyRAj67Rxv7k601PhAMXJ/Kv
         zQXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=AARDsc+qKR1tiSZQnznuyXjsYF8+lb0Jab821k1urZ0=;
        b=if4WMM9FAK6mkK+7OdrkWJQwKvEIgz8wJ6Hov2H8ohn1SVgCq0F3XEnLbsAHabTxga
         FYqbHryUzNB9gJCiqks6J6rhVbPrqvaN62shLfWpn1nPKdGYKZt3tW4r5tSE8u9y0SH1
         jG3YyWtV3cGrBJ8Q0NTXA8z/MAz8Yns5yKETCbXAXu2qAv4U+LPpUgZUH7a+jKQSiae1
         3vKk9y9GiftVNrnhd5LwtaCniUs9d63waYfTm9yOFLgrgYL2UVJmapdartzY1l82O/Lk
         ortrgvytyuYuU8LSyaVhIA2GYw5pTEPw9jTHAjXE00Djhas6Jvehp5H6rkZchZ3F5euY
         d3+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=XRudIStP;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id u11si12558017ljg.86.2019.05.22.08.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:30:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=XRudIStP;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1g.mail.yandex.net (mxbackcorp1g.mail.yandex.net [IPv6:2a02:6b8:0:1402::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id D12932E0993;
	Wed, 22 May 2019 18:30:24 +0300 (MSK)
Received: from smtpcorp1j.mail.yandex.net (smtpcorp1j.mail.yandex.net [2a02:6b8:0:1619::137])
	by mxbackcorp1g.mail.yandex.net (nwsmtp/Yandex) with ESMTP id u0oNPspX6E-UOkeHk5m;
	Wed, 22 May 2019 18:30:24 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1558539024; bh=AARDsc+qKR1tiSZQnznuyXjsYF8+lb0Jab821k1urZ0=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=XRudIStPFGmb/HtlqM4I2M1uA0By0RU3+o4Z6zLDd6mZ3kynjOpzCw4PhkN5tBFHu
	 jRn3K7+MPQAUfIyZvhVE2zVdX/fMJ8FRdyqlf+FmVVFg7sw7x0zLRjzBHV0n7Qscj2
	 iHMO5ULOWUNm43Syo5hztv4Cf2LIf66AUZXJNDe0=
Authentication-Results: mxbackcorp1g.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:e47f:4b1d:b053:2762])
	by smtpcorp1j.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id PG7C45att4-UN849cun;
	Wed, 22 May 2019 18:30:24 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH] proc/meminfo: add MemKernel counter
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>
References: <155853600919.381.8172097084053782598.stgit@buzz>
 <529aa7fd-2dc2-6979-4ea0-d40dfc7e3fde@suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <1ce9b1af-27bd-f1ea-14cb-57ce40475f38@yandex-team.ru>
Date: Wed, 22 May 2019 18:30:23 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <529aa7fd-2dc2-6979-4ea0-d40dfc7e3fde@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.05.2019 18:01, Vlastimil Babka wrote:
> On 5/22/19 4:40 PM, Konstantin Khlebnikov wrote:
>> Some kinds of kernel allocations are not accounted or not show in meminfo.
>> For example vmalloc allocations are tracked but overall size is not shown
> 
> I think Roman's vmalloc patch [1] is on its way?
> 
>> for performance reasons. There is no information about network buffers.
> 
> xfs buffers can also occupy a lot, from my experience
> 
>> In most cases detailed statistics is not required. At first place we need
>> information about overall kernel memory usage regardless of its structure.
>>
>> This patch estimates kernel memory usage by subtracting known sizes of
>> free, anonymous, hugetlb and caches from total memory size: MemKernel =
>> MemTotal - MemFree - Buffers - Cached - SwapCached - AnonPages - Hugetlb.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> 
> I've tried this once in [2]. The name was Unaccounted and one of the objections
> was that people would get worried. Yours is a bit better, perhaps MemKernMisc
> would be even more descriptive? Michal Hocko worried about maintainability, that
> we forget something, but I don't think that's a big issue.

I've started with Misc/Unaccounted too
https://lore.kernel.org/lkml/155792098821.1536.17069603544573830315.stgit@buzz/

But this version simply shows all kernel memory.

> 
> Vlastimil
> 
> [1] https://lore.kernel.org/linux-mm/20190514235111.2817276-2-guro@fb.com/T/#u
> [2] https://lore.kernel.org/linux-mm/20161020121149.9935-1-vbabka@suse.cz/T/#u
> 
>> ---
>>   Documentation/filesystems/proc.txt |    5 +++++
>>   fs/proc/meminfo.c                  |   20 +++++++++++++++-----
>>   2 files changed, 20 insertions(+), 5 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index 66cad5c86171..a0ab7f273ea0 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -860,6 +860,7 @@ varies by architecture and compile options.  The following is from a
>>   
>>   MemTotal:     16344972 kB
>>   MemFree:      13634064 kB
>> +MemKernel:      862600 kB
>>   MemAvailable: 14836172 kB
>>   Buffers:          3656 kB
>>   Cached:        1195708 kB
>> @@ -908,6 +909,10 @@ MemAvailable: An estimate of how much memory is available for starting new
>>                 page cache to function well, and that not all reclaimable
>>                 slab will be reclaimable, due to items being in use. The
>>                 impact of those factors will vary from system to system.
>> +   MemKernel: The sum of all kinds of kernel memory allocations: Slab,
>> +              Vmalloc, Percpu, KernelStack, PageTables, socket buffers,
>> +              and some other untracked allocations. Does not include
>> +              MemFree, Buffers, Cached, SwapCached, AnonPages, Hugetlb.
>>        Buffers: Relatively temporary storage for raw disk blocks
>>                 shouldn't get tremendously large (20MB or so)
>>         Cached: in-memory cache for files read from the disk (the
>> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
>> index 568d90e17c17..b27d56dd619a 100644
>> --- a/fs/proc/meminfo.c
>> +++ b/fs/proc/meminfo.c
>> @@ -39,17 +39,27 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>   	long available;
>>   	unsigned long pages[NR_LRU_LISTS];
>>   	unsigned long sreclaimable, sunreclaim;
>> +	unsigned long anon_pages, file_pages, swap_cached;
>> +	long kernel_pages;
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
>> +	kernel_pages = i.totalram - i.freeram - anon_pages - file_pages -
>> +		       hugetlb_total_pages();
>> +	if (kernel_pages < 0)
>> +		kernel_pages = 0;
>> +
>>   	for (lru = LRU_BASE; lru < NR_LRU_LISTS; lru++)
>>   		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
>>   
>> @@ -60,9 +70,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>   	show_val_kb(m, "MemTotal:       ", i.totalram);
>>   	show_val_kb(m, "MemFree:        ", i.freeram);
>>   	show_val_kb(m, "MemAvailable:   ", available);
>> +	show_val_kb(m, "MemKernel:      ", kernel_pages);
>>   	show_val_kb(m, "Buffers:        ", i.bufferram);
>>   	show_val_kb(m, "Cached:         ", cached);
>> -	show_val_kb(m, "SwapCached:     ", total_swapcache_pages());
>> +	show_val_kb(m, "SwapCached:     ", swap_cached);
>>   	show_val_kb(m, "Active:         ", pages[LRU_ACTIVE_ANON] +
>>   					   pages[LRU_ACTIVE_FILE]);
>>   	show_val_kb(m, "Inactive:       ", pages[LRU_INACTIVE_ANON] +
>> @@ -92,8 +103,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>>   		    global_node_page_state(NR_FILE_DIRTY));
>>   	show_val_kb(m, "Writeback:      ",
>>   		    global_node_page_state(NR_WRITEBACK));
>> -	show_val_kb(m, "AnonPages:      ",
>> -		    global_node_page_state(NR_ANON_MAPPED));
>> +	show_val_kb(m, "AnonPages:      ", anon_pages);
>>   	show_val_kb(m, "Mapped:         ",
>>   		    global_node_page_state(NR_FILE_MAPPED));
>>   	show_val_kb(m, "Shmem:          ", i.sharedram);
>>
> 

