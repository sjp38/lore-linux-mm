Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 426006B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 16:48:33 -0400 (EDT)
Date: Sat, 10 Apr 2010 22:47:56 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410204756.GR5708@random.random>
References: <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC0E2C4.8090101@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 10, 2010 at 11:42:44PM +0300, Avi Kivity wrote:
> 3-5% improvement.  I had to tune khugepaged to scan more aggressively 
> since the run is so short.  The working set is only ~100MB here though.

We need to either solve it with a kernel workaround or have an
environment var for glibc to do the right thing...

The best I got so far with gcc is with, about half goes in hugepages
with this but it's not enough as likely lib invoked mallocs goes into
heap and extended 1M at time.

export MALLOC_MMAP_THRESHOLD_=$[1024*1024*1024]
export MALLOC_TOP_PAD_=$[1024*1024*1024]

Whatever we do, it has to be possible to disable it of course with
malloc debug options, or with electric fence of course, but it's not
like the default 1M provides any benefit compared to growing it 2M
aligned ;) so it's quite an obvious thing to address in glibc in my
view. Then if it takes too much RAM on small systems echo madvise
>/sys/kernel/mm/transparent_hugepage/enabled will retain the
optimizations in qemu guest physical address space range or other
bits that are guaranteed not to waste memory and that also are a
must-have on embedded that have even smaller l2 caches and slower cpus
where every optimization matters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
