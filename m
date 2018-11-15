Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5EA6B062C
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:31:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id q62so12609188pgq.9
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 14:31:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b15si8759260plm.431.2018.11.15.14.31.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 14:31:06 -0800 (PST)
Date: Thu, 15 Nov 2018 14:31:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: cleancache: fix corruption on missed inode
 invalidation
Message-Id: <20181115143103.c6fa8fec343bb706b91f6c6c@linux-foundation.org>
In-Reply-To: <20181112095734.17979-1-ptikhomirov@virtuozzo.com>
References: <20181112095734.17979-1-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Cc: Vasily Averin <vvs@virtuozzo.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Konstantin Khorenko <khorenko@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 12 Nov 2018 12:57:34 +0300 Pavel Tikhomirov <ptikhomirov@virtuozzo.com> wrote:

> If all pages are deleted from the mapping by memory reclaim and also
> moved to the cleancache:
> 
> __delete_from_page_cache
>   (no shadow case)
>   unaccount_page_cache_page
>     cleancache_put_page
>   page_cache_delete
>     mapping->nrpages -= nr
>     (nrpages becomes 0)
> 
> We don't clean the cleancache for an inode after final file truncation
> (removal).
> 
> truncate_inode_pages_final
>   check (nrpages || nrexceptional) is false
>     no truncate_inode_pages
>       no cleancache_invalidate_inode(mapping)
> 
> These way when reading the new file created with same inode we may get
> these trash leftover pages from cleancache and see wrong data instead of
> the contents of the new file.
> 
> Fix it by always doing truncate_inode_pages which is already ready for
> nrpages == 0 && nrexceptional == 0 case and just invalidates inode.
> 

Data corruption sounds serious.  Shouldn't we backport this into
-stable kernels?
