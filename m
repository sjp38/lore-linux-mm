Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA1A6B013A
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:07:03 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so8151905pbb.14
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:07:03 -0700 (PDT)
Received: from mail-pb0-x22e.google.com (mail-pb0-x22e.google.com [2607:f8b0:400e:c01::22e])
        by mx.google.com with ESMTPS id tm9si13195541pab.305.2014.03.18.19.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 19:07:02 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8106312pbb.5
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 19:07:02 -0700 (PDT)
Date: Tue, 18 Mar 2014 19:06:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: bad rss-counter message in 3.14rc5
In-Reply-To: <CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1403181848380.3318@eggly.anvils>
References: <20140311045109.GB12551@redhat.com> <20140310220158.7e8b7f2a.akpm@linux-foundation.org> <20140311053017.GB14329@redhat.com> <20140311132024.GC32390@moon> <531F0E39.9020100@oracle.com> <20140311134158.GD32390@moon> <20140311142817.GA26517@redhat.com>
 <20140311143750.GE32390@moon> <20140311171045.GA4693@redhat.com> <20140311173603.GG32390@moon> <20140311173917.GB4693@redhat.com> <alpine.LSU.2.11.1403181703470.7055@eggly.anvils> <CA+55aFx0ZyCVrkosgTongBrNX6mJM4B8+QZQE1p0okk8ubbv7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bob Liu <bob.liu@oracle.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Tue, 18 Mar 2014, Linus Torvalds wrote:
> On Tue, Mar 18, 2014 at 5:38 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > And yes, it is possible (though very unusual) to find an anon page or
> > swap entry in a VM_SHARED nonlinear mapping: coming from that horrid
> > get_user_pages(write, force) case which COWs even in a shared mapping.
> 
> Hmm. Maybe we could just disallow that forced case.
> 
> It *used* to be a trivial "we can just do a COW", but that was back
> when the VM was much simpler and we had no rmap's etc. So "that horrid
> case" used to be a simple hack that wasn't painful. But I suspect we
> could very easily just fail it instead of forcing a COW, if that would
> make it simpler for the VM code.

I'd love that, if we can get away with it now: depends very
much on whether we then turn out to break userspace or not.

If I remember correctly, it's been that way since early days,
in case ptrace were used to put a breakpoint into a MAP_SHARED
mapping of an executable: to prevent that modification from
reaching the file, if the file happened to be opened O_RDWR.
Usually it's not open for writing, and mapped MAP_PRIVATE anyway.

That is still something worth protecting against, I presume;
but I'd much rather do it by failing the awkward case,
than by perverting the VM to break its own rules.

If I'm not mistaken, Konstantin (who happens to be already on this
Cc list) had a patch (that I hated) to complicate things, to fix up
some of the inconsistencies arising from this very odd and overlooked
corner-case.  I think he'd prefer this simplification to his patch too.

I'll look into it further, but not in haste.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
