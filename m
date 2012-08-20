Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id A04406B0069
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 04:00:54 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so7521565pbb.14
        for <linux-mm@kvack.org>; Mon, 20 Aug 2012 01:00:53 -0700 (PDT)
Date: Mon, 20 Aug 2012 01:00:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Repeated fork() causes SLAB to grow without bound
In-Reply-To: <502F100A.1080401@redhat.com>
Message-ID: <alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
References: <20120816024610.GA5350@evergreen.ssec.wisc.edu> <502D42E5.7090403@redhat.com> <20120818000312.GA4262@evergreen.ssec.wisc.edu> <502F100A.1080401@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Daniel Forrest <dan.forrest@ssec.wisc.edu>, Andrea Arcangeli <aarcange@redhat.com>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 17 Aug 2012, Rik van Riel wrote:
> On 08/17/2012 08:03 PM, Daniel Forrest wrote:
> 
> > Based on your comments, I came up with the following patch.  It boots
> > and the anon_vma/anon_vma_chain SLAB usage is stable, but I don't know
> > if I've overlooked something.  I'm not a kernel hacker.
> 
> The patch looks reasonable to me.  There is one spot left
> for optimization, which I have pointed out below.
> 
> Of course, that leaves the big question: do we want the
> overhead of having the atomic addition and decrement for
> every anonymous memory page, or is it easier to fix this
> issue in userspace?

I've not given any thought to alternatives, and I've not done any
performance analysis; but my instinct says that we really do not
want another atomic increment and decrement (and another cache
line redirtied) for every single page mapped.

One of the things I've often admired about Andrea's anon_vma design
was the way it did not need a refcount; and although we later added
one for KSM and migration, that scarcely mattered, because it was
for exceptional circumstances, and not per page.

May I dare to think: what if we just backed out all the anon_vma_chain
complexity, and returned to the simple anon_vma list we had in 2.6.33?

Just how realistic was the workload which led you to anon_vma_chains?
And isn't it correct to say that the performance evaluation was made
while believing that each anon_vma->lock was useful, before the sad
realization that anon_vma->root->lock (or ->mutex) had to be used?

I've Cc'ed Michel, because I think he has plans (or at least hopes) for
the anon_vmas, in his relentless pursuit of world domination by rbtree.

Hugh

> 
> Given that malicious userspace could potentially run the
> system out of memory, without needing special privileges,
> and the OOM killer may not be able to reclaim it due to
> internal slab fragmentation, I guess this issue could be
> classified as a low impact denial of service vulnerability.
> 
> Furthermore, there is already a fair amount of bookkeeping
> being done in the rmap code, so this patch is not likely
> to add a whole lot - some testing might be useful, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
