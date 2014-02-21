Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCBD6B00D9
	for <linux-mm@kvack.org>; Fri, 21 Feb 2014 16:24:34 -0500 (EST)
Received: by mail-vc0-f175.google.com with SMTP id ij19so3787065vcb.20
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 13:24:34 -0800 (PST)
Received: from mail-ve0-x234.google.com (mail-ve0-x234.google.com [2607:f8b0:400c:c01::234])
        by mx.google.com with ESMTPS id kl10si3529759vdb.129.2014.02.21.13.24.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Feb 2014 13:24:33 -0800 (PST)
Received: by mail-ve0-f180.google.com with SMTP id cz12so2557377veb.11
        for <linux-mm@kvack.org>; Fri, 21 Feb 2014 13:24:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393016226.3039.44.camel@buesod1.americas.hpqcorp.net>
References: <1392960523.3039.16.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFw1_Ecbjjv9vijj3o46mkq3NrJn0X-FnbpCGBZG2=NuOA@mail.gmail.com>
	<1393016226.3039.44.camel@buesod1.americas.hpqcorp.net>
Date: Fri, 21 Feb 2014 13:24:33 -0800
Message-ID: <CA+55aFzw24Mwk_xw3QM_36-TbDOya=XZCqUeSSBVNS1QfjnWEw@mail.gmail.com>
Subject: Re: [PATCH] mm: per-thread vma caching
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, "Norton, Scott J" <scott.norton@hp.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Feb 21, 2014 at 12:57 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
>
> Btw, one concern I had is regarding seqnum overflows... if such
> scenarios should happen we'd end up potentially returning bogus vmas and
> getting bus errors and other sorts of issues. So we'd have to flush the
> caches, but, do we care? I guess on 32bit systems it could be a bit more
> possible to trigger given enough forking.

I guess we should do something like

    if (unlikely(!++seqnum))
        flush_vma_cache()

just to not have to worry about it.

And we can either use a "#ifndef CONFIG_64BIT" to disable it for the
64-bit case (because no, we really don't need to worry about overflow
in 64 bits ;), or just decide that a 32-bit sequence number actually
packs better in the structures, and make it be an "u32" even on 64-bit
architectures?

It looks like a 32-bit sequence number might pack nicely next to the

    unsigned brk_randomized:1;

but I didn't actually go and look at the context there to see what
else is there..

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
