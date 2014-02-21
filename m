Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id A31666B00D8
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 16:18:39 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so3745373vcb.6
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 13:18:39 -0800 (PST)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id a5si3551867vez.6.2014.02.21.13.18.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 13:18:39 -0800 (PST)
Received: by mail-vc0-f174.google.com with SMTP id im17so3865913vcb.19
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 13:18:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393016019.3039.40.camel@buesod1.americas.hpqcorp.net>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
	<1393016019.3039.40.camel@buesod1.americas.hpqcorp.net>
Date: Fri, 21 Feb 2014 13:18:38 -0800
Message-ID: <CA+55aFyQJGG6SC99mWwm3L=xYTCmt3=Qm-R4pWjeCyY_xAt63Q@mail.gmail.com>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 21, 2014 at 12:53 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> I think you are right. I just reran some of the tests and things are
> pretty much the same, so we could get rid of it.

Ok, I'd prefer the simpler model of just a single per-thread hashed
lookup, and then we could perhaps try something more complex if there
are particular loads that really matter. I suspect there is more
upside to playing with the hashing of the per-thread cache (making it
three bits, whatever) than with some global thing.

>> Also, the hash you use for the vmacache index is *particularly* odd.
>>
>>         int idx =  (addr >> 10) & 3;
>>
>> you're using the top two bits of the address *within* the page.
>> There's a lot of places that round addresses down to pages, and in
>> general it just looks really odd to use an offset within a page as an
>> index, since in some patterns (linear accesses, whatever), the page
>> faults will always be to the beginning of the page, so index 0 ends up
>> being special.
>
> Ah, this comes from tediously looking at access patterns. I actually
> printed pages of them. I agree that it is weird, and I'm by no means
> against changing it. However, the results are just too good, specially
> for ebizzy, so I decided to keep it, at least for now. I am open to
> alternatives.

Hmm. Numbers talk, bullshit walks. So if you have the numbers that say
this is actually a good model..

I guess that for any particular page, only the first access address
matters. And if it really is a "somewhat linear", and the first access
tends to hit in the first part of the page, and the cache index tends
to cluster towards idx=0. And for linear accesses, I guess *any*
clustering is actually a good thing, since spreading things out just
defeats the fact that linear accesses also tend to hit in the same
vma.

And if you have truly fairly random accesses, then presumably their
offsets within the page are fairly random too, and so hashing by
offset within page might work well to spread out the vma cache
lookups.

So I guess I can rationalize it. I just found it surprising, and I
worry a bit about us sometimes just masking the address, but I guess
this is all statistical *anyway*, so if there is some rare path that
masks the address, I guess we don't care, and the only thing that
matters is the hitrate.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
