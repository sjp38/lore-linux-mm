Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 61F086B0253
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 22:54:06 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id e128so46009648pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:54:06 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id s69si8420869pfi.105.2016.04.06.19.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 19:54:05 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id c20so46100861pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 19:54:05 -0700 (PDT)
Date: Wed, 6 Apr 2016 19:53:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 12/31] huge tmpfs: extend get_user_pages_fast to shmem
 pmd
In-Reply-To: <20160406070044.GD3078@gmail.com>
Message-ID: <alpine.LSU.2.11.1604061917530.3092@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils> <alpine.LSU.2.11.1604051429160.5965@eggly.anvils> <20160406070044.GD3078@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Apr 2016, Ingo Molnar wrote:
> * Hugh Dickins <hughd@google.com> wrote:
> 
> > ---
> > Cc'ed to arch maintainers as an FYI: this patch is not expected to
> > go into the tree in the next few weeks, and depends upon a PageTeam
> > definition not yet available outside this huge tmpfs patchset.
> > Please refer to linux-mm or linux-kernel for more context.

Actually, Andrew took it and the rest into mmotm yesterday, to give them
better exposure through linux-next, so they should appear there soon.

> > 
> >  arch/mips/mm/gup.c  |   15 ++++++++++++++-
> >  arch/s390/mm/gup.c  |   19 ++++++++++++++++++-
> >  arch/sparc/mm/gup.c |   19 ++++++++++++++++++-
> >  arch/x86/mm/gup.c   |   15 ++++++++++++++-
> >  mm/gup.c            |   19 ++++++++++++++++++-
> >  5 files changed, 82 insertions(+), 5 deletions(-)
...
> 
> Ouch!

Oh sorry, I didn't mean to hurt you ;)

> 
> Looks like there are two main variants - so these kinds of repetitive patterns 
> very much call for some sort of factoring out of common code, right?

Hmm.  I'm still struggling between the two extremes, of

(a) agreeing completely with you, and saying, yeah, I'll take on the job
    of refactoring every architecture's get_user_pages_as_fast_as_you_can(),
    without much likelihood of testing more than one,

and

(b) running a mile, and pointing out that we have a tradition of using
    arch/x86/mm/gup.c as a template for the others, and here I've just
    added a few more lines to that template (which never gets built more
    than once into any kernel).

Both are appealing in their different ways, but I think you can tell
which I'm leaning towards...

Honestly, I am still struggling between those two; but I think the patch
as it stands is one thing, and cleanup for commonality should be another
however weaselly that sounds ("I'll come back to it" - yeah, right).

Hugh

> 
> Then the fix could be applied to the common portion(s) only, which will cut down 
> this gigantic diffstat:
> 
>   >  5 files changed, 82 insertions(+), 5 deletions(-)
> 
> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
