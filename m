Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE976B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:55:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w79so363152wrc.19
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:55:31 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [2a02:6b8:0:1a72::290])
        by mx.google.com with ESMTPS id z3si3795859lfa.600.2017.10.02.04.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 04:55:30 -0700 (PDT)
Subject: Re: [PATCH RFC] mm: implement write-behind policy for sequential file
 writes
References: <150693809463.587641.5712378065494786263.stgit@buzz>
 <c684ee77-27a6-1522-b443-0c6d33d569a0@redhat.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <6f332027-3304-a5c2-1978-294fe1106ef7@yandex-team.ru>
Date: Mon, 2 Oct 2017 14:55:28 +0300
MIME-Version: 1.0
In-Reply-To: <c684ee77-27a6-1522-b443-0c6d33d569a0@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 02.10.2017 14:23, Florian Weimer wrote:
> On 10/02/2017 11:54 AM, Konstantin Khlebnikov wrote:
>> This patch implements write-behind policy which tracks sequential writes
>> and starts background writeback when have enough dirty pages in a row.
> 
> Does this apply to data for files which have never been written to disk before?
> 
> I think one of the largest benefits of the extensive write-back caching in Linux is that the cache is discarded if the file is deleted 
> before it is ever written to disk.  (But maybe I'm wrong about this.)

Yes. I've mentioned that current policy is good for short-living files.

Write-behind keeps small files (<256kB) in cache and writes files smaller
than 1MB in background, synchronous writes starts only after 1MB.

But in other hand such files have to be written if somebody calls sync or
metadata changes are serialized by journal transactions, or memory pressure
flushes them to the disk. So this caching is very unstable and uncertain.
In some cases caching makes whole operation much slower because actual disk
write starts later than could be.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
