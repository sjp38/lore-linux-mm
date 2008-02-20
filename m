Date: Wed, 20 Feb 2008 15:03:39 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080220210339.GA25659@sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220103942.GU7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 11:39:42AM +0100, Andrea Arcangeli wrote:
> Given Nick's comments I ported my version of the mmu notifiers to
> latest mainline. There are no known bugs AFIK and it's obviously safe
> (nothing is allowed to schedule inside rcu_read_lock taken by
> mmu_notifier() with my patch).
> ....

I ported the GRU driver to use the latest #v6 patch and ran a series of
tests on it using our system simulator. The simulator is slow so true
stress or swapping is not possible - at least within a finite amount of
time.

Functionally, the #v6 patch seems to work for the GRU. However, I did
notice two significant differences that make the #v6 performance worse for
the GRU than Christoph's patch.  I think one difference is easily fixable
but the other is more difficult:

	- the location of the mmu_notifier_release() callout is at a
	  different place in the 2 patches. Christoph has the callout
	  BEFORE the call to unmap_vmas() whereas you have it AFTER. The
	  net result is that the GRU does a LOT of 1-page TLB flushes
	  during process teardown.  These flushes are not done with
	  Christops's patch.

	- the range callouts in Christoph's patch benefit the GRU because
	  multiple TLB entries can be flushed with a single GRU
	  instruction (the GRU hardware supports a range flush using a
	  vaddr & length).  The #v6 patch does a TLB flush for each page in
	  the range.  Flushing on the GRU is slow so being able to flush
	  multiple pages with a single request is a benefit.

Seems like the latter difference could be significant for other users
of mmu notifiers.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
