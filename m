Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 4BABF6B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 11:53:55 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id u54so2264297wey.41
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 08:53:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121221134740.GC13367@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org> <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com> <20121221134740.GC13367@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 21 Dec 2012 08:53:33 -0800
Message-ID: <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Dec 21, 2012 at 5:47 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Thu, Dec 20, 2012 at 02:55:22PM -0800, David Rientjes wrote:
>>
>> This is probably worth discussing now to see if we can't revert
>> b22d127a39dd ("mempolicy: fix a race in shared_policy_replace()"), keep it
>> only as a spinlock as you suggest, and do what KOSAKI suggested in
>> http://marc.info/?l=linux-kernel&m=133940650731255 instead.  I don't think
>> it's worth trying to optimize this path at the cost of having both a
>> spinlock and mutex.
>
> Jeez, I'm still not keen on that approach for the reasons that are explained
> in the changelog for b22d127a39dd.

Christ, Mel.

Your reasons in b22d127a39dd are weak as hell, and then you come up
with *THIS* shit instead:

> That leads to this third *ugly* option that conditionally drops the lock
> and it's up to the caller to figure out what happened. Fooling around with
> how it conditionally releases the lock results in different sorts of ugly.
> We now have three ugly sister patches for this. Who wants to be Cinderalla?
>
> ---8<---
> mm: numa: Release the PTL if calling vm_ops->get_policy during NUMA hinting faults

Heck no. In fact, not a f*cking way in hell. Look yourself in the
mirror, Mel. This patch is ugly, and *guaranteed* to result in subtle
locking issues, and then you have the *gall* to quote the "uhh, that's
a bit ugly due to some trivial duplication" thing in commit
b22d127a39dd.

Reverting commit b22d127a39dd and just having a "ok, if we need to
allocate, then drop the lock, allocate, re-get the lock, and see if we
still need the new allocation" is *beautiful* code compared to the
diseased abortion you just posted.

Seriously. Conditional locking is error-prone, and about a million
times worse than the trivial fix that Kosaki suggested.

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
