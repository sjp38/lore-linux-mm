Date: Thu, 28 Feb 2008 17:17:33 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v7
Message-ID: <20080228231732.GA21604@sgi.com>
References: <20080219135851.GI7128@v2.random> <20080219231157.GC18912@wotan.suse.de> <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <Pine.LNX.4.64.0802281139250.30865@schroedinger.engr.sgi.com> <20080228215257.GJ8091@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080228215257.GJ8091@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

> > The release should be called much earlier to allow the driver to release 
> > all resources in one go. This way each vma must be processed individually. 
> > For our gobs of memory this method may create a scaling problem on exit().
> 
> Good point, it has to be called earlier for GRU, but it's not a
> performance issue. GRU doesn't pin the pages so it should make the
> global invalidate in ->release _before_ unmap_vmas. Linux can't fault
> in the ptes anymore because mm_users is zero so there's no need of a
> ->release_begin/end, the _begin is enough.
> 

I disagree. The location of the callout IS a performance issue. In simple
comparisons of the 2 patches (Christoph's vs. Andrea's), Andrea's has a 7X
increase in the number of TLB purges being issued to the GRU. TLB flushing
is slow and can impact the performance of of tasks using the GRU.

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
