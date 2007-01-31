Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l0VLp9jU015636
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:51:09 -0800
Received: from wr-out-0506.google.com (wri57.prod.google.com [10.54.9.57])
	by zps38.corp.google.com with ESMTP id l0VLo6vH001971
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:51:00 -0800
Received: by wr-out-0506.google.com with SMTP id 57so330743wri
        for <linux-mm@kvack.org>; Wed, 31 Jan 2007 13:51:00 -0800 (PST)
Message-ID: <b040c32a0701311351q5d0b13c0r2813f8da85197062@mail.gmail.com>
Date: Wed, 31 Jan 2007 13:51:00 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [patch] not to disturb page LRU state when unmapping memory range
In-Reply-To: <1170279811.10924.32.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
	 <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
	 <1170279811.10924.32.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Wed, 2007-01-31 at 18:02 +0000, Hugh Dickins wrote:
>
> > I'm sympathetic, but I'm going to chicken out on this one.  It was
> > me who made that set_page_dirty and mark_page_accessed conditional on
> > !PageAnon: because I didn't like the waste of time either, and could
> > see it was pointless in the PageAnon case.  But the situation is much
> > less clear to me in the file case, and it is very longstanding code.
>
> > Peter's SetPageReferenced compromise seems appealing: I'd feel better
> > about it if we had other raw uses of SetPageReferenced in the balancing
> > code, to follow as precedents.  There used to be one in do_anonymous_page,
> > but Nick and I found that an odd-one-out and conspired to have it removed
> > in 2.6.16.
>
> The trouble seems to be that mark_page_accessed() is deformed by this
> use once magick. And that really works against us in this case.
>
> The fact is that these pages can have multiple mappings triggering
> multiple calls to mark_page_accessed() launching these pages into the
> active set. Which clearly seems wrong to me.
>
> I'll go over other callers tomorrow, but I'd really like to change this
> to SetPageReferenced(), this will just preserve the PTE young state and
> let page reclaim do its usual thing.

I agree with Peter on changing it to SetPageReferenced() as a middle
ground.  Tested and it does relief majority of the problem by eliminate
calls to activate_page().  Ack'ing on Peter's earlier patch.

Acked-by: Ken Chen <kenchen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
