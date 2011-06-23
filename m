Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 33C13900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 20:44:14 -0400 (EDT)
Date: Thu, 23 Jun 2011 02:44:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
Message-ID: <20110623004404.GE20843@redhat.com>
References: <201106212132.39311.nai.xia@gmail.com>
 <4E01C752.10405@redhat.com>
 <4E01CC77.10607@ravellosystems.com>
 <4E01CDAD.3070202@redhat.com>
 <4E01CFD2.6000404@ravellosystems.com>
 <4E020CBC.7070604@redhat.com>
 <20110622165529.GY20843@redhat.com>
 <BANLkTinRYr9Vg==C-qyCaRmO7C_aQqBPzw@mail.gmail.com>
 <20110622235906.GC20843@redhat.com>
 <BANLkTimc0wETJxS7wFqczroPdS5u7BBEfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimc0wETJxS7wFqczroPdS5u7BBEfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On Thu, Jun 23, 2011 at 08:31:56AM +0800, Nai Xia wrote:
> On Thu, Jun 23, 2011 at 7:59 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Thu, Jun 23, 2011 at 07:37:47AM +0800, Nai Xia wrote:
> >> On 2MB pages, I'd like to remind you and Rik that ksmd currently splits
> >> huge pages before their sub pages gets really merged to stable tree.
> >> So when there are many 2MB pages each having a 4kB subpage
> >> changed for all time, this is already a concern for ksmd to judge
> >> if it's worthwhile to split 2MB page and get its sub-pages merged.
> >
> > Hmm not sure to follow. KSM memory density with THP on and off should
> > be identical. The cksum is computed on subpages so the fact the 4k
> > subpage is actually mapped by a hugepmd is invisible to KSM up to the
> > point we get a unstable_tree_search_insert/stable_tree_search lookup
> > succeeding.
> 
> I agree on your points.
> 
> But, I mean splitting the huge page into normal pages when some subpages
> need to be merged may increase the TLB lookside timing of CPU and
> _might_ hurt the workload ksmd is scanning. If only a small portion of false
> negative 2MB pages are really get merged eventually, maybe it's not worthwhile,
> right?

Yes, there's not threshold to say "only split if we could merge more
than N subpages", 1 subpage match in two different hugepages is enough
to split both and save just 4k but then memory accesses will be slower
for both 2m ranges that have been splitted. But the point is that it
won't be slower than if THP was off in the first place. So in the end
all we gain is 4k saved but we still run faster than THP off, in the
other hugepages that haven't been splitted yet.

> But, well, just like Rik said below, yes, ksmd should be more aggressive to
> avoid much more time consuming cost for swapping.

Correct the above logic also follows the idea to always maximize
memory merging in KSM, which is why we've no threshold to wait N
subpages to be mergeable before we split the hugepage.

I'm unsure if admins in real life would then start to use those
thresholds even if we'd implement them. The current way of enabling
KSM a per-VM (not per-host) basis is pretty simple: the performance
critical VM has KSM off, non-performance critical VM has KSM on and it
prioritizes on memory merging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
