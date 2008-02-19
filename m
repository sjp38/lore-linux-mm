From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Date: Tue, 19 Feb 2008 19:54:14 +1100
References: <20080215064859.384203497@sgi.com> <20080215064932.620773824@sgi.com>
In-Reply-To: <20080215064932.620773824@sgi.com>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <200802191954.14874.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Friday 15 February 2008 17:49, Christoph Lameter wrote:
> The invalidation of address ranges in a mm_struct needs to be
> performed when pages are removed or permissions etc change.
>
> If invalidate_range_begin() is called with locks held then we
> pass a flag into invalidate_range() to indicate that no sleeping is
> possible. Locks are only held for truncate and huge pages.
>
> In two cases we use invalidate_range_begin/end to invalidate
> single pages because the pair allows holding off new references
> (idea by Robin Holt).
>
> do_wp_page(): We hold off new references while we update the pte.
>
> xip_unmap: We are not taking the PageLock so we cannot
> use the invalidate_page mmu_rmap_notifier. invalidate_range_begin/end
> stands in.

This whole thing would be much better if you didn't rely on the page
lock at all, but either a) used the same locking as Linux does for its
ptes/tlbs, or b) have some locking that is private to the mmu notifier
code. Then there is not all this new stuff that has to be understood in
the core VM.

Also, why do you have to "invalidate" ranges when switching to a
_more_ permissive state? This stuff should basically be the same as
(a subset of) the TLB flushing API AFAIKS. Anything more is a pretty
big burden to put in the core VM.

See my alternative patch I posted -- I can't see why it won't work
just like a TLB.

As far as sleeping inside callbacks goes... I think there are big
problems with the patch (the sleeping patch and the external rmap
patch). I don't think it is workable in its current state. Either
we have to make some big changes to the core VM, or we have to turn
some locks into sleeping locks to do it properly AFAIKS. Neither
one is good.

But anyway, I don't really think the two approaches (Andrea's
notifiers vs sleeping/xrmap) should be tangled up too much. I
think Andrea's can possibly be quite unintrusive and useful very
soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
