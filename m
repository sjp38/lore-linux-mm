Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E45FC6B085B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:55:52 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id s64-v6so8224860lje.19
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 23:55:52 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r19-v6si27580868ljj.162.2018.11.15.23.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 23:55:51 -0800 (PST)
Subject: Re: [PATCH] mm: cleancache: fix corruption on missed inode
 invalidation
References: <20181112095734.17979-1-ptikhomirov@virtuozzo.com>
 <20181115143103.c6fa8fec343bb706b91f6c6c@linux-foundation.org>
From: Vasily Averin <vvs@virtuozzo.com>
Message-ID: <d2a7e3fe-67ca-12f3-d16b-c9de0646c063@virtuozzo.com>
Date: Fri, 16 Nov 2018 10:55:45 +0300
MIME-Version: 1.0
In-Reply-To: <20181115143103.c6fa8fec343bb706b91f6c6c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khorenko <khorenko@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/16/18 1:31 AM, Andrew Morton wrote:
> On Mon, 12 Nov 2018 12:57:34 +0300 Pavel Tikhomirov <ptikhomirov@virtuozzo.com> wrote:
> 
>> If all pages are deleted from the mapping by memory reclaim and also
>> moved to the cleancache:
>>
>> __delete_from_page_cache
>>   (no shadow case)
>>   unaccount_page_cache_page
>>     cleancache_put_page
>>   page_cache_delete
>>     mapping->nrpages -= nr
>>     (nrpages becomes 0)
>>
>> We don't clean the cleancache for an inode after final file truncation
>> (removal).
>>
>> truncate_inode_pages_final
>>   check (nrpages || nrexceptional) is false
>>     no truncate_inode_pages
>>       no cleancache_invalidate_inode(mapping)
>>
>> These way when reading the new file created with same inode we may get
>> these trash leftover pages from cleancache and see wrong data instead of
>> the contents of the new file.
>>
>> Fix it by always doing truncate_inode_pages which is already ready for
>> nrpages == 0 && nrexceptional == 0 case and just invalidates inode.
>>
> 
> Data corruption sounds serious.  Shouldn't we backport this into
> -stable kernels?

Yes, it was broken in 4.14 kernel and it should affect all who uses cleancache
Fixes: commit 91b0abe36a7b ("mm + fs: store shadow entries in page cache")
