Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id C39B86B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 14:05:36 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id va2so7514936obc.26
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 11:05:36 -0800 (PST)
Received: from mail-oa0-x22b.google.com (mail-oa0-x22b.google.com [2607:f8b0:4003:c02::22b])
        by mx.google.com with ESMTPS id tk7si8314852obc.81.2014.02.10.11.05.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 11:05:35 -0800 (PST)
Received: by mail-oa0-f43.google.com with SMTP id h16so8019213oag.2
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 11:05:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
References: <1387459407-29342-1-git-send-email-ddstreet@ieee.org>
 <1390831279-5525-1-git-send-email-ddstreet@ieee.org> <20140203150835.f55fd427d0ebb0c2943f266b@linux-foundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 10 Feb 2014 14:05:14 -0500
Message-ID: <CALZtONAFF3F4j0KQX=ineJ1cOVEWJSGSe3V=Ja4x=3NguFAFMQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/zswap: add writethrough option
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>, Shirish Pargaonkar <spargaonkar@suse.com>, Mel Gorman <mgorman@suse.de>

On Mon, Feb 3, 2014 at 6:08 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 27 Jan 2014 09:01:19 -0500 Dan Streetman <ddstreet@ieee.org> wrote:
>
>> Currently, zswap is writeback cache; stored pages are not sent
>> to swap disk, and when zswap wants to evict old pages it must
>> first write them back to swap cache/disk manually.  This avoids
>> swap out disk I/O up front, but only moves that disk I/O to
>> the writeback case (for pages that are evicted), and adds the
>> overhead of having to uncompress the evicted pages and the
>> need for an additional free page (to store the uncompressed page).
>>
>> This optionally changes zswap to writethrough cache by enabling
>> frontswap_writethrough() before registering, so that any
>> successful page store will also be written to swap disk.  The
>> default remains writeback.  To enable writethrough, the param
>> zswap.writethrough=1 must be used at boot.
>>
>> Whether writeback or writethrough will provide better performance
>> depends on many factors including disk I/O speed/throughput,
>> CPU speed(s), system load, etc.  In most cases it is likely
>> that writeback has better performance than writethrough before
>> zswap is full, but after zswap fills up writethrough has
>> better performance than writeback.
>>
>> The reason to add this option now is, first to allow any zswap
>> user to be able to test using writethrough to determine if they
>> get better performance than using writeback, and second to allow
>> future updates to zswap, such as the possibility of dynamically
>> switching between writeback and writethrough.
>>
>> ...
>>
>> Based on specjbb testing on my laptop, the results for both writeback
>> and writethrough are better than not using zswap at all, but writeback
>> does seem to be better than writethrough while zswap isn't full.  Once
>> it fills up, performance for writethrough is essentially close to not
>> using zswap, while writeback seems to be worse than not using zswap.
>> However, I think more testing on a wider span of systems and conditions
>> is needed.  Additionally, I'm not sure that specjbb is measuring true
>> performance under fully loaded cpu conditions, so additional cpu load
>> might need to be added or specjbb parameters modified (I took the
>> values from the 4 "warehouses" test run).
>>
>> In any case though, I think having writethrough as an option is still
>> useful.  More changes could be made, such as changing from writeback
>> to writethrough based on the zswap % full.  And the patch doesn't
>> change default behavior - writethrough must be specifically enabled.
>>
>> The %-ized numbers I got from specjbb on average, using the default
>> 20% max_pool_percent and varying the amount of heap used as shown:
>>
>> ram | no zswap | writeback | writethrough
>> 75     93.08     100         96.90
>> 87     96.58     95.58       96.72
>> 100    92.29     89.73       86.75
>> 112    63.80     38.66       19.66
>> 125    4.79      29.90       15.75
>> 137    4.99      4.50        4.75
>> 150    4.28      4.62        5.01
>> 162    5.20      2.94        4.66
>> 175    5.71      2.11        4.84
>
> Changelog is very useful, thanks for taking the time.
>
> It does sound like the feature is of marginal benefit.  Is "zswap
> filled up" an interesting or useful case to optimize?
>
> otoh the addition is pretty simple and we can later withdraw the whole
> thing without breaking anyone's systems.

ping...

you still thinking about this or is it a reject for now?

>
> What do people think?
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
