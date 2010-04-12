Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3C1BE6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 03:36:29 -0400 (EDT)
Date: Mon, 12 Apr 2010 09:35:30 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412073530.GF5656@random.random>
References: <20100410184750.GJ5708@random.random>
 <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <20100412064940.GA7745@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412064940.GA7745@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Nick Piggin <npiggin@suse.de>, Avi Kivity <avi@redhat.com>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 08:49:40AM +0200, Ingo Molnar wrote:
> AFAIK that's what Andrea has done as a test - but yes, i agree that 
> fragmentation is the main design worry.

Well, I didn't only run a kernel compile for a couple of minutes to
show how memory compaction + in-kernel set_recommended_min_free_kbytes
behaved on my system. I can't claim my numbers are conclusive as it
only run for 1 day and half but there was some real unmovable load on
it. Plus uptime isn't the only variable, if you use the kernel to
create an hypervisor product, you can leave it running VM for a much
longer time than 1 day, and it won't ever generate the amount of
unmovable load that I generated in one day and half I guess.

I built a ton of packages including gcc, bison (which in javac
triggered the anon-vma bug before I backed it out) quite some other
stuff that come as a regular update with a couple of emerge world like
kvirc and stuff like that. There was mutt on lkml and linux-mm maildir
with some hundred thousand inodes for the email, and a dozen kernel
builds and git checkouts to verify my aa.git tree. That's what I can
recall. After 1 day and half I still had ~80% of the not allocated ram
in order 9 and maybe ~75% (by memory, could have been more or less I
don't remember exactly but I posted the exact buddyinfo so you can
calculate yourself if curious) in order 10 == MAX_ORDER. The vast
majority of the free ram was in order 10 after echo 3 >drop_caches and
echo >compact_memory, which simulates the maximum ability of the VM to
generate hugepages dynamically (of course it won't ever create such a
totally compacted buddyinfo at runtime as we don't want to shrink or
compact stuff unless it's really needed). Likely if I killed mutt and
other running apps and I would have run drop_caches and memory
compaction again I would have gotten an even higher ratio as result of
more memory being freeable.

One day and half isn't enough, but it was initial data, and then I had
to reboot into a new #20 release to test a memleak fix I did in
do_huge_pmd_wp_page_fallback... I'll try to run it for a longer time
now. I guess I'll be rebuilding quite some glibc on my system as we
optimize it for the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
