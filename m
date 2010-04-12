Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A736E6B01EF
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 13:47:22 -0400 (EDT)
Message-ID: <4BC35C61.7010201@redhat.com>
Date: Mon, 12 Apr 2010 13:46:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: hugepages will matter more in the future
References: <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <alpine.LFD.2.00.1004110814080.3576@i5.linux-foundation.org> <4BC1EE13.7080702@redhat.com> <alpine.LFD.2.00.1004110844420.3576@i5.linux-foundation.org> <4BC34837.7020108@redhat.com> <alpine.LFD.2.00.1004120929290.26679@i5.linux-foundation.org> <20100412173632.GB5583@random.random>
In-Reply-To: <20100412173632.GB5583@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 01:36 PM, Andrea Arcangeli wrote:

> I should make the default selectable at kernel config time, so
> developers can keep it =always and distro can set it =madvise (trivial
> to switch to "always" during boot or with kernel command line). Right
> now it's =always also to give it more testing btw.

That still means the code will not benefit most applications.

Surely a more benign default behaviour is possible?  For
example, instantiating hugepages on pagefault only in VMAs
that are significantly larger than a hugepage (say, 16MB or
larger?) and not VM_GROWSDOWN (stack starts small).

We can still collapse the small pages into a large page if
the process starts actually using the memory in the VMA.

Memory use is a serious concern for some people, even people
who could really benefit from the hugepages.  For example,
my home desktop system has 12GB RAM, but also runs 3 production
virtual machines (kernelnewbies, PSBL, etc) and often has a
test virtual machine as well.

Not wasting memory is important, since the system is constantly
doing disk IO.  Any memory that is taken away from the page
cache could hurt things.  On the other hand, speeding up the
virtual machines by 6% could be a big help too...

I'd like to think we can find a way to get the best of both
worlds.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
