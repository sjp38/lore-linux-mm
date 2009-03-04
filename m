Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 66E5F6B00B4
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 13:13:52 -0500 (EST)
Date: Wed, 4 Mar 2009 18:13:47 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [patch][rfc] mm: hold page lock over page_mkwrite
Message-ID: <20090304181347.GA10233@shareable.org>
References: <20090225093629.GD22785@wotan.suse.de> <20090301081744.GI26138@disturbed> <20090301135057.GA26905@wotan.suse.de> <20090302081953.GK26138@disturbed> <20090302083718.GE1257@wotan.suse.de> <49ABFA9D.90801@hp.com> <20090303043338.GB3973@wotan.suse.de> <20090303172535.GA16993@shareable.org> <20090304092343.GB27043@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090304092343.GB27043@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: jim owens <jowens@hp.com>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> > Suppose the systems has two pages to be written.  The first must
> > _reserve_ 40 pages of scratch space just in case the operation will
> > need them.  If the second page write is initiated concurrently with
> > the first, the second must reserve another 40 pages concurrently.
> > 
> > If 10 page writes are concurrent, that's 400 pages of scratch space
> > needed in reserve...
> 
> You only need to guarantee forward progress, so you would reserve
> 40 pages up front for the entire machine (some mempools have more
> memory than strictly needed to improve performance, so you could
> toy with that, but let's just describe the baseline).
> 
> So allocations happen as normal, except when an allocation fails,
> then the task which fails the allocation is given access to this
> reserve memory, any other task requiring reserve will then block.
> 
> Now the reserve provides enough pages to guarantee forward progress,
> so that one task is going to be able to proceed and eventually its
> pages will become freeable and can be returned to the reserve. Once
> the writeout has finished, the reserve will become available to
> other tasks.
> 
> So this way you only have to reserve enough to write out 1 page,
> and you only start blocking things when their memory allocations
> wolud have failed *anyway*. And you guarantee forward progress.

Ah.  *light bulb*  In the writing tasks, memory allocation is
forbidden, but blocking is allowed.  That's what I was missing :-)

Forward progress marches on.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
