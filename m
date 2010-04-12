Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 14ED96B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 13:37:43 -0400 (EDT)
Date: Mon, 12 Apr 2010 19:36:32 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412173632.GB5583@random.random>
References: <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org>
 <4BC1EE13.7080702@redhat.com>
 <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org>
 <4BC34837.7020108@redhat.com>
 <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 09:40:54AM -0700, Linus Torvalds wrote:
> Yet now, the possibility of _truly_ wasting memory isn't apparently even a 
> blip on anybody's radar. People blithely talk about changing glibc default 
> behavior as if there are absolutely no issues, and 2MB chunks are pocket 
> change.

This is about enabled=always, in some cases we'll waste memory in the
hope to run faster, correct.

> I can pretty much guarantee that every single developer on this list has a 
> machine with excessive amounts of memory compared to what the machine is 
> actually required to do. And I just do not think that is true in general.

If this is the concern about general use, it's enough to make the
default:

    echo madvise >/sys/kernel/mm/transparent_hugepage/enabled

and then only madvise(MADV_HUGEPAGE) (like qemu guest physical memory)
will use it, and khugepaged will _only_ scan madvise regions. That
guarantees zero RAM waste, and even a 128M embedded definitely should
enable and take advantage of it to squeeze a few cycles away from a
slow CPU. It's a one liner change.

I should make the default selectable at kernel config time, so
developers can keep it =always and distro can set it =madvise (trivial
to switch to "always" during boot or with kernel command line). Right
now it's =always also to give it more testing btw.

Also note about glibc, our target is to replace libhugetlbfs and
pratically make libhugetlbfs the default. Applications calling mmap
and not passing through malloc, or using libs not possible to
override, will also not be able to take advantage of libhugetlbfs so
that's ok. If somebody scatters 4k mappings all over the virtual
address space of a task, I don't like to allocate 2M pages for those
4k virtual mappings (even if it'd be possible to reclaim them pretty
fast without I/O), though even that is theoretically possible. I just
prefer to have a glibc that cooperates, just like libhugetlbfs
cooperates with hugetlbfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
