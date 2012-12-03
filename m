Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id A242B6B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 10:45:05 -0500 (EST)
Date: Mon, 3 Dec 2012 15:44:58 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 18/52] mm/numa: Migrate on reference policy
Message-ID: <20121203154458.GO8218@suse.de>
References: <1354473824-19229-1-git-send-email-mingo@kernel.org>
 <1354473824-19229-19-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1354473824-19229-19-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>

On Sun, Dec 02, 2012 at 07:43:10PM +0100, Ingo Molnar wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> This is the simplest possible policy that still does something
> of note. When a pte_numa is faulted, it is moved immediately.
> Any replacement policy must at least do better than this and in
> all likelihood this policy regresses normal workloads.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Rik van Riel <riel@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Paul Turner <pjt@google.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Alex Shi <lkml.alex@gmail.com>
> Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> Cc: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>

It is worth noting that at this point in your combined tree that this
policy and patch does not and cannot do anything. It has none of the
faulting machinery, pte scanning, two-stage filter etc that are necessary
for it to work. So for example, you can not take this point of your tree,
compare it with balancenuma and get a meaningful comparison.

So while superfically this patch looks like a useful bisection point, it
isn't. A plain rebase on top of balancenuma would have given us a comparison
between "do nothing", "do the bare minimum to be useful (balancenuma)" and
"do something complex (numacore)" even *if* you decided to revert parts
of balancenuma during your rebase. For example, you might have decided
to force the removal of migrate rate-limiting even though I stand by it
being a valid decision to mitigate worst-case behaviour. The key is that
it would have been possible to bisect parts of numacore to help identify
the source of any regressions.

This restructure is an all or nothing approach. It does not look like it's
possible to do a comparison between "do nothing", "do the bare minimum
(balancenuma)" and "do something complex (numacore)". It would also be
impossible to do any sort of rebase of autonuma policies on top as was
the case with balancenuma.

FWIW, I pulled tip again this morning and rebased tip/numa/base to
3.7-rc7 and queued the result. I had pulled tip/master but it didn't
boot.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
