Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E62C9C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8697220883
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 08:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="sliMViUI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8697220883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18E086B0272; Tue, 28 May 2019 04:04:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 118A56B0273; Tue, 28 May 2019 04:04:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F21F46B0275; Tue, 28 May 2019 04:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3F06B0272
	for <linux-mm@kvack.org>; Tue, 28 May 2019 04:04:52 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id q26so2487939lfc.3
        for <linux-mm@kvack.org>; Tue, 28 May 2019 01:04:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=M5GVJ5UIA7HPk8GVmrSjaHR1Kocs/6E9oStwcHVdqSs=;
        b=KHdXdqmSMELVxzn+39iwUw0k+rucU+pL9oQaZvwHRoLUPCG+nNhhvYqlSFBNM0U6bu
         LyUZXrIBYsa+6XYTqzJnhHkzhdbZA1ggW9v+6asx1Sw9eWpR6wBXRvy/7GTzVnKrin2f
         fqb6SXp+RSulqJz9AFKtR6lXGsil4k0GW7j5K/N23Me/ePfHh3SJK49Xo0CIDgtlBNPE
         cDX3hBV/P84n9SLucNbOzkSegp9x9fBflIUuMto5mfFwxEHjsDnrCMUgcGimQD68/9/P
         l1Q3ldjpgCcOcDRALQbcRIUa8zpoipwyhu4If5O1SqlArC/ogUJQNPUldCr4i/wGrlAM
         kt2Q==
X-Gm-Message-State: APjAAAU+q0KaGvesHaRR0BLGNFSpiMmB5nNsI39Yj0PqMIUhr5h2cNrG
	08+GzmWUz4TFX7RaqdwJzA6coPk+cQb0dfmWFua1QbbyK2Yg9hZHGWV6eAl2+9Ntc+IVNpRVq1L
	1fZP2J09rwNf5o/tHjoX16gu694K9mjYzKAYBm312MZ7i94UxZawb8jA90GtxRo7CDg==
X-Received: by 2002:a2e:8954:: with SMTP id b20mr18243324ljk.10.1559030691880;
        Tue, 28 May 2019 01:04:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxF+vie9cX3F7cS1cPu6ibaYn7Gocz5VPX2E8bxlHtUbef5aE9leXqHXMonu8w2/8nAiGf1
X-Received: by 2002:a2e:8954:: with SMTP id b20mr18243291ljk.10.1559030691108;
        Tue, 28 May 2019 01:04:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559030691; cv=none;
        d=google.com; s=arc-20160816;
        b=kAfozVAr5k46v8ae9gzbDdGKHYxUNQY3XomXbUC+eTrW6dm7AxOy51oNv1nrDHYED6
         dpoT4gdT+tUnxGGkjlPxUHgAL4bUzTRklbBBz/ATtKznWVkEM8cIFeQCtXuG5MUNehkE
         fNJBKQ9j4Rj/omJyIImKH5mjiQMDT9oRte7BEa10JHiPgkfgl43Z/K+rP41/tOZAoczi
         AequWwY9v51MirrXmIH1YUgP6VpqTjOCcdCuo5nKOQnu0HJgdTdlnDW4TAWgKqTETzm2
         S/iBqt1YpWI85BoiB6kdJJZMPcRA6adb6yf88G/SmrEDldirc4rIZJGd7rDJEhuy30La
         xN0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=M5GVJ5UIA7HPk8GVmrSjaHR1Kocs/6E9oStwcHVdqSs=;
        b=FYIoBHR9yQ6Imuq7AS/U6mO8yRU8qI8iMuOGAvBP9XZBhOvobYGSdbYRhtK9lV52Kz
         fQ23JVxpKEdwmEs68FL52Om3HMCNaNNTrmAzT1pKHMkRZoasVOgI3lJ8k43mgZ9DY/w0
         k9dyyjOn6oTaU260JIqkRtRUEuTQthcwdhf6/z6iEEfsMawGYI61gojuAV2pFq3cMp/P
         oityT3Ym0GOGXNLkn9oZGWiIBkgGfhY1u3BHDXtVMSKqAqCEXH3IwGX0cEhksa/6UmEv
         5L7BJFyp3YPKhfvYvzxE+7230UYCl/IlItQvzVZjmHFDoFY/0S2suRtRhZ5B3dX2yOXx
         Q2kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=sliMViUI;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [2a02:6b8:0:1619::183])
        by mx.google.com with ESMTPS id y15si12785943ljc.149.2019.05.28.01.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 01:04:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) client-ip=2a02:6b8:0:1619::183;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=sliMViUI;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 2a02:6b8:0:1619::183 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 5733E2E0A36;
	Tue, 28 May 2019 11:04:48 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id m59xZhNhfy-4l5i7XHm;
	Tue, 28 May 2019 11:04:48 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1559030688; bh=M5GVJ5UIA7HPk8GVmrSjaHR1Kocs/6E9oStwcHVdqSs=;
	h=In-Reply-To:Message-ID:From:Date:References:To:Subject:Cc;
	b=sliMViUISlZv4ivdP47YUmKzIFD6JxWHzMWRPoMofXHi0Bl+gyker5cZo1ApiaRIX
	 H6vjAeJxiF3qHI6Qw4jAKpxzBRUmSPeFLWG7TV+eAlkO5pB8z9Rfxi8B4u8tLqnMnt
	 6Fk93jMvklQm1PE68ODKx+mLq0YhXEUE2EYY84v4=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:d877:17c:81de:6e43])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id 8KcqFbu0Vu-4llCBi6N;
	Tue, 28 May 2019 11:04:47 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: Re: [PATCH RFC] mm/madvise: implement MADV_STOCKPILE (kswapd from
 user space)
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, Roman Gushchin <guro@fb.com>,
 linux-api@vger.kernel.org
References: <155895155861.2824.318013775811596173.stgit@buzz>
 <20190527141223.GD1658@dhcp22.suse.cz> <20190527142156.GE1658@dhcp22.suse.cz>
 <20190527143926.GF1658@dhcp22.suse.cz>
 <9c55a343-2a91-46c6-166d-41b94bf5e9c8@yandex-team.ru>
 <20190528065153.GB1803@dhcp22.suse.cz>
 <a4e5eeb8-3560-d4b4-08a0-8a22c677c0f7@yandex-team.ru>
 <20190528073835.GP1658@dhcp22.suse.cz>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <5af1ba69-61d1-1472-4aa3-20beb4ae44ae@yandex-team.ru>
Date: Tue, 28 May 2019 11:04:46 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190528073835.GP1658@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 28.05.2019 10:38, Michal Hocko wrote:
> On Tue 28-05-19 10:30:12, Konstantin Khlebnikov wrote:
>> On 28.05.2019 9:51, Michal Hocko wrote:
>>> On Tue 28-05-19 09:25:13, Konstantin Khlebnikov wrote:
>>>> On 27.05.2019 17:39, Michal Hocko wrote:
>>>>> On Mon 27-05-19 16:21:56, Michal Hocko wrote:
>>>>>> On Mon 27-05-19 16:12:23, Michal Hocko wrote:
>>>>>>> [Cc linux-api. Please always cc this list when proposing a new user
>>>>>>>     visible api. Keeping the rest of the email intact for reference]
>>>>>>>
>>>>>>> On Mon 27-05-19 13:05:58, Konstantin Khlebnikov wrote:
>>>>>> [...]
>>>>>>>> This implements manual kswapd-style memory reclaim initiated by userspace.
>>>>>>>> It reclaims both physical memory and cgroup pages. It works in context of
>>>>>>>> task who calls syscall madvise thus cpu time is accounted correctly.
>>>>>>
>>>>>> I do not follow. Does this mean that the madvise always reclaims from
>>>>>> the memcg the process is member of?
>>>>>
>>>>> OK, I've had a quick look at the implementation (the semantic should be
>>>>> clear from the patch descrition btw.) and it goes all the way up the
>>>>> hierarchy and finally try to impose the same limit to the global state.
>>>>> This doesn't really make much sense to me. For few reasons.
>>>>>
>>>>> First of all it breaks isolation where one subgroup can influence a
>>>>> different hierarchy via parent reclaim.
>>>>
>>>> madvise(NULL, size, MADV_STOCKPILE) is the same as memory allocation and
>>>> freeing immediately, but without pinning memory and provoking oom.
>>>>
>>>> So, there is shouldn't be any isolation or security issues.
>>>>
>>>> At least probably it should be limited with portion of limit (like half)
>>>> instead of whole limit as it does now.
>>>
>>> I do not think so. If a process is running inside a memcg then it is
>>> a subject of a limit and that implies an isolation. What you are
>>> proposing here is to allow escaping that restriction unless I am missing
>>> something. Just consider the following setup
>>>
>>> 		root (total memory = 2G)
>>> 		 / \
>>>              (1G) A   B (1G)
>>>                      / \
>>>              (500M) C   D (500M)
>>>
>>> all of them used up close to the limit and a process inside D requests
>>> shrinking to 250M. Unless I am misunderstanding this implementation
>>> will shrink D, B root to 250M (which means reclaiming C and A as well)
>>> and then globally if that was not sufficient. So you have allowed D to
>>> "allocate" 1,75G of memory effectively, right?
>>
>> It shrinks not 'size' memory - only while usage + size > limit.
>> So, after reclaiming 250M in D all other levels will have 250M free.
> 
> Could you define the exact semantic? Ideally something for the manual
> page please?
> 

Like kswapd which works with thresholds of free memory this one reclaims
until 'free' (i.e. memory which could be allocated without invoking
direct recliam of any kind) is lower than passed 'size' argument.

Thus right after madvise(NULL, size, MADV_STOCKPILE) 'size' bytes
could be allocated in this memory cgroup without extra latency from
reclaimer if there is no other memory consumers.

Reclaimed memory is simply put into free lists in common buddy allocator,
there is no reserves for particular task or cgroup.

If overall memory allocation rate is smooth without rough spikes then
calling MADV_STOCKPILE in loop periodically provides enough room for
allocations and eliminates direct reclaim from all other tasks.
As a result this eliminates unpredictable delays caused by
direct reclaim in random places.

