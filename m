Date: Tue, 15 May 2001 10:24:34 -0700 (PDT)
From: Matt Dillon <dillon@earth.backplane.com>
Message-Id: <200105151724.f4FHOYt54576@earth.backplane.com>
Subject: Re: on load control / process swapping
References: <Pine.LNX.4.21.0105131417550.5468-100000@imladris.rielhome.conectiva> <3B00CECF.9A3DEEFA@mindspring.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Terry Lambert <tlambert2@mindspring.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

:Rik van Riel wrote:
:> So we should not allow just one single large job to take all
:> of memory, but we should allow some small jobs in memory too.
:
:Historically, this problem is solved with a "working set
:quota".

    We have a process-wide working set quota.  It's called the 'memoryuse'
    resource.

:...
:> 5) have a better chance of getting out of the overload situation
:>    sooner
:> 
:> I realise this would make the scheduling algorithm slightly
:> more complex and I'm not convinced doing this would be worth
:> it myself, but we may want to do some brainstorming over this ;)
:
:A per vnode working set quota with a per use count adjust
:would resolve most load thrashing issues.  Programs with

    It most certainly would not.  Limiting the number of pages
    you allow to be 'cached' on a vnode by vnode basis would be a 
    disaster.  It has absolutely nothing whatsoever to do with thrashing
    or thrash-management.  It would simply be an artificial limitation
    based on artificial assumptions that are as likely to be wrong as right.

    If I've learned anything working on the FreeBSD VM system, it's that
    the number of assumptions you make in regards to what programs do,
    how they do it, how much data they should be able to cache, and so forth
    is directly proportional to how badly you fuck up the paging algorithms.

    I implemented a special page-recycling algorithm in 4.1/4.2 (which is
    still there in 4.3).  Basically it tries predict when it is possible to
    throw away pages 'behind' a sequentially accessed file, so as not to
    allow that file to blow away your cache.  E.G. if you have 128M of ram
    and you are sequentially accessing a 200MB file, obviously there is
    not much point in trying to cache the data as you read it.

    But being able to predict something like this is extremely difficult.
    In fact, nearly impossible.  And without being able to make the
    prediction accurately you simply cannot determine how much data you
    should try to cache before you begin recycling it.  I wound up having
    to change the algorithm to act more like a heuristic -- it does a rough
    prediction but doesn't hold the system to it, then allows the page
    priority mechanism to refine the prediction.  But it can take several
    passes (or non-passes) on the file before the page recycling stabilizes.

    So the jist of the matter is that FreeBSD (1) already has process-wide
    working set limitations which are activated when the system is under
    load, and (2) already has a heuristic that attempts to predict when
    not to cache pages.  Actually several heuristics (a number of which were
    in place in the original CSRG code).

						-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
