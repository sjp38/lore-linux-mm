Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 7FAD66B0070
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 17:55:25 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so1751499dal.15
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 14:55:24 -0800 (PST)
Date: Thu, 20 Dec 2012 14:55:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy
 tree
In-Reply-To: <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org> <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com> <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, 20 Dec 2012, Linus Torvalds wrote:

> Going through some old emails before -rc1 rlease..
> 
> What is the status of this patch? The patch that is reported to cause
> the problem hasn't been merged, but that mpol_misplaced() thing did
> happen in commit 771fb4d806a9. And it looks like it's called from
> numa_migrate_prep() under the pte map lock. Or am I missing something?

Andrew pinged both Ingo and I about it privately two weeks ago.  It 
probably doesn't trigger right now because there's no pte_mknuma() on 
shared pages (yet) but will eventually be needed for correctness.  So it's 
not required for -rc1 as it sits in the tree today but will be needed 
later (and hopefully not forgotten about until Sasha fuzzes again).

> See commit 9532fec118d ("mm: numa: Migrate pages handled during a
> pmd_numa hinting fault").
> 
> Am I missing something? Mel, please take another look.
> 
> I despise these kinds of dual-locking models, and am wondering if we
> can't have *just* the spinlock?
> 

Adding KOSAKI to the cc.

This is probably worth discussing now to see if we can't revert 
b22d127a39dd ("mempolicy: fix a race in shared_policy_replace()"), keep it 
only as a spinlock as you suggest, and do what KOSAKI suggested in 
http://marc.info/?l=linux-kernel&m=133940650731255 instead.  I don't think 
it's worth trying to optimize this path at the cost of having both a 
spinlock and mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
