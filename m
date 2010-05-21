Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE9A6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 01:13:20 -0400 (EDT)
Date: Fri, 21 May 2010 15:13:02 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Transparent Hugepage Support #25
Message-ID: <20100521051302.GK2516@laptop>
References: <20100521000539.GA5733@random.random>
 <1274412373.4977.8.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1274412373.4977.8.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Fri, May 21, 2010 at 05:26:13AM +0200, Eric Dumazet wrote:
> Le vendredi 21 mai 2010 a 02:05 +0200, Andrea Arcangeli a ecrit :
> > If you're running scientific applications, JVM or large gcc builds
> > (see attached patch for gcc), and you want to run from 2.5% faster for
> > kernel build (on bare metal), or 8% faster in translate.o of qemu (on
> > bare metal), 15% faster or more with virt and Intel EPT/ AMD NPT
> > (depending on the workload), you should apply and run the transparent
> > hugepage support on your systems.
> > 
> > Awesome results have already been posted on lkml, if you test and
> > benchmark it, please provide any positive/negative real-life result on
> > lkml (or privately to me if you prefer). The more testing the better.
> > 
> 
> Interesting !
> 
> Did you tried to change alloc_large_system_hash() to use hugepages for
> very large allocations ? We currently use vmalloc() on NUMA machines...
> 
> Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
> Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
> IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
> TCP established hash table entries: 524288 (order: 11, 8388608 bytes)

Different (easier) kind of problem there.

We should indeed start using hugepages for special vmalloc cases like
this eventually. Last time I checked, we didn't quite have enough memory
per node to do this (ie. it does not end up being interleaved over all
nodes). It probably starts becoming realistic to do this soon with the
rate of memory size increases.

Probably for tuned servers where various hashes are sized very large,
it already makes sese.

It's on my TODO list.

> 
> 
> 0xffffc90000003000-0xffffc90001004000 16781312 alloc_large_system_hash+0x1d8/0x280 pages=4096 vmalloc vpages N0=2048 N1=2048
> 0xffffc9000100f000-0xffffc90001810000 8392704 alloc_large_system_hash+0x1d8/0x280 pages=2048 vmalloc vpages N0=1024 N1=1024
> 0xffffc90005882000-0xffffc90005c83000 4198400 alloc_large_system_hash+0x1d8/0x280 pages=1024 vmalloc vpages N0=512 N1=512
> 0xffffc90005c84000-0xffffc90006485000 8392704 alloc_large_system_hash+0x1d8/0x280 pages=2048 vmalloc vpages N0=1024 N1=1024
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
