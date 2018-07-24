Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAE06B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 00:24:15 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e21-v6so1347998itc.5
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 21:24:15 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id a200-v6si7877912ioa.64.2018.07.23.21.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 21:24:14 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: freepage accounting bug with CMA/migrate isolation
Message-ID: <86bea4f7-229a-7cbb-1e8a-7e6d96f0f087@oracle.com>
Date: Mon, 23 Jul 2018 21:24:09 -0700
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>, Laura Abbott <labbott@redhat.com>

With v4.17, I can see an issue like those addressed in commits 3c605096d315
("mm/page_alloc: restrict max order of merging on isolated pageblock")
and d9dddbf55667 ("mm/page_alloc: prevent merging between isolated and
other pageblocks").  After running a CMA stress test for a while, I see:
  MemTotal:        8168384 kB
  MemFree:         8457232 kB
  MemAvailable:    9204844 kB
If I let the test run, MemFree and MemAvailable will continue to grow.

I am certain the issue is with pageblocks of migratetype ISOLATED.  If
I disable all special 'is_migrate_isolate' checks in freepage accounting,
the issue goes away.  Further, I am pretty sure the issue has to do with
pageblock merging and or page orders spanning pageblocks.  If I make
pageblock_order equal MAX_ORDER-1, the issue also goes away.

Just looking for suggesting in where/how to debug.  I've been hacking on
this without much success.
--
Mike Kravetz
