Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 03D636B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 07:53:53 -0400 (EDT)
Date: Sun, 11 Apr 2010 13:52:29 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: hugepages will matter more in the future
Message-ID: <20100411115229.GB10952@elte.hu>
References: <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
 <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC1B034.4050302@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> > It is no doubt that benchmark advantages can be shown - the point of this 
> > exercise is to show that there are real-life speedups to various 
> > categories of non-server apps that hugetlb gives us.
> 
> I think hugetlb will mostly help server apps.  Desktop apps simply don't 
> have working sets big enough to matter.  There will be exceptions, but as a 
> rule, desktop apps won't benefit much from this.

Both Xorg, xterms and firefox have rather huge RSS's on my boxes. (Even a 
phone these days easily has more than 512 MB RAM.) Andrea measured 
multi-percent improvement in gcc performance. I think it's real.

Also note that IMO hugetlbs will matter _more_ in the future, even if CPU 
designers do a perfect job and CPU caches stay well-balanced to typical 
working sets: because RAM size is increasing somewhat faster than CPU cache 
size, due to the different physical constraints that CPUs face.

A quick back-of-the-envelope estimation: 20 years ago the high-end desktop had 
4MB of RAM and 64K of a cache [1:64 proportion], today it has 16 GB of RAM and 
8 MB of L2 cache on the CPU [1:2048 proportion].

App working sets track typical RAM sizes [it is their primary limit], not 
typical CPU cache sizes.

So while RAM size is exploding, CPU cache sizes cannot grow that fast and 
there's an increasing 'gap' between the pagetable size of higher-end 
RAM-filling workloads and CPU cache sizes - which gap the CPU itself cannot 
possibly close or mitigate in the future.

Also, the proportion of 4K:2MB is a fixed constant, and CPUs dont grow their 
TLB caches as much as typical RAM size grows: they'll grow it according to the 
_mean_ working set size - while the 'max' working set gets larger and larger 
due to the increasing [proportional] gap to RAM size.

Put in a different way: this slow, gradual phsyical process causes data-cache 
misses to become 'colder and colder': in essence a portion of the worst-case 
TLB miss cost gets added to the average data-cache miss cost on more and more 
workloads. (Even without any nested-pagetables or other virtualization 
considerations.) The CPU can do nothing about this - even if it stays in a 
golden balance with typical workloads.

Hugetlbs were ridiculous 10 years ago, but are IMO real today. My prediction 
is that in 5-10 years we'll be thinking about 1GB pages for certain HPC apps 
and 2MB pages will be common on the desktop.

This is why i think we should think about hugetlb support today and this is 
why i think we should consider elevating hugetlbs to the next level of 
built-in Linux VM support.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
