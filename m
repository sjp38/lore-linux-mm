Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 805136B0006
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:55:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e20-v6so13133873pff.14
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:55:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z30-v6si18302749pfg.266.2018.05.23.05.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 23 May 2018 05:55:49 -0700 (PDT)
Date: Wed, 23 May 2018 14:55:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/8] md: raid5: use refcount_t for reference counting
 instead atomic_t
Message-ID: <20180523125542.GT12198@hirez.programming.kicks-ass.net>
References: <20180509193645.830-1-bigeasy@linutronix.de>
 <20180509193645.830-4-bigeasy@linutronix.de>
 <20180523123615.GY12217@hirez.programming.kicks-ass.net>
 <20180523125007.pbxcxef622cde3jz@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523125007.pbxcxef622cde3jz@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org, Anna-Maria Gleixner <anna-maria@linutronix.de>

On Wed, May 23, 2018 at 02:50:07PM +0200, Sebastian Andrzej Siewior wrote:
> On 2018-05-23 14:36:15 [+0200], Peter Zijlstra wrote:
> > > Most changes are 1:1 replacements except for
> > > 	BUG_ON(atomic_inc_return(&sh->count) != 1);
> > 
> > That doesn't look right, 'inc_return == 1' implies inc-from-zero, which
> > is not allowed by refcount.
> > 
> > > which has been turned into
> > >         refcount_inc(&sh->count);
> > >         BUG_ON(refcount_read(&sh->count) != 1);
> > 
> > And that is racy, you can have additional increments in between.
> 
> so do we stay with the atomic* API here or do we extend refcount* API?

Stay with the atomic; I'll look at the rest of these patches, but raid5
looks like a usage-count, not a reference count.

I'll probably ack your initial set and parts of this.. but let me get to
the end of this first.
