Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5D6D6B0313
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 03:56:24 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v26so16434610pfa.0
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 00:56:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 90si1380517pfr.15.2017.07.12.00.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 00:56:23 -0700 (PDT)
Date: Wed, 12 Jul 2017 09:56:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 06/16] lockdep: Detect and handle hist_lock ring
 buffer overwrite
Message-ID: <20170712075617.o2jds2giuoqxjqic@hirez.programming.kicks-ass.net>
References: <1495616389-29772-1-git-send-email-byungchul.park@lge.com>
 <1495616389-29772-7-git-send-email-byungchul.park@lge.com>
 <20170711161232.GB28975@worktop>
 <20170712020053.GB20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170712020053.GB20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Jul 12, 2017 at 11:00:53AM +0900, Byungchul Park wrote:
> On Tue, Jul 11, 2017 at 06:12:32PM +0200, Peter Zijlstra wrote:

> > Right, like I wrote in the comment; I don't think you need quite this
> > much.
> > 
> > The problem only happens if you rewind more than MAX_XHLOCKS_NR;
> > although I realize it can be an accumulative rewind, which makes it
> > slightly more tricky.
> > 
> > We can either make the rewind more expensive and make xhlock_valid()
> > false for each rewound entry; or we can keep the max_idx and account
> 
> Does max_idx mean the 'original position - 1'?

	orig_idx = current->hist_idx;
	current->hist_idx++;
	if ((int)(current->hist_idx - orig_idx) > 0)
	  current->hist_idx_max = current->hist_idx;


I've forgotten if the idx points to the most recent entry or beyond it.

Given the circular nature, and tail being one ahead of head, the max
effectively tracks the tail (I suppose we can also do an explicit tail
tracking, but that might end up more difficult).

This allows rewinds of less than array_size() while still maintaining a
correct tail.

Only once we (cummulative or not) rewind past the tail -- iow, loose the
_entire_ history, do we need to do something drastic.

> > from there. If we rewind >= MAX_XHLOCKS_NR from the max_idx we need to
> > invalidate the entire state, which we can do by invaliding
> 
> Could you explain what the entire state is?

All hist_lock[]. Did the above help?

> > xhlock_valid() or by re-introduction of the hist_gen_id. When we
> 
> What does the re-introduction of the hist_gen_id mean?

What you used to call work_id or something like that. A generation count
for the hist_lock[].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
