Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8676060037E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 11:51:33 -0400 (EDT)
Date: Fri, 9 Apr 2010 17:50:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
Message-ID: <20100409155040.GC5708@random.random>
References: <patchbomb.1270691443@v2.random>
 <4BBDA43F.5030309@redhat.com>
 <4BBDC181.5040205@redhat.com>
 <4BBEE920.9020502@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBEE920.9020502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 09, 2010 at 11:45:20AM +0300, Avi Kivity wrote:
> On 04/08/2010 02:44 PM, Avi Kivity wrote:
> >
> >> I'll try running this with a kernel build in parallel.
> >
> > Results here are less than stellar.  While khugepaged is pulling pages 
> > together, something is breaking them apart.  Even after memory 
> > pressure is removed, this behaviour continues.  Can it be that 
> > compaction is tearing down huge pages?
> 
> ok, #19 is a different story.  A 1.2GB sort vs 'make -j12' and a cat of 
> the source tree and some light swapping, all in 2GB RAM, didn't quite 
> reach 1.2GB but came fairly close.  The sort was started while memory 
> was quite low so it had to fight its way up, but even then khugepaged 
> took less that 1.5 seconds total time after a _very_ long compile.

Good. Also please check you're on
8707120d97e7052ffb45f9879efce8e7bd361711, with that one all bugs are
ironed out, it's stable on all my systems under constant mixed heavy
load (the same load would crash it in 1 hour with the memory
compaction bug, or half a day with the anon-vma bugs and no memory
compaction). 8707120d97e7052ffb45f9879efce8e7bd361711 is rock solid as
far as I can tell.

> I observed huge pages being used for gcc as well, likely not bringing 
> much performance since kernel compiles don't use a lot of memory per 
> file.  I'll look at the link stage, that will probably use a lot of 
> large pages.

I also observed them but not too many.... not the whole >200M. You
should probably decrease scan_sleep_millisecs (and
alloc_sleep_millisecs). If you set scan_sleep_millisecs to 0, you'll
run khugepaged in a loop, so gcc should get a whole lot of
hugepages. Only problem is the cost of the khugepaged pmd scan
itself... gcc is too short, but for all longstanding apps khugepaged
is already capable of dealing with slowly extending vm_end even when
run with default scan millisecs.

I guess I'll look into glibc to see what we can do to have gcc use
100% hugepages and hopefully run 6% faster too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
