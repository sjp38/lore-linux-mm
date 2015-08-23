Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id D87106B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 02:46:05 -0400 (EDT)
Received: by ykfw73 with SMTP id w73so107532102ykf.3
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 23:46:05 -0700 (PDT)
Received: from ns.horizon.com (ns.horizon.com. [71.41.210.147])
        by mx.google.com with SMTP id e125si8200783ywf.83.2015.08.22.23.46.04
        for <linux-mm@kvack.org>;
        Sat, 22 Aug 2015 23:46:05 -0700 (PDT)
Date: 23 Aug 2015 02:46:03 -0400
Message-ID: <20150823064603.14050.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
Subject: Re: [PATCH 0/3] mm/vmalloc: Cache the /proc/meminfo vmalloc statistics
In-Reply-To: <20150823060443.GA9882@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@horizon.com, mingo@kernel.org
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org

Ingo Molnar <mingo@kernel.org> wrote:
> I think this is too complex.
> 
> How about something simple like the patch below (on top of the third patch)?

> It makes the vmalloc info transactional - /proc/meminfo will always print a 
> consistent set of numbers. (Not that we really care about races there, but it 
> looks really simple to solve so why not.)

Looks like a huge simplification!

It needs a comment about the approximate nature of the locking and
the obvious race conditions:
1) The first caller to get_vmalloc_info() clears vmap_info_changed
   before updating vmap_info_cache, so a second caller is likely to
   get stale data for the duration of a calc_vmalloc_info call.
2) Although unlikely, it's possible for two threads to race calling
   calc_vmalloc_info, and the one that computes fresher data updates
   the cache first, so the later write leaves stale data.

Other issues:
3) Me, I'd make vmap_info_changed a bool, for documentation more than
   any space saving.
4) I wish there were a trylock version of write_seqlock, so we could
   avoid blocking entirely.  (You *could* hand-roll it, but that eats
   into the simplicity.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
