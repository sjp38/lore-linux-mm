Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1262B6B025F
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:17:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so148453932pfa.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:17:45 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id v129si11175911pfb.232.2016.06.17.01.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 01:17:44 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id c74so5785587pfb.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:17:44 -0700 (PDT)
Date: Fri, 17 Jun 2016 17:17:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160617081726.GA30699@swordfish>
References: <20160616084656.GB432@swordfish>
 <20160616085836.GC6836@dhcp22.suse.cz>
 <20160616092345.GC432@swordfish>
 <20160616094139.GE6836@dhcp22.suse.cz>
 <20160616095457.GD432@swordfish>
 <20160616101216.GT17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616101216.GT17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Hello,

On (06/16/16 19:12), Minchan Kim wrote:
[..]
> > I'll copy-paste one more backtrace I swa today [originally was posted to another
> > mail thread].
> 
> Please, look at http://lkml.kernel.org/r/20160616100932.GS17127@bbox

I don't have a solid/stable reproducer for this one, but after some
mixed workloads beating (mempressure + zsmalloc + compiler workload)
with reverted b3ceb05f4bae844f67ce I haven't seen any problems.

So I think you nailed it Minchan!


reverted the entire patch set (for simplicity):

    Revert "mm/compaction: split freepages without holding the zone lock"
    Revert "mm/page_owner: initialize page owner without holding the zone lock"
    Revert "mm/page_owner: copy last_migrate_reason in copy_page_owner()"
    Revert "mm/page_owner: introduce split_page_owner and replace manual handling"
    Revert "tools/vm/page_owner: increase temporary buffer size"
    Revert "mm/page_owner: use stackdepot to store stacktrace"
    Revert "mm/page_owner: avoid null pointer dereference"
    Revert "mm/page_alloc: introduce post allocation processing on page allocator"

adding "mm/compaction: split freepages without holding the zone lock"
back seem to introduce the page->map_count bug after some time.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
