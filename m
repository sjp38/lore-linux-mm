Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 220B76B04CF
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 03:50:13 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m45-v6so9167905edc.2
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 00:50:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8-v6si158604ejm.303.2018.11.07.00.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 00:50:11 -0800 (PST)
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
 <63d9f48c-e39f-d345-0fb6-2f04afe769a2@yandex-team.ru>
 <08a61c003eed0280fd82f6200debcbca@codeaurora.org>
 <10c88df6-dbb1-7490-628c-055d59b5ad8e@yandex-team.ru>
 <22fa2222012341a54f6b0b6aea341aa2@codeaurora.org>
 <c3b0edf9-e6a2-c1ab-8490-d94b9830c8ae@yandex-team.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <89a259aa-156e-041c-b3bc-266824acb173@suse.cz>
Date: Wed, 7 Nov 2018 09:50:10 +0100
MIME-Version: 1.0
In-Reply-To: <c3b0edf9-e6a2-c1ab-8490-d94b9830c8ae@yandex-team.ru>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, julia.lawall@lip6.fr

On 11/7/18 8:02 AM, Konstantin Khlebnikov wrote:
> On 06.11.2018 11:43, Arun KS wrote:
>> On 2018-11-06 14:07, Konstantin Khlebnikov wrote:
>>> On 06.11.2018 11:30, Arun KS wrote:
>>>> On 2018-11-06 13:47, Konstantin Khlebnikov wrote:
>>>>> On 06.11.2018 8:38, Arun KS wrote:
>>>>>> Any comments?
>>>>>
>>>>> Looks good.
>>>>> Except unclear motivation behind this change.
>>>>> This should be in comment of one of patch.
>>>>
>>>> totalram_pages, zone->managed_pages and totalhigh_pages are sometimes modified outside managed_page_count_lock. Hence convert these 
>>>> variable to atomic to avoid readers potentially seeing a store tear.
>>>
>>> So, this is just theoretical issue or splat from sanitizer.
>>> After boot memory online\offline are strictly serialized by rw-semaphore.
>>
>> Few instances which can race with hot add. Please see below,
>> https://patchwork.kernel.org/patch/10627521/
> Could you point what exactly are you fixing with this set?
> 
> from v2:
> 
>  > totalram_pages, zone->managed_pages and totalhigh_pages updates
>  > are protected by managed_page_count_lock, but readers never care
>  > about it. Convert these variables to atomic to avoid readers
>  > potentially seeing a store tear.
> 
> This?
> 
> 
> Aligned unsigned long almost always stored at once.

The point is "almost always", so better not rely on it :) But the main
motivation was that managed_page_count_lock handling was complicating
Arun's "memory_hotplug: Free pages as higher order" patch and it seemed
a better idea to just remove and convert this to atomics, with
preventing potential store-to-read tearing as a bonus.

It would be nice to mention it in the changelogs though.

> To make it completely correct you could replace
> 
> a += b;
> 
> with
> 
> WRITE_ONCE(a, a + b);

Wouldn't be enough to get rid of the locks.
