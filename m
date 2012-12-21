Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 8DAF66B0072
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 17:02:26 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hq12so2262602wib.0
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 14:02:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121221195817.GE13367@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
 <20121221134740.GC13367@suse.de> <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
 <20121221195817.GE13367@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Dec 2012 14:02:04 -0800
Message-ID: <CA+55aFwDXj3LqCRepsaeZMjOg0YsWV=7GFLHqHe2CxoF4JchCQ@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Dec 21, 2012 at 11:58 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Kosaki's patch does not fix the actual problem with NUMA hinting
> faults. Converting to a spinlock is nice but we'd still hold the PTL at
> the time sp_alloc is called and potentially allocating GFP_KERNEL with a
> spinlock held.

The problem I saw reported - and the problem that the "mutex+spinlock"
patch was fixing - wasn't actually sp_alloc(), but just sp_lookup()
through mpol_shared_policy_lookup().

And converting that to a spinlock would definitely fix it - taking
that spinlock quickly for the lookup while holding the pt lock is
fine.

Now, if we have to call sp_alloc() too at some point, that's
different, but that wouldn't be helped by the "mutex+spinlock" patch
(that started this thread) anyway.

> At the risk of making your head explode, here is another patch.

So I don't hate this patch, but I don't see the point of your games in
do_pmd_numa_page(). I'm not seeing the allocation in mpol_misplaced(),
and that wasn't what the original report was.

The backtrace you quote is literally *only* about the fact that you
cannot take a mutex inside a spinlock. No allocation, just a lookup.

So where's the sp_alloc()?

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
