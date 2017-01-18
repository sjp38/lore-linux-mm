Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC626B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:11:00 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so18404271itb.7
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:11:00 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id 135si1814085ioc.221.2017.01.18.07.10.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:10:59 -0800 (PST)
Date: Wed, 18 Jan 2017 16:10:53 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate
 stack_trace
Message-ID: <20170118151053.GF6500@twins.programming.kicks-ass.net>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-6-git-send-email-byungchul.park@lge.com>
 <20170112161643.GB3144@twins.programming.kicks-ass.net>
 <20170113101143.GE3326@X58A-UD3R>
 <20170117155431.GE5680@worktop>
 <20170118020432.GK3326@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118020432.GK3326@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 11:04:32AM +0900, Byungchul Park wrote:
> On Tue, Jan 17, 2017 at 04:54:31PM +0100, Peter Zijlstra wrote:
> > On Fri, Jan 13, 2017 at 07:11:43PM +0900, Byungchul Park wrote:
> > > What do you think about the following patches doing it?
> > 
> > I was more thinking about something like so...
> > 
> > Also, I think I want to muck with struct stack_trace; the members:
> > max_nr_entries and skip are input arguments to save_stack_trace() and
> > bloat the structure for no reason.
> 
> With your approach, save_trace() must be called whenever check_prevs_add()
> is called, which might be unnecessary.

True.. but since we hold the graph_lock this is a slow path anyway, so I
didn't care much.

Then again, I forgot to clean up in a bunch of paths.

> Frankly speaking, I think what I proposed resolved it neatly. Don't you
> think so?

My initial reaction was to your patches being radically different to
what I had proposed. But after fixing mine I don't particularly like
either one of them.

Also, I think yours has a hole in, you check nr_stack_trace_entries
against an older copy to check we did save_stack(), this is not accurate
as check_prev_add() can drop graph_lock in the verbose case and then
someone else could have done save_stack().


Let me see if I can find something simpler..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
