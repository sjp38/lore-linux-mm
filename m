Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 249296B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 21:06:43 -0400 (EDT)
Date: Sun, 11 Apr 2010 03:05:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411010540.GW5708@random.random>
References: <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <20100410204756.GR5708@random.random>
 <4BC0E6ED.7040100@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC0E6ED.7040100@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

> > export MALLOC_MMAP_THRESHOLD_=$[1024*1024*1024]
> > export MALLOC_TOP_PAD_=$[1024*1024*1024]

With the above two params I get around 200M (around half) in
hugepages with gcc building translate.o:

$ rm translate.o ; time make translate.o
  CC    translate.o

real    0m22.900s
user    0m22.601s
sys     0m0.260s
$ rm translate.o ; time make translate.o
  CC    translate.o

real    0m22.405s
user    0m22.125s
sys     0m0.240s
# echo never > /sys/kernel/mm/transparent_hugepage/enabled
# exit
$ rm translate.o ; time make translate.o
  CC    translate.o

real    0m24.128s
user    0m23.725s
sys     0m0.376s
$ rm translate.o ; time make translate.o
  CC    translate.o

real    0m24.126s
user    0m23.725s
sys     0m0.376s
$ uptime
 02:36:07 up 1 day, 19:45,  5 users,  load average: 0.01, 0.12, 0.08

1 sec in 24 means around 4% faster, hopefully when glibc will fully
cooperate we'll get better results than the above with gcc...

I tried to emulate it with khugepaged running in a loop and I get
almost the whole gcc anon memory in hugepages this way (as expected):

# echo 0 > /sys/kernel/mm/transparent_hugepage/khugepaged/scan_sleep_millisecs
# exit
rm translate.o ; time make translate.o
  CC    translate.o

real    0m21.950s
user    0m21.481s
sys     0m0.292s
$ rm translate.o ; time make translate.o
  CC    translate.o

real    0m21.992s
user    0m21.529s
sys     0m0.288s
$ 

So this takes more than 2 seconds away from 24 seconds reproducibly,
and it means gcc now runs 8% faster. This requires running khugepaged
at 100% of one of the four cores but with a slight chance to glibc
we'll be able reach the exact same 8% speedup (or more because this
also involves copying ~200M and sending IPIs to unmap pages and stop
userland during the memory copy that won't be necessary anymore).

BTW, the current default for khugepaged is to scan 8 pmd every 10
seconds, that means collapsing at most 16M every 10 seconds. Checking
8 pmd pointers every 10 seconds and 6 wakeup per minute for a kernel
thread is absolutely unmeasurable but despite the unmeasurable
overhead, it provides for a very nice behavior for long lived
allocations that may have been swapped in fragmented.

This is on phenom X4, I'd be interested if somebody can try on other cpus.

To get the environment of the test just:

git clone git://git.kernel.org/pub/scm/virt/kvm/qemu-kvm.git
cd qemu-kvm
make
cd x86_64-softmmu

export MALLOC_MMAP_THRESHOLD_=$[1024*1024*1024]
export MALLOC_TOP_PAD_=$[1024*1024*1024]
rm translate.o; time make translate.o

Then you need to flip the above sysfs controls as I did.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
