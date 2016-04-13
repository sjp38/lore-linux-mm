Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 43882828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:58:54 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id v188so162019245wme.1
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:58:54 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id y4si21660620wjy.204.2016.04.13.01.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 01:58:52 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id a140so11962929wma.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 01:58:52 -0700 (PDT)
Date: Wed, 13 Apr 2016 10:58:49 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 12/31] huge tmpfs: extend get_user_pages_fast to shmem pmd
Message-ID: <20160413085849.GA29175@gmail.com>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051429160.5965@eggly.anvils>
 <20160406070044.GD3078@gmail.com>
 <alpine.LSU.2.11.1604061917530.3092@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1604061917530.3092@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org


* Hugh Dickins <hughd@google.com> wrote:

> > >  arch/mips/mm/gup.c  |   15 ++++++++++++++-
> > >  arch/s390/mm/gup.c  |   19 ++++++++++++++++++-
> > >  arch/sparc/mm/gup.c |   19 ++++++++++++++++++-
> > >  arch/x86/mm/gup.c   |   15 ++++++++++++++-
> > >  mm/gup.c            |   19 ++++++++++++++++++-
> > >  5 files changed, 82 insertions(+), 5 deletions(-)
> ...

> > Looks like there are two main variants - so these kinds of repetitive patterns 
> > very much call for some sort of factoring out of common code, right?
> 
> Hmm.  I'm still struggling between the two extremes, of
> 
> (a) agreeing completely with you, and saying, yeah, I'll take on the job
>     of refactoring every architecture's get_user_pages_as_fast_as_you_can(),
>     without much likelihood of testing more than one,
> 
> and
> 
> (b) running a mile, and pointing out that we have a tradition of using
>     arch/x86/mm/gup.c as a template for the others, and here I've just
>     added a few more lines to that template (which never gets built more
>     than once into any kernel).
> 
> Both are appealing in their different ways, but I think you can tell
> which I'm leaning towards...
> 
> Honestly, I am still struggling between those two; but I think the patch
> as it stands is one thing, and cleanup for commonality should be another
> however weaselly that sounds ("I'll come back to it" - yeah, right).

Yeah, so my worry is this: your patch for example roughly doubles the algorithmic 
complexity of mm/gup.c and arch/*/mm/gup.c's ::gup_huge_pmd().

And you want this to add a new feature!

So it really looks like to me this is the last sane chance to unify cheaply, then 
add the feature you want. Everyone else in the future will be able to refer to 
your example to chicken out! ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
