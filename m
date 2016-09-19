Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDAA6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 02:48:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id n4so113382460lfb.3
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:48:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e69si16128303wmc.143.2016.09.18.23.48.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 23:48:50 -0700 (PDT)
Date: Mon, 19 Sep 2016 08:48:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919064848.GA10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun 18-09-16 13:03:01, Linus Torvalds wrote:
> [ More or less random collection of people from previous oom patches
> and/or discussions, if you feel you shouldn't have been cc'd, blame me
> for just picking things from earlier threads and/or commits ]
> 
> I'm afraid that the oom situation is still not fixed, and the "let's
> die quickly" patches are still a nasty regression.
> 
> I have a 16GB desktop that I just noticed killed one of the chrome
> tabs yesterday. Tha machine had *tons* of freeable memory, with
> something like 7GB of page cache at the time, if I read this right.
> 
> The trigger is a kcalloc() in the i915 driver:
> 
>     Xorg invoked oom-killer:
> gfp_mask=0x240c0d0(GFP_TEMPORARY|__GFP_COMP|__GFP_ZERO), order=3,
> oom_score_adj=0
> 
>       __kmalloc+0x1cd/0x1f0
>       alloc_gen8_temp_bitmaps+0x47/0x80 [i915]
> 
> which looks like it is one of these:
> 
>   slabinfo - version: 2.1
>   # name            <active_objs> <num_objs> <objsize> <objperslab>
> <pagesperslab>
>   kmalloc-8192         268    268   8192    4    8
>   kmalloc-4096         732    786   4096    8    8
>   kmalloc-2048        1402   1456   2048   16    8
>   kmalloc-1024        2505   2976   1024   32    8
> 
> so even just a 1kB allocation can cause an order-3 page allocation.

Yes it can trigger order-3 but that should be just
alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL

so not triggering OOM and failing early rather than retry really hard.
Considering the above gfp_mask this seems like the real order-3 size
request.

> And yeah, I had what, 137MB free memory, it's just that it's all
> fairly fragmented.

137MB in your case means that all usable zones are not meating the min
wmark so 6b4e3181d7bd ("mm, oom: prevent premature OOM killer invocation
for high order request") didn't stop the OOM.

[...]

> So quite honestly, I *really* don't think that a 1kB allocation should
> have reasonably failed and killed anything at all (ok, it could have
> been an 8kB one, who knows - but it really looks like it *could* have
> been just 1kB).

Unless I am missing something this should really be a 32k request. It is
true that retrying some or much more might help here indeed this is
really hard to tell. Vlastimil's patches you have mentioned might really
help here because they are getting rid of most of the heuristics that
would give up just too early. But I am also wondering whether a more
pragmatic approach in this case would be to simply use GFP_NORETRY and
fallback to vmalloc. Note that I am not familiar with the code and
vmalloc might be a no-go but it is at least worth exploring this option.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
