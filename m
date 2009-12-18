Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6CB4E6B0071
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 11:23:38 -0500 (EST)
Date: Fri, 18 Dec 2009 17:23:32 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: FWD:  [PATCH v2] vmscan: limit concurrent reclaimers in
 shrink_zone
Message-ID: <20091218162332.GR29790@random.random>
References: <20091211164651.036f5340@annuminas.surriel.com>
 <1260810481.6666.13.camel@dhcp-100-19-198.bos.redhat.com>
 <20091217193818.9FA9.A69D9226@jp.fujitsu.com>
 <4B2A22C0.8080001@redhat.com>
 <4B2A8CA8.6090704@redhat.com>
 <Pine.LNX.4.64.0912172055570.15788@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0912172055570.15788@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 09:05:23PM +0000, Hugh Dickins wrote:
> Please first clarify whether what Larry is running is actually
> a workload that people need to behave well in real life.

Anything with 10000 connections using a connection-per-thread/process
model, should use threads if good performance are expected, processes
not. Most things that are using multi-process design will never use
one-connection-per-process design (yes there are exceptions and
no we can't expect to fix those as they're proprietary ;). So I'm not
particularly worried.

Also make sure this also happens on older kernels, newer kernels uses
rmap chains and mangle over ptes even when there's no VM pressure for
no good reason. Older kernels would only hit on the anon_vma chain on
any anon page, only after this anon page was converted to swapcache
and swap was hit, so it makes a whole lot of difference. Anon_vma
chains should only be touched after we are I/O bound if anybody is to
expect decent performance out of the kernel.

> I'm not asserting that this one is purely academic, but I do
> think we need more than an artificial case to worry much about it.

Tend to agree.

> An rwlock there has been proposed on several occasions, but
> we resist because that change benefits this case but performs
> worse on more common cases (I believe: no numbers to back that up).

I think rwlock for anon_vma is a must. Whatever higher overhead of the
fast path with no contention is practically zero, and in large smp it
allows rmap on long chains to run in parallel, so very much worth it
because downside is practically zero and upside may be measurable
instead in certain corner cases. I don't think it'll be enough, but I
definitely like it.

> Substitute a MAP_SHARED file underneath those 10000 vmas,
> and don't you have an equal problem with the prio_tree,
> which would be harder to solve than the anon_vma case?

That is a very good point.

Rik suggested to me to have a cowed newly allocated page to use its
own anon_vma. Conceptually Rik's idea is fine one, but the only
complication then is how to chain the same vma into multiple anon_vma
(in practice insert/removal will be slower and more metadata will be
needed for additional anon_vmas and vams queued in more than
anon_vma). But this only will help if the mapcount of the page is 1,
if the mapcount is 10000 no change to anon_vma or prio_tree will solve
this, and we've to start breaking the rmap loop after 64
test_and_clear_young instead to mitigate the inefficiency on pages
that are used and never will go into swap and so where wasting 10000
cachelines just because this used page eventually is in the tail
position of the lru uis entirely wasted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
