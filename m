Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id CD10D6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:09:05 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so7425339igc.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:09:05 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id 9si11626268iod.108.2015.09.14.21.09.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 21:09:05 -0700 (PDT)
Received: by igcpb10 with SMTP id pb10so7425252igc.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 21:09:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55F6D641.6010209@suse.cz>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <55F6D356.5000106@suse.cz> <CAMJBoFMD8jj372sXfb5NkT2MBzBUQp232U7XxO9QHKco+mHUYQ@mail.gmail.com>
 <55F6D641.6010209@suse.cz>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 15 Sep 2015 00:08:25 -0400
Message-ID: <CALZtONCKCTRP5r0u5iXYHsQ=uxA-B+1M=4=RPGtFiwo4EOpzeg@mail.gmail.com>
Subject: Re: [PATCH 0/3] allow zram to use zbud as underlying allocator
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 14, 2015 at 10:14 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 09/14/2015 04:12 PM, Vitaly Wool wrote:
>>
>> On Mon, Sep 14, 2015 at 4:01 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>>
>>> On 09/14/2015 03:49 PM, Vitaly Wool wrote:
>>>>
>>>>
>>>> While using ZRAM on a small RAM footprint devices, together with
>>>> KSM,
>>>> I ran into several occasions when moving pages from compressed swap back
>>>> into the "normal" part of RAM caused significant latencies in system
>>>
>>>
>>>
>>> I'm sure Minchan will want to hear the details of that :)
>>>
>>>> operation. By using zbud I lose in compression ratio but gain in
>>>> determinism, lower latencies and lower fragmentation, so in the coming
>>>
>>>
>>>
>>> I doubt the "lower fragmentation" part given what I've read about the
>>> design of zbud and zsmalloc?
>>
>>
>> As it turns out, I see more cases of compaction kicking in and
>> significantly more compact_stalls with zsmalloc.
>
>
> Interesting, I thought that zsmalloc doesn't need contiguous high-order
> pages.

it doesn't.  but it has a complex (compared to zbud) way of storing
pages - many different classes, which each are made up of zspages,
which contain multiple actual pages to store some number of
specifically sized objects.  So it can get fragmented, with lots of
zspages with empty spaces for objects.  That's what the recently added
zsmalloc compaction addresses, by scanning all the zspages in all the
classes and compacting zspages within each class.

but I haven't followed most of the recent zsmalloc updates too
closely, so I may be totally wrong :-)

zbud is much simpler; since it just uses buddied pairs, it simply
keeps a list of zbud page with only 1 compressed page stored in it.
There is still the possibility of fragmentation, but since it's
simple, it's much smaller.  And there is no compaction implemented in
it, currently.  The downside, as we all know, is worse efficiency in
storing compressed pages - it can't do better than 2:1.

>
>> ~vitaly
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
