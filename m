Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 66C576B026A
	for <linux-mm@kvack.org>; Fri,  4 May 2018 12:38:33 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id p138-v6so2766439itc.3
        for <linux-mm@kvack.org>; Fri, 04 May 2018 09:38:33 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q25-v6si4623580iob.104.2018.05.04.09.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 09:38:32 -0700 (PDT)
Date: Fri, 4 May 2018 18:38:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Introduce atomic_dec_and_lock_irqsave()
Message-ID: <20180504163826.GR12217@hirez.programming.kicks-ass.net>
References: <20180504154533.8833-1-bigeasy@linutronix.de>
 <20180504155446.GP12217@hirez.programming.kicks-ass.net>
 <20180504160726.ikotgmd5fbix7b6b@linutronix.de>
 <20180504162102.GQ12217@hirez.programming.kicks-ass.net>
 <20180504162640.GH30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180504162640.GH30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, Shaohua Li <shli@kernel.org>, linux-raid@vger.kernel.org

On Fri, May 04, 2018 at 05:26:40PM +0100, Al Viro wrote:
> On Fri, May 04, 2018 at 06:21:02PM +0200, Peter Zijlstra wrote:
> > On Fri, May 04, 2018 at 06:07:26PM +0200, Sebastian Andrzej Siewior wrote:
> > 
> > > do you intend to kill refcount_dec_and_lock() in the longterm?
> > 
> > You meant to say atomic_dec_and_lock() ? Dunno if we ever get there, but
> > typically dec_and_lock is fairly refcounty, but I suppose it is possible
> > to have !refcount users, in which case we're eternally stuck with it.
> 
> Yes, there are - consider e.g.
> 
> void iput(struct inode *inode)
> { 
>         if (!inode)
>                 return;
>         BUG_ON(inode->i_state & I_CLEAR);
> retry:
>         if (atomic_dec_and_lock(&inode->i_count, &inode->i_lock)) {
> 
> inode->i_count sure as hell isn't refcount_t fodder...

Yeah, I should've remembered, I tried to convert that once ;-) i_count is
a usage count, not a refcount.
