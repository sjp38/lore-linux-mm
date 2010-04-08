Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 80032600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 12:03:14 -0400 (EDT)
Date: Thu, 8 Apr 2010 18:02:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
Message-ID: <20100408160240.GG5749@random.random>
References: <patchbomb.1270691443@v2.random>
 <4BBDA43F.5030309@redhat.com>
 <4BBDC181.5040205@redhat.com>
 <20100408152302.GA5749@random.random>
 <4BBDF5CA.5050907@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BBDF5CA.5050907@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 08, 2010 at 06:27:06PM +0300, Avi Kivity wrote:
> On 04/08/2010 06:23 PM, Andrea Arcangeli wrote:
> > On Thu, Apr 08, 2010 at 02:44:01PM +0300, Avi Kivity wrote:
> >    
> >> Results here are less than stellar.  While khugepaged is pulling pages
> >> together, something is breaking them apart.  Even after memory pressure
> >> is removed, this behaviour continues.  Can it be that compaction is
> >> tearing down huge pages?
> >>      
> > migrate will split hugepages, but memory compaction shouldn't migrate
> > hugepages... If it does I agree it needs fixing.
> >
> >    
> 
> Well, khugepaged was certainly fighting with something.  Perhaps ftrace 
> will point the finger.

It's likely splitting and migrating hugepages really, like you just
said.

> It ran stably for me FWIW.

It's not easily reproducible (the tiny race in memcg prepare_migration
also was hard to reproduce but that one was easy to fix by reproducing
it just once). I suspect something's wrong with isolate_migratepages,
I don't see where it skips tail pages, and it should skip all compound
pages to avoid migrating them which would also solve your
issue. something like that... ;). I think migration splits the
hugepages good enough and while migration has a pin on the page (to
keep khugepaged away).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
