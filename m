Message-ID: <45C15CAB.2090607@redhat.com>
Date: Wed, 31 Jan 2007 22:21:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] not to disturb page LRU state when unmapping memory range
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>	<Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>	<1170279811.10924.32.camel@lappy>	<20070131140450.09f174e9.akpm@osdl.org>	<1170282300.10924.50.camel@lappy> <20070131144855.8fe255ff.akpm@osdl.org>
In-Reply-To: <20070131144855.8fe255ff.akpm@osdl.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Perhaps we're approaching this from the wrong direction.  Rather than
> looking at the code and saying "hey, we should change that", we should be
> looking at workloads and seeing how they can be improved.  Perhaps.

I think this makes a lot of sense.  It may not be benchmarkable,
because there is no exhaustive test of workloads, but we can at
least come up with several conceptual groups of workloads that
should be kept in mind when changing things to the VM.

I could think of a few workloads and their characteristics and
desired behaviour:

1) desktop workload - program working sets need to be kept in
    memory and protected from pressure by streaming IO

2) database workload - some pages get accessed more frequently
    than others, those need to be kept resident in memory

3) file server workload - some pages get accessed more frequently
    than others, those need to be kept resident in memory.  This
    is similar to the database workload, except the inter-reference
    distance on a file server is WAY larger and an LRU queue is
    likely not large enough to catch even the frequently accessed
    pages.

4) web server workload - somewhere in-between the desktop and the
    file server, the working sets of the server programs need to be
    kept in memory, and we want to cache the frequently accessed
    data pages

5) developer desktop - like the desktop workload, except we have
    programs like git and rsync doing streaming IO with double
    accesses next to each other, which will push the working sets
    of the desktop programs out of memory if our use-once algorithm
    gets fooled

6) realtime data processing - this kind of workload is usually
    mlocked, but sometimes still wants to do lots of file IO.
    We need to make sure the VM does not get upset by the sometimes
    large amount of mlocked data

7) ... fill in your own workload here :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
