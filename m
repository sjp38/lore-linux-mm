Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 2FF196B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 21:40:14 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so5379701qcx.2
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 18:40:13 -0800 (PST)
Received: from mail-qg0-x231.google.com (mail-qg0-x231.google.com. [2607:f8b0:400d:c04::231])
        by mx.google.com with ESMTPS id gh3si25407633qcb.26.2014.12.23.18.40.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 18:40:13 -0800 (PST)
Received: by mail-qg0-f49.google.com with SMTP id a108so5302067qge.22
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 18:40:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141224010633.GL24183@dastard>
References: <20141218153341.GB832@dhcp22.suse.cz>
	<201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
	<20141220020331.GM1942@devil.localdomain>
	<201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
	<20141220223504.GI15665@dastard>
	<201412211745.ECD69212.LQOFHtFOJMSOFV@I-love.SAKURA.ne.jp>
	<20141221204249.GL15665@dastard>
	<20141222165736.GB2900@dhcp22.suse.cz>
	<20141222213058.GQ15665@dastard>
	<20141223094132.GA12208@phnom.home.cmpxchg.org>
	<20141224010633.GL24183@dastard>
Date: Tue, 23 Dec 2014 18:40:12 -0800
Message-ID: <CA+55aFxBMSKH46eRwALoU3KgzAjjcNjNmakhpFt9pD4217k5hQ@mail.gmail.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <dchinner@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 23, 2014 at 5:06 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Worse, it can be the task that is consuming all the memory, as canbe
> seen by this failure on xfs/084 on my single CPU. 1GB RAM VM. This
> test has been failing like this about 30% of the time since 3.18-rc1:

Quite frankly, uif you can realiably handle memory allocation failures
and they won't cause problems for other processes, you should use
GFP_USER, not GFP_KERNEL.

GFP_KERNEL does mean "try really hard".  That has *always* been true.
We used to have a __GFP_HIGH set in GFP_KERNEL exactly for that
reason.

We seem lost that distinction between GFP_USER and GFP_KERNEL long
ago, and then re-grew it in a weaker form as GFP_HARDWALL. That may be
part of the problem: the kernel cannot easily distinguish between "we
should try really hard to satisfy this allocation" and "we can easily
fail it".

Maybe we could just use that GFP_HARDWALL bit for it. Possibly rename
it, but for *testing* it somebody could try this trivial/minimal
test-patch.

    diff --git a/mm/page_alloc.c b/mm/page_alloc.c
    index 7633c503a116..7cacd45b47ce 100644
    --- a/mm/page_alloc.c
    +++ b/mm/page_alloc.c
    @@ -2307,6 +2307,10 @@ should_alloc_retry(gfp_t gfp_mask, unsigned
int order,
             if (!did_some_progress && pm_suspended_storage())
                     return 0;

    +        /* GFP_USER allocations don't re-try */
    +        if (gfp_mask & __GFP_HIGHWALL)
    +                return 0;
    +
             /*
              * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
              * means __GFP_NOFAIL, but that may not be true in other

which is intentionally whitespace-damaged, because it really is meant
as a "this is a starting point for experimentation by VM people"
rather than as a "apply this patch and you're good to go" patch..

Hmm?

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
