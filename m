Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E7F2A6B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 10:29:25 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:24:52 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <20100410184750.GJ5708@random.random>
Message-ID: <alpine.DEB.2.00.1004120912180.12455@router.home>
References: <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu> <20100410184750.GJ5708@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 10 Apr 2010, Andrea Arcangeli wrote:

> Full agreement! I think everyone wants transparent hugepage, the only
> compliant I ever heard so far is from Christoph that has some slight
> preference on not introducing split_huge_page and going full hugepage
> everywhere, with native in gup immediately where GUP only returns head
> pages and every caller has to check PageTransHuge on them to see if
> it's huge or not. Changing several hundred of drivers in one go and
> with native swapping with hugepage backed swapcache immediately, which
> means also pagecache has to deal with hugepages immediately, is
> possible too, but I think this more gradual approach is easier to keep
> under control, Rome wasn't built in a day. Surely in a second time I
> want tmpfs backed by hugepages too at least. And maybe pagecache, but
> it doesn't need to happen immediately. Also we've to keep in mind for
> huge systems the PAGE_SIZE should eventually become 2M and those will
> be able to take advantage of transparent hugepages for the 1G
> pud_trans_huge, that will make HPC even faster. Anyway nothing
> prevents to take Christoph's long term direction also by starting self
> contained.

I want hugepages but not the way you have done it here. Follow conventions
and do not introduce on the fly conversion of page size and do not treat a
huge page as a 2M page while also handling the 4k components as separate
pages. Those create additional synchronization issues (like the compound
lock and the refcounting of tail pages). There are existing ways to
convert from 2M to 4k without these issues (see reclaim logic and page
migration). This would be much cleaner.

I am not sure where your imagination ran wild to make the claim that
hundreds of drivers would have to be changed only because of the use of
proper synchronization methods. I have never said that everything has to
be converted in one go but that it would have to be an incremental
process.

Would you please stop building strawmem and telling wild stories?

> To me what is relevant is that everyone in the VM camp seems to want
> transparent hugepages in some shape or form, because of the about
> linear speedup they provide to everything running on them on bare
> metal (and an more than linear cumulative speedup in case of nested
> pagetables for obvious reasons), no matter what design that it is.

We want huge pages yes. But transparent? If you can define transparent
then we may agree at some point. Certainly not transparent in the sense of
volatile objects that suddenly convert from 2M to 4K sizes causing
breakage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
