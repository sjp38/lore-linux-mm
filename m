Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A355F6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 14:45:02 -0400 (EDT)
Date: Tue, 4 Aug 2009 12:13:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
 script for page-allocator-related ftrace events
Message-Id: <20090804121332.46df33a7.akpm@linux-foundation.org>
In-Reply-To: <4A787D84.2030207@redhat.com>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
	<1249409546-6343-5-git-send-email-mel@csn.ul.ie>
	<20090804112246.4e6d0ab1.akpm@linux-foundation.org>
	<4A787D84.2030207@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: mel@csn.ul.ie, lwoodman@redhat.com, mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Aug 2009 14:27:16 -0400
Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> > On Tue,  4 Aug 2009 19:12:26 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> > 
> >> This patch adds a simple post-processing script for the page-allocator-related
> >> trace events. It can be used to give an indication of who the most
> >> allocator-intensive processes are and how often the zone lock was taken
> >> during the tracing period. Example output looks like
> >>
> >> find-2840
> >>  o pages allocd            = 1877
> >>  o pages allocd under lock = 1817
> >>  o pages freed directly    = 9
> >>  o pcpu refills            = 1078
> >>  o migrate fallbacks       = 48
> >>    - fragmentation causing = 48
> >>      - severe              = 46
> >>      - moderate            = 2
> >>    - changed migratetype   = 7
> > 
> > The usual way of accumulating and presenting such measurements is via
> > /proc/vmstat.  How do we justify adding a completely new and different
> > way of doing something which we already do?
> 
> Mel's tracing is more akin to BSD process accounting,
> where these statistics are kept on a per-process basis.

Is that useful?  Any time I've wanted to find out things like this, I
just don't run other stuff on the machine at the same time.

Maybe there are some scenarios where it's useful to filter out other
processes, but are those scenarios sufficiently important to warrant
creation of separate machinery like this?

> Nothing in /proc allows us to see statistics on a per
> process basis on process exit.

Can this script be used to monitor the process while it's still running?



Also, we have a counter for "moderate fragmentation causing migrate
fallbacks".  There must be hundreds of MM statistics which can be
accumulated once we get down to this level of detail.  Why choose these
nine?


Is there a plan to add the rest later on?


Or are these nine more a proof-of-concept demonstration-code thing?  If
so, is it expected that developers will do an ad-hoc copy-n-paste to
solve a particular short-term problem and will then toss the tracepoint
away?  I guess that could be useful, although you can do the same with
vmstat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
