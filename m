Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CA1F96B0254
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:56:43 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so9721438wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:56:43 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id b19si2312699wiw.16.2015.08.25.02.56.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 02:56:42 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so9673725wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:56:41 -0700 (PDT)
Date: Tue, 25 Aug 2015 11:56:38 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 3/3 v6] mm/vmalloc: Cache the vmalloc memory info
Message-ID: <20150825095638.GA24750@gmail.com>
References: <20150824075018.GB20106@gmail.com>
 <20150824125402.28806.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150824125402.28806.qmail@ns.horizon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: dave@sr71.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@rasmusvillemoes.dk, peterz@infradead.org, riel@redhat.com, rientjes@google.com, torvalds@linux-foundation.org


* George Spelvin <linux@horizon.com> wrote:

> (I hope I'm not annoying you by bikeshedding this too much, although I
> think this is improving.)

[ I don't mind, although I wish other, more critical parts of the kernel got this
  much attention as well ;-) ]

> Anyway, suggested changes for v6 (sigh...):
> 
> First: you do a second read of vmap_info_gen to optimize out the copy
> of vmalloc_info if it's easily seen as pointless, but given how small
> vmalloc_info is (two words!), i'd be inclined to omit that optimization.
> 
> Copy always, *then* see if it's worth keeping.  Smaller code, faster
> fast path, and is barely noticeable on the slow path.

Ok, done.

> Second, and this is up to you, I'd be inclined to go fully non-blocking and
> only spin_trylock().  If that fails, just skip the cache update.

So I'm not sure about this one: we have no guarantee of the order every updater 
reaches the spinlock, and we want the 'freshest' updater to do the update. The 
trylock might cause us to drop the 'freshest' update erroneously - so this change 
would introduce a 'stale data' bug I think.

> Third, ANSI C rules allow a compiler to assume that signed integer
> overflow does not occur.  That means that gcc is allowed to optimize
> "if (x - y > 0)" to "if (x > y)".

That's annoying ...

> Given that gcc has annoyed us by using this optimization in other
> contexts, It might be safer to make them unsigned (which is required to
> wrap properly) and cast to integer after subtraction.

Ok, done.

> Basically, the following (untested, but pretty damn simple):

I've attached v6 which applies your first and last suggestion, but not the trylock 
one.

I also removed _ONCE() accesses from the places that didn't need them.

I added your Reviewed-by optimistically, saving a v7 submission hopefully ;-)

Lightly tested.

Thanks,

	Ingo

==============================>
