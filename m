Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 93D5E6B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 03:29:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w84so34362381wmg.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:29:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 11si28103223wmn.108.2016.09.21.00.29.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Sep 2016 00:29:43 -0700 (PDT)
Date: Wed, 21 Sep 2016 09:29:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160921072941.GB10300@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160921000458.15fdd159@metalhead.dragonrealms>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160921000458.15fdd159@metalhead.dragonrealms>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Wed 21-09-16 00:04:58, Raymond Jennings wrote:
> On Sun, 18 Sep 2016 13:03:01 -0700
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > [ More or less random collection of people from previous oom patches
> > and/or discussions, if you feel you shouldn't have been cc'd, blame me
> > for just picking things from earlier threads and/or commits ]
> > 
> > I'm afraid that the oom situation is still not fixed, and the "let's
> > die quickly" patches are still a nasty regression.
> > 
> > I have a 16GB desktop that I just noticed killed one of the chrome
> > tabs yesterday. Tha machine had *tons* of freeable memory, with
> > something like 7GB of page cache at the time, if I read this right.
> 
> Suggestions:
> 
> * Live compaction?
> 
> Have a background process that actively defragments free memory by
> bubbling movable pages to one end of the zone and the free holes to the
> other end?
> 
> Same spirit perhaps as khugepaged, periodically walk a zone from one
> end and migrate any used movable pages into the hole closest to the
> other end?

we have something like that already. It's called kcompactd

> I dunno, doing this manually with /proc/sys/vm/compact_blah seems a
> little hamfisted to me, and maybe a background process doing it
> incrementally would be better?
> 
> Also, question (for myself but also for the curious):
> 
> If you're allocating memory, can you synchronously reclaim, or does the
> memory have to be free already?

Yes we do direct reclaim if we are hitting watermarks. kswapd will start
earlier to prevent from direct reclaim because that will incur
latencies.

[...]
> > And yes, CONFIG_COMPACTION was enabled.
> 
> Does this compact manually or automatically?

Without this option there is no compaction at all and the reclaim is the
only source of high order pages.

> > So quite honestly, I *really* don't think that a 1kB allocation should
> > have reasonably failed and killed anything at all (ok, it could have
> > been an 8kB one, who knows - but it really looks like it *could* have
> > been just 1kB).
> > 
> > Considering that kmalloc() pattern, I suspect that we need to consider
> > order-3 allocations "small", and try a lot harder.
> > 
> > Because killing processes due to "out of memory" in this situation is
> > unquestionably a bug.
> 
> In this case I'd wonder why the freeable-but-still-used-in-pagecache
> memory isn't being reaped at alloc time.

I've tried to explain in other email. But let me try again. Compaction
code will back off and refrain from doing anything if we are close the
watermarks. This was your case as I've pointed in other email. The
workaround (retry as long as we are above order-0 watermark) which is
sitting in the Linus' tree will prevent only high order ooms only if
there is some memory left which should be normally the case because the
reclaim should free up something but if you hit parallel allocation
during reclaim somebody might have eaten up that memory. That's why I've
said it's far from idea but it should at least plug the biggest hole.

The patches from Vlastimil get us back to compaction feedback route
which was my original design. That means we keep reclaiming while the
compaction backs off and keep retrying as long as the compaction doesn't
fail. His changes get rid of some heuristics if we are getting close to
OOM situation so it should work much more reliably than my original
implementation. He doesn't have to change the detection code but rather
change compaction implementation details.

HTH
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
