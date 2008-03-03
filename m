Date: Mon, 3 Mar 2008 14:24:59 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] mmu notifiers #v8
Message-ID: <20080303132459.GT8091@v2.random>
References: <20080220010941.GR7128@v2.random> <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303032934.GA3301@wotan.suse.de> <20080303125152.GS8091@v2.random> <20080303131017.GC13138@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080303131017.GC13138@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jack Steiner <steiner@sgi.com>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 02:10:17PM +0100, Nick Piggin wrote:
> Is this just a GRU problem? Can't we just require them to take a ref
> on the page (IIRC Jack said GRU could be changed to more like a TLB
> model).

Yes, it's just a GRU problem, it tries to optimize performance by
calling follow_page only in the fast path, and fallbacks to
get_user_pages; put_page in the slow path. xpmem could also send the
message in _begin and wait the message in _end, to reduce the wait
time. But if you forge GRU to call get_user_pages only (like KVM
does), the _begin can be removed. In theory we could also optimize KVM
to use follow_page only if the pte is already established. I'm not
sure how much that is a worthwhile optimization though.

However note that Quadrics also had a callback before and one after,
so they may be using the callback before for similar
optimizations. But functionality-wise _end is the only required bit if
everyone takes refcounts like KVM and XPMEM do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
