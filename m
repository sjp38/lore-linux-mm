Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 1D2946B0044
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 13:38:38 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id hm11so322703wib.8
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 10:38:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121201122649.GA20322@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com> <20121201122649.GA20322@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 1 Dec 2012 10:38:16 -0800
Message-ID: <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm/migration: Remove anon vma locking from
 try_to_unmap() use
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Sat, Dec 1, 2012 at 4:26 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
>
> So as a quick concept hack I wrote the patch attached below.
> (It's not signed off, see the patch description text for the
> reason.)

Well, it confirms that anon_vma locking is a big problem, but as
outlined in my other email it's completely incorrect from an actual
behavior standpoint.

Btw, I think the anon_vma lock could be made a spinlock instead of a
mutex or rwsem, but that would probably take more work. We *shouldn't*
be doing anything that needs IO inside the anon_vma lock, though, so
it *should* be doable. But there are probably quite a bit of
allocations inside the lock, and I know it covers huge areas, so a
spinlock might not only be hard to convert to, it quite likely has
latency issues too.

Oh, btw, MUTEX_SPIN_ON_OWNER may well improve performance too, but it
gets disabled by DEBUG_MUTEXES. So some of the performance impact of
the vma locking may be *very* kernel-config dependent.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
