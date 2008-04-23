Date: Thu, 24 Apr 2008 00:19:28 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423221928.GV24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423163713.GC24536@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 06:37:13PM +0200, Andrea Arcangeli wrote:
> I'm afraid if you don't want to worst-case unregister with ->release
> you need to have a better idea than my mm_lock and personally I can't
> see any other way than mm_lock to ensure not to miss range_begin...

But wait, mmu_notifier_register absolutely requires mm_lock to ensure
that when the kvm->arch.mmu_notifier_invalidate_range_count is zero
(large variable name, it'll get shorter but this is to explain),
really no cpu is in the middle of range_begin/end critical
section. That's why we've to take all the mm locks.

But we cannot care less if we unregister in the middle, unregister
only needs to be sure that no cpu could possibly still using the ram
of the notifier allocated by the driver before returning. So I'll
implement unregister in O(1) and without ram allocations using srcu
and that'll fix all issues with unregister. It'll return "void" to
make it crystal clear it can't fail. It turns out unregister will make
life easier to kvm as well, mostly to simplify the teardown of the
/dev/kvm closure. Given this can be a considered a bugfix to
mmu_notifier_unregister I'll apply it to 1/N and I'll release a new
mmu-notifier-core patch for you to review before I resend to Andrew
before Saturday. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
