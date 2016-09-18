Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C133E6B025E
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 17:18:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id v62so222857914oig.3
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:18:23 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id g9si17249006oif.281.2016.09.18.14.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 14:18:23 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id a62so39030214oib.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:18:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 18 Sep 2016 14:18:22 -0700
Message-ID: <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
Subject: Re: More OOM problems
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun, Sep 18, 2016 at 2:00 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
> hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
> OOM, though. Guess not...

SLUB it is - and I think that's pretty much all the world these days.
SLAB is largely deprecated.

We should probably start to remove SLAB entirely, and I definitely
hope that no oom people run with it. SLUB is marked default in our
config files, and I think most distros follow that (I know Fedora
does, didn't check others).

> Well, order-3 is actually PAGE_ALLOC_COSTLY_ORDER, and costly orders
> have to be strictly larger in all the tests. So order-3 is in fact still
> considered "small", and thus it actually results in OOM instead of
> allocation failure.

Yeah, but I do think that "oom when you have 156MB free and 7GB
reclaimable, and haven't even tried swapping" counts as obviously
wrong.

I'm not saying the code should fail and return NULL either, of course.

So  PAGE_ALLOC_COSTLY_ORDER should *not* mean "oom rather than return
NULL". It really has to mean "try a _lot_ harder".

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
