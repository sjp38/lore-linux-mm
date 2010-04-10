Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0AC136B01E3
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 17:48:31 -0400 (EDT)
Date: Sat, 10 Apr 2010 23:47:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410214726.GS5708@random.random>
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

On Sun, Apr 11, 2010 at 12:00:29AM +0300, Avi Kivity wrote:
> IMO, both.  The kernel should align vmas on 2MB boundaries (good for 
> small pages as well).  glibc should use 2MB increments.  Even on <2MB 

Agreed.

> sized vmas, the kernel should reserve the large page frame for a while 
> in the hope that the application will use it in a short while.

I don't see the need of this per-process, and the buddy logic is already
doing exactly that for us... (even without the movable/unmovable
fallback logic)

> There are also guard pages around stacks IIRC, we could make them 2MB on 
> x86-64.

Agreed. That will provide little benefit though, the stack usage is
quite local near the top and few apps stores bulks of data there (hard
to reach even 512k in size). Firefox has a 300k stack. It'll waste >1M
per process. If it grows and the application is long lived khugepaged
takes care of this already. But personally I tend to like a
black/white approach as much as possible, so I agree to make the vma
large enough immediately if enabled = always.

> Well, but mapping a 2MB vma with a large page could be a considerable 
> waste if the application doesn't eventually use it.  I'd like to map the 
> pages with small pages (belonging to a large frame) and if the 
> application actually uses the pages, switch to a large pte.
>
> Something that can also improve small pages is to prefault the vma with 
> small pages, but with the accessed and dirty bit cleared.  Later, we 
> check those bits and reclaim the pages if they're unused, or coalesce 
> them if they were used.  The nice thing is that we save tons of page 
> faults in the common case where the pages are used.

Yeah we could do that. I'm not against it but it's not my preference
to do these things. Anything that introduces the risk of performance
regressions in corner cases frightens me. I prefer to pay with RAM
anytime.

Again I like to keep the design as black/white as possible, if
somebody is ram constrained he shouldn't leave enabled=always but keep
enabled=madvise. That's the whole point of having added a enabled =
madvise, for who is ram constrained but wants to run faster anyway
with zero ram-waste risk.

These days even desktop systems have more ram than needed so I don't
see the big deal, we should squeeze out of the ram every possible CPU
cycle (even in the user stack even if likely not significant and just
a RAM waste) and not waste CPU in pre-fault or migration of 4k to 2M
pages when the vm_end grows and then having to find which unmapped
pages of a hugepage to reclaim after splitting it on the fly.

I want to reduce to the minimum the risk of regressions anywhere when
full transparency is enabled. This also has the benefit of keeping the
kernel code simpler and with less special cases ;).

It may not be ideal if you've a 1G desktop system and you want to run
faster when encoding a movie, but for that there's exactly
madvise(MADV_HUGEPAGE). qemu-kvm/transcode/ffmpeg all can use a little
madvise on their big chunks of memory. khugepaged should also learn to
prioritize on those VM_HUGEPAGE vmas before scanning the rest (which
it doesn't right now to keep it a bit simpler, but obviously there's
room for improvement).

Anyway I think I we can start with aligning the vmas that don't pad
themselfs with previous vma, to 2M size, and have the stack also
aligned so the page faults will fill them automatically. Changing
glibc to grow 2m instead of 1m is a one liner change to a #define and
it'll also halve the number of mmap syscalls so it's quite
strightforward next step. I also need to make it numa aware with an
alloc_pages_vma. Both are simple enough that I can do them right now
without worries. Then we can re-think at making the kernel more
complex. I don't mean it's bad idea, just less obvious than paying
with RAM and be simpler...  I want to be sure this is rock solid
before we go ahead doing more complex stuff. There have been zero
problems so far (backing out the anon-vma changes solved the only bug
that triggered without memory compaction (showing a skew between the
pmd_huge mappings and page_mapcount because of anon-vma errors), and
memory compaction also works great now with the last integration fix ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
