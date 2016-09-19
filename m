Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 487486B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:52:35 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so116062580lfs.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:52:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 123si17741024wmt.39.2016.09.19.00.52.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 00:52:33 -0700 (PDT)
Date: Mon, 19 Sep 2016 09:52:30 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919075230.GE10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
 <20160919070106.GC10785@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919070106.GC10785@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon 19-09-16 09:01:06, Michal Hocko wrote:
> On Sun 18-09-16 14:18:22, Linus Torvalds wrote:
[...]
> > I'm not saying the code should fail and return NULL either, of course.
> > 
> > So  PAGE_ALLOC_COSTLY_ORDER should *not* mean "oom rather than return
> > NULL". It really has to mean "try a _lot_ harder".
> 
> Agreed and Vlastimil's patches go that route. We just do not try
> sufficiently hard with the compaction.

And just to clarify why I think that Vlastimil's patches might help
here. Your allocation fails because you seem to be hitting min watermark
even for order-0 with my workaround which is sitting in 4.8. If this is
a longer term state then the compaction even doesn't try to do anything.
With the original should_compact_retry we would keep retrying based on
compaction_withdrawn() feedback. That would get us over order-0
watermarks kick the compaction in. Without Vlastimil's patches we could
still give up too early due some of the back off heuristic in the
compaction code. But most of those should be gone with his patches. So I
believe that they should really help here. Maybe there are still some
places to look at - I didn't get to fully review his patches (plan to do
it this week).

So in short the workaround we have in 4.8 currently tried to plug the
biggest hole while the situation is not ideal. That's why I originally
hoped for the compaction feedback already in 4.8.

I fully realize this is a lot of code for late 4.8 cycle, though. So if
this turns out to be really critical for 4.8 then what Vlastimil was
suggesting in
http://lkml.kernel.org/r/6aa81fe3-7f04-78d7-d477-609a7acd351a@suse.cz
might be another workaround on top. We can even consider completely
disable OOM killer for !costly orders.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
