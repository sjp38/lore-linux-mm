Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4BE606B0038
	for <linux-mm@kvack.org>; Sun, 23 Aug 2015 04:17:57 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so46412813wic.1
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 01:17:56 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gs3si14837682wib.29.2015.08.23.01.17.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Aug 2015 01:17:55 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so46680437wid.0
        for <linux-mm@kvack.org>; Sun, 23 Aug 2015 01:17:54 -0700 (PDT)
Date: Sun, 23 Aug 2015 10:17:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/3 v3] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150823081750.GA28349@gmail.com>
References: <20150823060443.GA9882@gmail.com>
 <20150823064603.14050.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150823064603.14050.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* George Spelvin <linux@horizon.com> wrote:

> Ingo Molnar <mingo@kernel.org> wrote:
> > I think this is too complex.
> > 
> > How about something simple like the patch below (on top of the third patch)?
> 
> > It makes the vmalloc info transactional - /proc/meminfo will always print a 
> > consistent set of numbers. (Not that we really care about races there, but it 
> > looks really simple to solve so why not.)
> 
> Looks like a huge simplification!
> 
> It needs a comment about the approximate nature of the locking and
> the obvious race conditions:
> 1) The first caller to get_vmalloc_info() clears vmap_info_changed
>    before updating vmap_info_cache, so a second caller is likely to
>    get stale data for the duration of a calc_vmalloc_info call.
> 2) Although unlikely, it's possible for two threads to race calling
>    calc_vmalloc_info, and the one that computes fresher data updates
>    the cache first, so the later write leaves stale data.
> 
> Other issues:
> 3) Me, I'd make vmap_info_changed a bool, for documentation more than
>    any space saving.
> 4) I wish there were a trylock version of write_seqlock, so we could
>    avoid blocking entirely.  (You *could* hand-roll it, but that eats
>    into the simplicity.)

Ok, fair enough - so how about the attached approach instead, which uses a 64-bit 
generation counter to track changes to the vmalloc state.

This is still very simple, but should not suffer from stale data being returned 
indefinitely in /proc/meminfo. We might race - but that was true before as well 
due to the lock-less RCU list walk - but we'll always return a correct and 
consistent version of the information.

Lightly tested. This is a replacement patch to make it easier to read via email.

I also made sure there's no extra overhead in the !CONFIG_PROC_FS case.

Note that there's an even simpler variant possible I think: we could use just the 
two generation counters and barriers to remove the seqlock.

Thanks,

	Ingo

==============================>
