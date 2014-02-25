Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
	by kanga.kvack.org (Postfix) with ESMTP id 18C936B00D3
	for <linux-mm@kvack.org>; Mon, 24 Feb 2014 20:42:50 -0500 (EST)
Received: by mail-ve0-f179.google.com with SMTP id oz11so1287558veb.10
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 17:42:49 -0800 (PST)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id sm10si6408874vec.119.2014.02.24.17.42.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Feb 2014 17:42:49 -0800 (PST)
Received: by mail-vc0-f178.google.com with SMTP id ik5so6625760vcb.37
        for <linux-mm@kvack.org>; Mon, 24 Feb 2014 17:42:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393290984.2577.5.camel@buesod1.americas.hpqcorp.net>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
	<1393016019.3039.40.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFyQJGG6SC99mWwm3L=xYTCmt3=Qm-R4pWjeCyY_xAt63Q@mail.gmail.com>
	<1393290984.2577.5.camel@buesod1.americas.hpqcorp.net>
Date: Mon, 24 Feb 2014 17:42:48 -0800
Message-ID: <CA+55aFz8jdbO5S9NjV69=vvFSMpHNU=a0wrPyXGSvBx-aaxhAA@mail.gmail.com>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Feb 24, 2014 at 5:16 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> If we add the two missing bits to the shifting and use PAGE_SHIFT (x86
> at least) we get just as good results as with 10. So we would probably
> prefer hashing based on the page number and not some offset within the
> page.

So just

    int idx = (addr >> PAGE_SHIFT) & 3;

works fine?

That makes me think it all just wants to be maximally spread out to
approximate some NRU when adding an entry.

 Also, as far as I can tell, "vmacache_update()" should then become
just a simple unconditional

    int idx = (addr >> PAGE_SHIFT) & 3;
    current->vmacache[idx] = newvma;

because your original code did

+       if (curr->vmacache[idx] != newvma)
+               curr->vmacache[idx] = newvma;

and that doesn't seem to make sense, since if "newvma" was already in
the cache, then we would have found it when looking up, and we
wouldn't be here updating it after doing the rb-walk? And with the
per-mm cache removed, all that should remain is that simple version,
no? You don't even need the "check the vmcache sequence number and
clear if bogus", because the rule should be that you have always done
a "vmcache_find()" first, which should have done that..

Anyway, can you send the final cleaned-up and simplfied (and
re-tested) version? There's enough changes discussed here that I don't
want to track the end result mentally..

         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
