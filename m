Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEFFE6B0268
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 13:22:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y128so5330620pfg.5
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 10:22:07 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e13si1287211pgt.166.2017.10.27.10.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Oct 2017 10:22:06 -0700 (PDT)
Date: Fri, 27 Oct 2017 10:22:05 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm: Simplify and batch working set shadow pages LRU
 isolation locking
Message-ID: <20171027172205.GA22894@tassilo.jf.intel.com>
References: <20171026234854.25764-1-andi@firstfloor.org>
 <20171027170156.GA1743@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171027170156.GA1743@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org

> The nlru->lock in list_lru_shrink_walk() is the only thing that keeps
> truncation blocked on workingset_update_node() -> list_lru_del() and
> so ultimately keeping it from freeing the radix tree node.
> 
> It's not safe to access the nodes on the private list after that.

True.

> 
> Batching mapping->tree_lock is possible, but you have to keep the
> lock-handoff scheme. Pass a &mapping to list_lru_shrink_walk() and
> only unlock and spin_trylock(&mapping->tree_lock) if it changes?

Yes something like that could work. Thanks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
