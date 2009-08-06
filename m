Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1DE116B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 06:21:01 -0400 (EDT)
Date: Thu, 6 Aug 2009 12:20:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806102057.GQ23385@random.random>
References: <20090805024058.GA8886@localhost>
 <20090805155805.GC23385@random.random>
 <20090806100824.GO23385@random.random>
 <4A7AAE07.1010202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7AAE07.1010202@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 01:18:47PM +0300, Avi Kivity wrote:
> Reasonable; if you depend on a hint from userspace, that hint can be 
> used against you.

Correct, that is my whole point. Also we never know if applications
are mmapping huge files with MAP_EXEC just because they might need to
trampoline once in a while, or do some little JIT thing once in a
while. Sometime people open files with O_RDWR even if they only need
O_RDONLY. It's not a bug, but radically altering VM behavior because
of a bitflag doesn't sound good to me.

I certainly see this tends to help as it will reactivate all
.text. But this signals current VM behavior is not ok for small
systems IMHO if such an hack is required. I prefer a dynamic algorithm
that when active list grow too much stop reactivating pages and
reduces the time for young bit activation only to the time the page
sits on the inactive list. And if active list is small (like 128M
system) we  fully trust young bit and if it set, we don't allow it to
go in inactive list as it's quick enough to scan the whole active
list, and young bit is meaningful there.

The issue I can see is with huge system and million pages in active
list, by the time we can it all, too much time has passed and we don't
get any meaningful information out of young bit. Things are radically
different on all regular workstations, and frankly regular
workstations are very important too, as I suspect there are more users
running on <64G systems than on >64G systems.

> How about, for every N pages that you scan, evict at least 1 page, 
> regardless of young bit status?  That limits overscanning to a N:1 
> ratio.  With N=250 we'll spend at most 25 usec in order to locate one 
> page to evict.

Yes exactly, something like that I think will be dynamic, and then we
can drop VM_EXEC check and solve the issues on large systems while
still not almost totally ignoring young bit on small systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
