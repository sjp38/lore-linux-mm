Subject: Re: [patch] not to disturb page LRU state when unmapping memory
	range
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	 <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 31 Jan 2007 22:43:31 +0100
Message-Id: <1170279811.10924.32.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Ken Chen <kenchen@google.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-01-31 at 18:02 +0000, Hugh Dickins wrote:

> I'm sympathetic, but I'm going to chicken out on this one.  It was
> me who made that set_page_dirty and mark_page_accessed conditional on
> !PageAnon: because I didn't like the waste of time either, and could
> see it was pointless in the PageAnon case.  But the situation is much
> less clear to me in the file case, and it is very longstanding code.

> Peter's SetPageReferenced compromise seems appealing: I'd feel better
> about it if we had other raw uses of SetPageReferenced in the balancing
> code, to follow as precedents.  There used to be one in do_anonymous_page,
> but Nick and I found that an odd-one-out and conspired to have it removed
> in 2.6.16.

The trouble seems to be that mark_page_accessed() is deformed by this
use once magick. And that really works against us in this case.

The fact is that these pages can have multiple mappings triggering
multiple calls to mark_page_accessed() launching these pages into the
active set. Which clearly seems wrong to me.

I'll go over other callers tomorrow, but I'd really like to change this
to SetPageReferenced(), this will just preserve the PTE young state and
let page reclaim do its usual thing.

Andrew, any strong opinions?

NOTE - the page_mapcount(page) > 1, idea seems interesting but lets not
go there, yet..

NOTE - recall, that in the PG_useonce patches mark_page_accessed() will
again be a simple:

  if (!PageReferenced(page))
    SetPageReferenced(page);

If only I could come up with a proper set of tests that covers all
this...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
