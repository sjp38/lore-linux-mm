Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 20C696B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 01:33:52 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id x65so63794885pfb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 22:33:52 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id m81si25216929pfi.201.2016.02.26.22.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 22:33:51 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id e127so64271172pfe.3
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 22:33:51 -0800 (PST)
Date: Sat, 27 Feb 2016 15:31:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160227063153.GB396@swordfish>
References: <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
 <20160222023432.GC27829@bbox>
 <20160222035954.GC11961@swordfish>
 <20160222044145.GE27829@bbox>
 <20160222104325.GA4859@swordfish>
 <20160223082532.GG27829@bbox>
 <20160223103527.GA5012@swordfish>
 <20160223160515.GA13851@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223160515.GA13851@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Minchan,

sorry for very long reply.

On (02/24/16 01:05), Minchan Kim wrote:
[..]
> > And the thing is -- quite huge internal class fragmentation. These are the 'normal'
> > classes, not affected by ORDER modification in any way:
> > 
> >  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage compact
> >    107  1744           1           23           196         76         84                3      51
> >    111  1808           0            0            63         63         28                4       0
> >    126  2048           0          160           568        408        284                1      80
> >    144  2336          52          620          8631       5747       4932                4    1648
> >    151  2448         123          406         10090       8736       6054                3     810
> >    168  2720           0          512         15738      14926      10492                2     540
> >    190  3072           0            2           136        130        102                3       3
> > 
> > 
> > so I've been thinking about using some sort of watermaks (well, zsmalloc is an allocator
> > after all, allocators love watermarks :-)). we can't defeat this fragmentation, we never
> > know in advance which of the pages will be modified or we the size class those pages will
> > land after compression. but we know stats for every class -- zs_can_compact(),
> > obj_allocated/obj_used, etc. so we can start class compaction if we detect that internal
> > fragmentation is too high (e.g. 30+% of class pages can be compacted).
> 
> AFAIRC, we discussed about that when I introduced compaction.
> Namely, per-class compaction.
> I love it and just wanted to do after soft landing of compaction.
> So, it's good time to introduce it. ;-)

ah, yeah, indeed. I vaguely recall this. my first 'auto-compaction' submission
has had this "compact every class in zs_free()", which was a subject to 10+%
performance penalty on some of the tests. but with watermarks this will be less
dramatic, I think.

> > 
> > on the other hand, we always can wait for the shrinker to come in and do the job for us,
> > but that can take some time.
> 
> Sure, with the feature, we can remove shrinker itself, I think.
> > 
> > what's your opinion on this?
> 
> I will be very happy.

good, I'll take a look later, to avoid any conflicts with your re-work.

[..]
> > does it look to you good enough to be committed on its own (off the series)?
> 
> I think it's good to have. Firstly, I thought we can get the information
> by existing stats with simple math on userspace but changed my mind
> because we could change the implementation sometime so such simple math
> might not be perfect in future and even, we can expose it easily so yes,
> let's do it.

thanks! submitted.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
