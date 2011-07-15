Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 35DC36B0082
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 21:08:47 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6G12Ceq003295
	for <linux-mm@kvack.org>; Sat, 16 Jul 2011 11:02:12 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6G186tM733204
	for <linux-mm@kvack.org>; Sat, 16 Jul 2011 11:08:11 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6G18USx013021
	for <linux-mm@kvack.org>; Sat, 16 Jul 2011 11:08:30 +1000
Date: Fri, 15 Jul 2011 23:10:49 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH 2/2] hugepage: Allow parallelization of the hugepage
 fault path
Message-ID: <20110715131049.GA4368@yookeroo.fritz.box>
References: <20110125143226.37532ea2@kryten>
 <20110125143414.1dbb150c@kryten>
 <m2zkkg6kvs.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2zkkg6kvs.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Anton Blanchard <anton@samba.org>, mel@csn.ul.ie, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 15, 2011 at 12:52:38AM -0700, Andi Kleen wrote:
> Anton Blanchard <anton@samba.org> writes:
> 
> 
> > This patch improves the situation by replacing the single mutex with a
> > table of mutexes, selected based on a hash of the address_space and
> > file offset being faulted (or mm and virtual address for MAP_PRIVATE
> > mappings).
> 
> It's unclear to me how this solves the original OOM problem.
> But then you can still have early oom over all the hugepages if they
> happen to hash to different pages, can't you? 

The spurious OOM case only occurs when the two processes or threads
are racing to instantiate the same page (that is the same page within
an address_space for SHARED or the same virtual address for PRIVATE).
In other cases the OOM is correct behaviour (because we really don't
have enough hugepages to satisfy the requests).

Because of the hash's construction, we're guaranteed than in the
spurious OOM case, both processes or threads will use the same mutex.

> I think it would be better to move out the clearing out of the lock,

We really can't.  The lock has to be taken before we grab a page from
the pool, and can't be released until after the page is "committed"
either by updating the address space's radix tree (SHARED) or the page
tables (PRIVATE).  I can't see anyway the clearing can be moved out of
that.

> and possibly take the lock only when the hugepages are about to 
> go OOM.

This is much easier said than done.  

At one stage I did attempt a more theoretically elegant approach which
is to keep a count of the number of "in-flight" hugepages - OOMs
should be retried if it is non-zero.  I believe that approach can
work, but it turns out to be pretty darn hairy to implement.

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
