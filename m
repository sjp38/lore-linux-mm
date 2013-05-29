Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AC48A6B0159
	for <linux-mm@kvack.org>; Wed, 29 May 2013 13:52:35 -0400 (EDT)
Date: Wed, 29 May 2013 19:52:23 +0200
From: Andres Freund <andres@2ndquadrant.com>
Subject: Re: [patch 1/2] mm: fincore()
Message-ID: <20130529175222.GC4678@awork2.anarazel.de>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
 <20130215063450.GA24047@cmpxchg.org>
 <20130215132738.c85c9eda.akpm@linux-foundation.org>
 <20130215231304.GB23930@cmpxchg.org>
 <20130215154235.0fb36f53.akpm@linux-foundation.org>
 <87621skhtc.fsf@rustcorp.com.au>
 <20130529145312.GE3955@alap2.anarazel.de>
 <20130529173223.GE15721@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130529173223.GE15721@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@kernel.dk>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On 2013-05-29 13:32:23 -0400, Johannes Weiner wrote:
> On Wed, May 29, 2013 at 04:53:12PM +0200, Andres Freund wrote:
> > On 2013-02-16 14:53:43 +1030, Rusty Russell wrote:
> > > Andrew Morton <akpm@linux-foundation.org> writes:
> > > > On Fri, 15 Feb 2013 18:13:04 -0500
> > > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > >> I dunno.  The byte vector might not be optimal but its worst cases
> > > >> seem more attractive, is just as extensible, and dead simple to use.
> > > >
> > > > But I think "which pages from this 4TB file are in core" will not be an
> > > > uncommon usage, and writing a gig of memory to find three pages is just
> > > > awful.
> > > 
> > > Actually, I don't know of any usage for this call.
> > 
> > [months later, catching up]
> > 
> > I do. Postgres' could really use something like that for making saner
> > assumptions about the cost of doing an index/heap scan. postgres doesn't
> > use mmap() and mmaping larger files into memory isn't all that cheap
> > (32bit...) so having fincore would be nice.

> How much of the areas you want to use it against is usually cached?
> I.e. are those 4TB files with 3 cached pages?

Hard to say in general. The point is exactly that we don't know. If
there's nothing of a large index in memory and we estimate that we want
20% of a table we sure won't do an indexscan. If its all in memory?
Different story.
For that usecase its not actually important that we get a 100% accurate
result although I, from my limited understanding, don't really see that
helping much.

(Yes, there are some problems with cache warming here)

> I do wonder if we should just have two separate interfaces.  Ugly, but
> I don't really see how the two requirements (dense but many holes
> vs. huge sparse areas) could be acceptably met with one interface.

The difference would be how the information would be encoded, right? Not
sure how the passed in memory could be sized in some run length encoded
scheme. What I could imagine is specifying the granularity we want
information about, but thats probably too specific.

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
