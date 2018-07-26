Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id E84E46B0270
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 08:29:04 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 90-v6so1142644pla.18
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 05:29:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u186-v6si1350597pfu.263.2018.07.26.05.28.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 05:28:56 -0700 (PDT)
Subject: Re: freepage accounting bug with CMA/migrate isolation
References: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <efc17c04-8498-29c8-56bb-9cbad897f0d8@suse.cz>
Date: Thu, 26 Jul 2018 14:28:53 +0200
MIME-Version: 1.0
In-Reply-To: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>

On 07/24/2018 06:24 AM, Mike Kravetz wrote:
> With v4.17, I can see an issue like those addressed in commits 3c605096d315
> ("mm/page_alloc: restrict max order of merging on isolated pageblock")
> and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
> other pageblocks").  After running a CMA stress test for a while, I see:
>   MemTotal:        8168384 kB
>   MemFree:         8457232 kB
>   MemAvailable:    9204844 kB
> If I let the test run, MemFree and MemAvailable will continue to grow.
> 
> I am certain the issue is with pageblocks of migratetype ISOLATED.  If
> I disable all special 'is_migrate_isolate' checks in freepage accounting,
> the issue goes away.

That means you count isolated pages as freepages, right?

> Further, I am pretty sure the issue has to do with
> pageblock merging and or page orders spanning pageblocks.  If I make
> pageblock_order equal MAX_ORDER-1, the issue also goes away.

Interesting, that should only matter in __free_one_page(). Do you have
page guards enabled?

> Just looking for suggesting in where/how to debug.  I've been hacking on
> this without much success.
> --
> Mike Kravetz
> 
