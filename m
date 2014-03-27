Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0C96B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 22:31:42 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so2790590pad.21
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 19:31:42 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id zt8si333134pbc.273.2014.03.26.19.31.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Mar 2014 19:31:40 -0700 (PDT)
Message-ID: <53338CFE.3060705@huawei.com>
Date: Thu, 27 Mar 2014 10:29:18 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] kmemleak: allow freeing internal objects after
 kmemleak was disabled
References: <5326750E.1000004@huawei.com> <F7314A69-24BE-42B9-8E99-8F9292B397C4@arm.com>
In-Reply-To: <F7314A69-24BE-42B9-8E99-8F9292B397C4@arm.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

(Just came back from travelling)

On 2014/3/22 7:37, Catalin Marinas wrote:
> Hi Li,
> 
> On 17 Mar 2014, at 04:07, Li Zefan <lizefan@huawei.com> wrote:
>> Currently if kmemleak is disabled, the kmemleak objects can never be freed,
>> no matter if it's disabled by a user or due to fatal errors.
>>
>> Those objects can be a big waste of memory.
>>
>>  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
>> 1200264 1197433  99%    0.30K  46164       26    369312K kmemleak_object
>>
>> With this patch, internal objects will be freed immediately if kmemleak is
>> disabled explicitly by a user. If it's disabled due to a kmemleak error,
>> The user will be informed, and then he/she can reclaim memory with:
>>
>> 	# echo off > /sys/kernel/debug/kmemleak
>>
>> v2: use "off" handler instead of "clear" handler to do this, suggested
>>    by Catalin.
> 
> I think there was a slight misunderstanding. My point was about "echo
> scan=off!+- before !?echo off!+-, they can just be squashed into the
> same action of the latter.
> 

I'm not sure if I understand correctly, so you want the "off" handler to
stop the scan thread but it will never free kmemleak objects until the 
user explicitly trigger the "clear" action, right?

> I would keep the !?clear!+- part separately as per your first patch. I
> recall people asked in the past to still be able to analyse the reports
> even though kmemleak failed or was disabled.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
