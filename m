Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 44D106B0044
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 13:51:06 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so649586wey.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 10:51:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121201184135.GA32449@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com> <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com> <20121201184135.GA32449@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 1 Dec 2012 10:50:44 -0800
Message-ID: <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/migration: Remove anon vma locking from
 try_to_unmap() use
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Sat, Dec 1, 2012 at 10:41 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> I'll try the rwsem and see how it goes?

Yeah. That should be an easy conversion (just convert everything to
use the write-lock first, and then you can make one or two migration
places use the read version).

Side note: The mutex code tends to potentially generate slightly
faster noncontended locks than rwsems, and it does have the
MUTEX_SPIN_ON_OWNER feature that makes the contention case often
*much* better, so there are real downsides to rw-semaphores.

But for this load, it does seem like the scalability advantages of an
rwsem *might* be worth it.

Side note: in contrast, the rwlock spinning reader-writer locks are
basically never a win - the downsides just about always negate any
theoretical scalability advantage. rwsem's can work well, we already
use it for mmap_sem, for example, to allow concurrent page faults, and
it was a *big* scalabiloity win there. Although then we did the "drop
mmap_sem over IO and retry", and that might have negated many of the
advantages of the mmap_sem.

> Hm, indeed. For performance runs I typically disable lock
> debugging - which might have made me not directly notice some of
> the performance problems.

Yeah, lock debugging really tends to make anything that is close to
contended be absolutely *horribly* contended. Doubly so for the
mutexes because it disables the spinning code, but it's true in
general too.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
