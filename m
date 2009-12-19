Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A1E876B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 10:49:10 -0500 (EST)
Date: Sat, 19 Dec 2009 16:48:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13 of 28] bail out gup_fast on freezed pmd
Message-ID: <20091219154818.GZ29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <6cd9b035a6e0752ec74d.1261076416@v2.random>
 <20091218185934.GE21194@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091218185934.GE21194@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 06:59:34PM +0000, Mel Gorman wrote:
> On Thu, Dec 17, 2009 at 07:00:16PM -0000, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Force gup_fast to take the slow path and block if the pmd is freezed, not only
> > if it's none.
> > 
> 
> What does the slow path do when the same PMD is encountered? Assume it's
> clear later but the set at the moment kinda requires you to understand
> the entire series all at once.

The only brainer thing of gup-fast is the fast
path. The moment you return zero you know you're slow and safe and
simple.

This check below is also why pmdp_splitting_flush has to flush the
tlb, to stop this gup-fast code from running while we set the
splitting bit in the pmd.

The slow path simply will call wait_split_huge_page, gup-fast can't
because it has irq disabled and wait_split_huge_page would never
return as the ipi wouldn't run.

I will add a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
