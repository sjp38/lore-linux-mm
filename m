Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id C54556B0119
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 20:50:56 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id gq1so1431075obb.17
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 17:50:56 -0800 (PST)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id mx9si11862257obc.80.2014.02.24.17.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 17:50:55 -0800 (PST)
Message-ID: <1393293051.2577.13.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Mon, 24 Feb 2014 17:50:51 -0800
In-Reply-To: <CA+55aFz8jdbO5S9NjV69=vvFSMpHNU=a0wrPyXGSvBx-aaxhAA@mail.gmail.com>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
	 <1393016019.3039.40.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFyQJGG6SC99mWwm3L=xYTCmt3=Qm-R4pWjeCyY_xAt63Q@mail.gmail.com>
	 <1393290984.2577.5.camel@buesod1.americas.hpqcorp.net>
	 <CA+55aFz8jdbO5S9NjV69=vvFSMpHNU=a0wrPyXGSvBx-aaxhAA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 2014-02-24 at 17:42 -0800, Linus Torvalds wrote:
> On Mon, Feb 24, 2014 at 5:16 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> >
> > If we add the two missing bits to the shifting and use PAGE_SHIFT (x86
> > at least) we get just as good results as with 10. So we would probably
> > prefer hashing based on the page number and not some offset within the
> > page.
> 
> So just
> 
>     int idx = (addr >> PAGE_SHIFT) & 3;
> 
> works fine?

Yep.

> 
> That makes me think it all just wants to be maximally spread out to
> approximate some NRU when adding an entry.
> 
>  Also, as far as I can tell, "vmacache_update()" should then become
> just a simple unconditional
> 
>     int idx = (addr >> PAGE_SHIFT) & 3;
>     current->vmacache[idx] = newvma;
> 

Yes, my thoughts exactly!

> because your original code did
> 
> +       if (curr->vmacache[idx] != newvma)
> +               curr->vmacache[idx] = newvma;
> 
> and that doesn't seem to make sense, since if "newvma" was already in
> the cache, then we would have found it when looking up, and we
> wouldn't be here updating it after doing the rb-walk? 

I noticed this as well but kept my fingers shut and was planning on
fixing it in v2.

> And with the
> per-mm cache removed, all that should remain is that simple version,
> no? 

Yes. 

Although I am planning on keeping the current way of doing things for
nommu configs as there's no dup_mmap. I'm not sure if that's the best
idea though, it makes things less straightforward.

> You don't even need the "check the vmcache sequence number and
> clear if bogus", because the rule should be that you have always done
> a "vmcache_find()" first, which should have done that..

Makes sense, noted.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
