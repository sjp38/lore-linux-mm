Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9620F6B0036
	for <linux-mm@kvack.org>; Wed, 21 May 2014 17:34:05 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so3404850wiw.4
        for <linux-mm@kvack.org>; Wed, 21 May 2014 14:34:05 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id bk5si17356542wjb.142.2014.05.21.14.34.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 14:34:01 -0700 (PDT)
Date: Wed, 21 May 2014 23:33:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140521213354.GL2485@laptop.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, May 21, 2014 at 02:26:22PM -0700, Andrew Morton wrote:
> > +static inline void
> > +__prepare_to_wait(wait_queue_head_t *q, wait_queue_t *wait,
> > +			struct page *page, int state, bool exclusive)
> 
> Putting MM stuff into core waitqueue code is rather bad.  I really
> don't know how I'm going to explain this to my family.

Right, so we could avoid all that and make the functions in mm/filemap.c
rather large and opencode a bunch of wait.c stuff.

Which is pretty much what I initially pseudo proposed.

> > +		__ClearPageWaiters(page);
> 
> We're freeing the page - if someone is still waiting on it then we have
> a huge bug?  It's the mysterious collision thing again I hope?

Yeah, so we only clear that bit when at 'unlock' we find there are no
more pending waiters, so if the last unlock still had a waiter, we'll
leave the bit set. So its entirely reasonable to still have it set when
we free a page etc..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
