Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 452CC6B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:36:21 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u137-v6so2739391itc.4
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:36:21 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j128-v6si2136304itj.45.2018.05.23.05.36.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 05:36:20 -0700 (PDT)
Date: Wed, 23 May 2018 14:36:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523123615.GY12217@hirez.programming.kicks-ass.net>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180509193645.830-4-bigeasy@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

> Most changes are 1:1 replacements except for
> 	BUG_ON(atomic_inc_return(&sh->count) != 1);

That doesn't look right, 'inc_return == 1' implies inc-from-zero, which
is not allowed by refcount.

> which has been turned into
>         refcount_inc(&sh->count);
>         BUG_ON(refcount_read(&sh->count) != 1);

And that is racy, you can have additional increments in between.
