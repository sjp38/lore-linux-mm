Date: Thu, 21 Feb 2008 05:54:30 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] mmu notifiers #v6
Message-ID: <20080221045430.GC15215@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080220103942.GU7128@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 11:39:42AM +0100, Andrea Arcangeli wrote:
> Given Nick's comments I ported my version of the mmu notifiers to
> latest mainline. There are no known bugs AFIK and it's obviously safe
> (nothing is allowed to schedule inside rcu_read_lock taken by
> mmu_notifier() with my patch).

Thanks! Yes the seqlock you are using now ends up looking similar
to what I did and I couldn't find a hole in that either. So I
think this is going to work.

I do prefer some parts of my patch, however for everyone's sanity,
I think you should be the maintainer of the mmu notifiers, and I
will send you incremental changes that can be discussed more easily
that way (nothing major, mainly style and minor things).


> XPMEM simply can't use RCU for the registration locking if it wants to
> schedule inside the mmu notifier calls. So I guess it's better to add
> the XPMEM invalidate_range_end/begin/external-rmap as a whole
> different subsystem that will have to use a mutex (not RCU) to
> serialize, and at the same time that CONFIG_XPMEM will also have to
> switch the i_mmap_lock to a mutex. I doubt xpmem fits inside a
> CONFIG_MMU_NOTIFIER anymore, or we'll all run a bit slower because of
> it. It's really a call of how much we want to optimize the MMU
> notifier, by keeping things like RCU for the registration.

I agree: your coherent, non-sleeping mmu notifiers are pretty simple
and unintrusive. The sleeping version is fundamentally going to either
need to change VM locks, or be non-coherent, so I don't think there is
a question of making one solution fit everybody. So the sleeping /
xrmap patch should be kept either completely independent, or as an
add-on to this one.

I will post some suggestions to you when I get a chance.

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
