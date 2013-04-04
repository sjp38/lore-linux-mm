Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 144A96B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 15:02:12 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wz12so1590028pbc.31
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 12:02:12 -0700 (PDT)
Date: Thu, 4 Apr 2013 12:01:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
In-Reply-To: <CA+55aFwCG2h1ijWTCJ38LVcUyczDAfk72c4MVSU+_-BiLoMOOw@mail.gmail.com>
Message-ID: <alpine.LNX.2.00.1304041149030.29847@eggly.anvils>
References: <alpine.LNX.2.00.1304041120510.26822@eggly.anvils> <CA+55aFwCG2h1ijWTCJ38LVcUyczDAfk72c4MVSU+_-BiLoMOOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Jakub Jelinek <jakub@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 4 Apr 2013, Linus Torvalds wrote:
> On Thu, Apr 4, 2013 at 11:35 AM, Hugh Dickins <hughd@google.com> wrote:
> >
> > find_vma() can be called by multiple threads with read lock
> > held on mm->mmap_sem and any of them can update mm->mmap_cache.
> > Prevent compiler from re-fetching mm->mmap_cache, because other
> > readers could update it in the meantime:
> 
> Ack. I do wonder if we should mark the unlocked update too some way
> (also in find_vma()), although it's probably not a problem in practice
> since there's no way the compiler can reasonably really do anything
> odd with it. We *could* make that an ACCESS_ONCE() write too just to
> highlight the fact that it's an unlocked write to this optimistic data
> structure.

Hah, you beat me to it.

I wanted to get Jan's patch in first, seeing as it actually fixes his
observed issue; and it is very nice to have such a good description of
one of those, when ACCESS_ONCE() is usually just an insurance policy.

But then I was researching the much rarer "ACCESS_ONCE(x) = y" usage
(popular in drivers/net/wireless/ath/ath9k and kernel/rcutree* and
sound/firewire, but few places else).

When Paul reminded us of it yesterday, I came to wonder if actually
every use of ACCESS_ONCE in the read form should strictly be matched
by ACCESS_ONCE whenever modifying the location.

My uneducated guess is that strictly it ought to, in the sense of
insurance policy; but that (apart from that strange split writing
issue which came up a couple of months ago) in practice our compilers
have not "advanced" to the point of making this an issue yet.

> 
> Anyway, applied.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
