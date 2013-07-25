Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C94846B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:32:11 -0400 (EDT)
Date: Thu, 25 Jul 2013 11:32:07 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mincore() & fincore()
Message-ID: <20130725153207.GA17975@cmpxchg.org>
References: <201307251658.33548.cedric@2ndquadrant.com>
 <201307251707.11159.cedric@2ndquadrant.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201307251707.11159.cedric@2ndquadrant.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?C=E9dric?= Villemain <cedric@2ndquadrant.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Jul 25, 2013 at 05:07:10PM +0200, Cedric Villemain wrote:
> [sorry, previous mail was sent earlier than expected]
> 
> > First, the proposed changes in this email are to be used at least for 
> > PostgreSQL extensions, maybe for core.
> > 
> > Purpose is to offer better monitoring/tracking of the hot/cold areas (and 
> > read/write paterns) in the tables and indexes, in PostgreSQL those are by default 
> > written in segments of 1GB.
> > 
> > There are some possible usecase already:
> > 
> >  * planning of hardware upgrade
> >  * easier configuration setup (both PostgreSQL and linux)
> >  * provide more informations to the planner/executor of PostgreSQL
> > 
> > My ideas so far are to 
> > 
> >  * improve mincore() in linux and add it information like in freeBSD (at 
> >    least adding 'mincore_modified' to track clean vs dirty pages).
> >  * adding fincore() to make the information easier to grab from PostgreSQL (no 
> >    mmap)
> >  * maybe some access to those stats in /proc/
> > 
> > It makes years that libprefetch, mincore() and fincore() are discussed on linux 
> > mailling lists. And they got a good feedback... So I hope it is ok to keep on 
> > those and provide updated patches.
> 
> Johannes, I add you in CC because you're the last one who proposed something. 
> Can I update your patch with previous suggestions from reviewers ?

Absolutely!

> I'm also asking for feedback in this area, others ideas are very welcome.

Andrew didn't like the idea of the one byte per covered page
representation but all proposals to express continuous ranges in a
more compact fashion had worse worst cases and a much more involved
interface.

I do wonder if we should model fincore() after mincore() and add a
separate syscall to query page cache coverage with statistical output
(x present [y dirty, z active, whatever] in specified area) rather
than describing individual pages or continuous chunks of pages in
address order.  That might leave us with better interfaces than trying
to integrate all of this into one arcane syscall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
