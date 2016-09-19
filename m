Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5286B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:01:08 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id n4so113582025lfb.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:01:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si22142904wmc.14.2016.09.19.00.01.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 00:01:07 -0700 (PDT)
Date: Mon, 19 Sep 2016 09:01:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919070106.GC10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun 18-09-16 14:18:22, Linus Torvalds wrote:
> On Sun, Sep 18, 2016 at 2:00 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> >
> > Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
> > hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
> > OOM, though. Guess not...
> 
> SLUB it is - and I think that's pretty much all the world these days.
> SLAB is largely deprecated.

It seems that this is not a general consensus
http://lkml.kernel.org/r/20160823153807.GN23577@dhcp22.suse.cz

> We should probably start to remove SLAB entirely, and I definitely
> hope that no oom people run with it. SLUB is marked default in our
> config files, and I think most distros follow that (I know Fedora
> does, didn't check others).
> 
> > Well, order-3 is actually PAGE_ALLOC_COSTLY_ORDER, and costly orders
> > have to be strictly larger in all the tests. So order-3 is in fact still
> > considered "small", and thus it actually results in OOM instead of
> > allocation failure.
> 
> Yeah, but I do think that "oom when you have 156MB free and 7GB
> reclaimable, and haven't even tried swapping" counts as obviously
> wrong.

The thing is that swapping doesn't really help. You can easily migrate
anonymous memory to create larger blocks even without reclaiming them.
So I still believe compaction is giving up too easily.

> I'm not saying the code should fail and return NULL either, of course.
> 
> So  PAGE_ALLOC_COSTLY_ORDER should *not* mean "oom rather than return
> NULL". It really has to mean "try a _lot_ harder".

Agreed and Vlastimil's patches go that route. We just do not try
sufficiently hard with the compaction.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
