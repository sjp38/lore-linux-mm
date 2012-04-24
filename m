Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D75D76B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 17:30:17 -0400 (EDT)
Date: Tue, 24 Apr 2012 14:30:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
Message-Id: <20120424143015.99fd8d4a.akpm@linux-foundation.org>
In-Reply-To: <CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
	<4F963742.2030607@jp.fujitsu.com>
	<4F963B8E.9030105@kernel.org>
	<CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com>
	<4F965413.9010305@kernel.org>
	<CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Apr 2012 17:48:29 +1000
Nick Piggin <npiggin@gmail.com> wrote:

> > Hmm, there are several places to use GFP_NOIO and GFP_NOFS even, GFP_ATOMIC.
> > I believe it's not trivial now.
> 
> They're all buggy then. Unfortunately not through any real fault of their own.

There are gruesome problems in block/blk-throttle.c (thread "mempool,
percpu, blkcg: fix percpu stat allocation and remove stats_lock").  It
wants to do an alloc_percpu()->vmalloc() from the IO submission path,
under GFP_NOIO.

Changing vmalloc() to take a gfp_t does make lots of sense, although I
worry a bit about making vmalloc() easier to use!

I do wonder whether the whole scheme of explicitly passing a gfp_t was
a mistake and that the allocation context should be part of the task
context.  ie: pass the allocation mode via *current.  As a handy
side-effect that would probably save quite some code where functions
are receiving a gfp_t arg then simply passing it on to the next
callee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
