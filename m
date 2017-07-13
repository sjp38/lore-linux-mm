Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C021440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 22:08:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z1so43299091pgs.10
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 19:08:32 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 6si3055846pfz.398.2017.07.12.19.08.30
        for <linux-mm@kvack.org>;
        Wed, 12 Jul 2017 19:08:31 -0700 (PDT)
Date: Thu, 13 Jul 2017 11:07:45 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170713020745.GG20323@X58A-UD3R>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
 <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Jul 12, 2017 at 09:56:17AM +0200, Peter Zijlstra wrote:
> On Wed, Jul 12, 2017 at 11:00:53AM +0900, Byungchul Park wrote:
> > On Tue, Jul 11, 2017 at 06:12:32PM +0200, Peter Zijlstra wrote:
> 
> > > Right, like I wrote in the comment; I don't think you need quite this
> > > much.
> > > 
> > > The problem only happens if you rewind more than MAX_XHLOCKS_NR;
> > > although I realize it can be an accumulative rewind, which makes it
> > > slightly more tricky.
> > > 
> > > We can either make the rewind more expensive and make xhlock_valid()
> > > false for each rewound entry; or we can keep the max_idx and account
> > 
> > Does max_idx mean the 'original position - 1'?
> 
> 	orig_idx = current->hist_idx;
> 	current->hist_idx++;
> 	if ((int)(current->hist_idx - orig_idx) > 0)
> 	  current->hist_idx_max = current->hist_idx;
> 
> 
> I've forgotten if the idx points to the most recent entry or beyond it.
> 
> Given the circular nature, and tail being one ahead of head, the max
> effectively tracks the tail (I suppose we can also do an explicit tail
> tracking, but that might end up more difficult).
> 
> This allows rewinds of less than array_size() while still maintaining a
> correct tail.
> 
> Only once we (cummulative or not) rewind past the tail -- iow, loose the
> _entire_ history, do we need to do something drastic.

I am sorry but I don't understand why we have to do the drastic work.

Does my approach have problems, rewinding to 'original idx' on exit and
deciding whether overwrite or not? I think, this way, no need to do the
drastic work. Or.. does my one get more overhead in usual case?

> 
> > > from there. If we rewind >= MAX_XHLOCKS_NR from the max_idx we need to
> > > invalidate the entire state, which we can do by invaliding
> > 
> > Could you explain what the entire state is?
> 
> All hist_lock[]. Did the above help?
> 
> > > xhlock_valid() or by re-introduction of the hist_gen_id. When we
> > 
> > What does the re-introduction of the hist_gen_id mean?
> 
> What you used to call work_id or something like that. A generation count
> for the hist_lock[].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
