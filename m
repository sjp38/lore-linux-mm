Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 007216B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 18:00:45 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id u56so423884wes.25
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 15:00:45 -0800 (PST)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id di1si12055949wjc.44.2013.11.21.15.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 15:00:45 -0800 (PST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so446072wib.16
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 15:00:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAL1ERfNr+J5gT-s1Qe+RVmNz+CenNFOzAWi86MNCt2ZGLB4ZCA@mail.gmail.com>
References: <1384976973-32722-1-git-send-email-ddstreet@ieee.org>
 <528D570D.3020006@oracle.com> <CAL1ERfNr+J5gT-s1Qe+RVmNz+CenNFOzAWi86MNCt2ZGLB4ZCA@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Thu, 21 Nov 2013 18:00:24 -0500
Message-ID: <CALZtONBzk4Yh9yHk3320a4x2DfSvUxGik8q+sLV38_cy4cuefg@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: change zswap to writethrough cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

On Wed, Nov 20, 2013 at 10:50 PM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
> Hello Dan,
>
> On Thu, Nov 21, 2013 at 8:42 AM, Bob Liu <bob.liu@oracle.com> wrote:
>> Hi Dan,
>>
>> On 11/21/2013 03:49 AM, Dan Streetman wrote:
>>> Currently, zswap is writeback cache; stored pages are not sent
>>> to swap disk, and when zswap wants to evict old pages it must
>>> first write them back to swap cache/disk manually.  This avoids
>>> swap out disk I/O up front, but only moves that disk I/O to
>>> the writeback case (for pages that are evicted), and adds the
>>> overhead of having to uncompress the evicted pages, and adds the
>>> need for an additional free page (to store the uncompressed page)
>>> at a time of likely high memory pressure.  Additionally, being
>>> writeback adds complexity to zswap by having to perform the
>>> writeback on page eviction.
>>>
>>
>> Good work!
>>
>>> This changes zswap to writethrough cache by enabling
>>> frontswap_writethrough() before registering, so that any
>>> successful page store will also be written to swap disk.  All the
>>> writeback code is removed since it is no longer needed, and the
>>> only operation during a page eviction is now to remove the entry
>>> from the tree and free it.
>>>
>
> Thanks for your work. I reviewed this patch, and it is good to me.
>
> However, I am skeptical about it because:
> 1. it will add more IO than original zswap, how does it result in a
> performance improvement ?

I haven't used SPECjbb yet (I don't have it, I'll have to find someone
who has it that I can borrow), but my testing with a small test
program I wrote does show that CPU-bound performance is better with
writethrough over writeback, once zswap is full, which I think is
expected since writeback adds cycles for decompressing old pages while
writethrough simply drops the compressed page.  Now, the additional
CPU load may be more desirable depending on CPU speed, # of CPUs, swap
disk speed, etc., so maybe it would be better to make zswap writeback
or writethrough, with a param to select, depending on the specific hw
it's being run on.

> 2. most embedded device use NAND, more IO will reduce its working life

This is certainly true; but most embedded devices also have tiny cpus
that might get hit hard when zswap fills up and has to start
decompressing pages while simultaneously compressing newly swapped out
pages.  I'd expect for many embedded devices it would be better to
simply invoke the oom killer and/or reboot than try to run with
overcommitted memory.  But, having writeback vs writethrough
selectable by param would allow flexibility based on the specific
user's needs.


>
> Regards
>
>> Could you do some testing using eg. SPECjbb? And compare the result with
>> original zswap.
>>
>> Thanks,
>> -Bob
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
