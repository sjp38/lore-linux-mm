Date: Thu, 28 Feb 2008 14:00:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v7
In-Reply-To: <20080228215257.GJ8091@v2.random>
Message-ID: <Pine.LNX.4.64.0802281354200.436@schroedinger.engr.sgi.com>
References: <20080219084357.GA22249@wotan.suse.de> <20080219135851.GI7128@v2.random>
 <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random>
 <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de>
 <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com>
 <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802281139250.30865@schroedinger.engr.sgi.com>
 <20080228215257.GJ8091@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Feb 2008, Andrea Arcangeli wrote:

> > This is not going to work even if the mutex would work as easily as you 
> > think since the patch here still does an rcu_lock/unlock around a callback.
> 
> See underlined.

Mutex is not acceptable for performance reasons. I think we can just drop 
the RCU lock if we simply unregister the mmu notifier in release and 
forbid the drivers from removing themselves from the notification 
chain. They can simply do nothing until release. At that time there is no 
concurrency and thus its safe to remove even without rcu locking.

> Good point, it has to be called earlier for GRU, but it's not a
> performance issue. GRU doesn't pin the pages so it should make the
> global invalidate in ->release _before_ unmap_vmas. Linux can't fault
> in the ptes anymore because mm_users is zero so there's no need of a
> ->release_begin/end, the _begin is enough.

I do not follow you about the _begin without end but the following fix 
seems okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
