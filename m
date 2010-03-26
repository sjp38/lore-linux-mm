Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1016B01FB
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 17:33:17 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o2QLWo63016330
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 22:32:50 +0100
Received: from ewy24 (ewy24.prod.google.com [10.241.103.24])
	by kpbe11.cbf.corp.google.com with ESMTP id o2QLWlnU012012
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 16:32:48 -0500
Received: by ewy24 with SMTP id 24so205790ewy.33
        for <linux-mm@kvack.org>; Fri, 26 Mar 2010 14:32:46 -0700 (PDT)
Date: Fri, 26 Mar 2010 21:32:28 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 35 of 41] don't leave orhpaned swap cache after ksm
 merging
In-Reply-To: <20100326172321.GA5825@random.random>
Message-ID: <alpine.LSU.2.00.1003262113310.8896@sister.anvils>
References: <patchbomb.1269622804@v2.random> <6a19c093c020d009e736.1269622839@v2.random> <4BACEBF8.90909@redhat.com> <20100326172321.GA5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Mar 2010, Andrea Arcangeli wrote:
> On Fri, Mar 26, 2010 at 01:16:40PM -0400, Rik van Riel wrote:
> > On 03/26/2010 01:00 PM, Andrea Arcangeli wrote:
> > > From: Andrea Arcangeli<aarcange@redhat.com>
> > >
> > > When swapcache is replaced by a ksm page don't leave orhpaned swap cache.
> > 
> > Why is this part of the hugepage series?
> 
> This is a not relevant for hugepages. There's another ksm change so I
> thought I could sneak it in. It's still separated so it can be pulled
> off separately as needed.

It's a nice little catch, but you certainly shouldn't have buried it
amidst 40 other patches unrelated to it!

I was going to ack that patch and urge you to forward it to Andrew
separately, but did you test whether it works?  Isn't it actually a
no-op?  Because KSM is holding page lock across replace_page() (maybe
that's something I added after you were last there - at the time I did
it just from instinct, and to make a block look prettier; but later I
believe it turned out to be necessary), and free_swap_cache() only
works if trylock_page() succeeds.

So if we want the fix, I think it would have to be reworked, perhaps
slightly messier.

Something needed for -stable?  No, I think not, it's a situation that
gradually increases memory pressure, and then memory pressure frees it
(vmscan.c's __delete_from_swap_cache); it never prevents swapoff.

But it would be nice to fix it all the same: thanks for spotting.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
