Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4375C6B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 21:04:06 -0400 (EDT)
Received: by ykdt205 with SMTP id t205so120663735ykd.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 18:04:06 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id c190si9391378ywa.73.2015.08.23.18.04.04
        for <linux-mm@kvack.org>;
        Sun, 23 Aug 2015 18:04:05 -0700 (PDT)
Date: 23 Aug 2015 21:04:03 -0400
Message-ID: <20150824010403.27903.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
In-Reply-To: <20150823081750.GA28349@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

First, an actual, albeit minor, bug: initializing both vmap_info_gen
and vmap_info_cache_gen to 0 marks the cache as valid, which it's not.

vmap_info_gen should be initialized to 1 to force an initial
cache update.

Second, I don't see why you need a 64-bit counter.  Seqlocks consider
32 bits (31 bits, actually, the lsbit means "update in progress") quite
a strong enough guarantee.

Third, it seems as though vmap_info_cache_gen is basically a duplicate
of vmap_info_lock.sequence.  It should be possible to make one variable
serve both purposes.

You just need a kludge to handle the case of multiple vamp_info updates
between cache updates.

There are two simple ones:

1) Avoid bumping vmap_info_gen unnecessarily.  In vmap_unlock(), do
	vmap_info_gen = (vmap_info_lock.sequence | 1) + 1;
2) - Make vmap_info_gen a seqcount_t
   - In vmap_unlock(), do write_seqcount_barrier(&vmap_info_gen)
   - In get_vmalloc_info, inside the seqlock critical section, do
     vmap_info_lock.seqcount.sequence = vmap_info_gen.sequence - 1;
     (Using the vmap_info_gen.sequence read while validating the
     cache in the first place.)

I should try to write an actual patch illustrating this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
