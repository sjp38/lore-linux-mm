Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 92C7E6B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 21:04:21 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n5so3787452pfn.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 18:04:21 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id st10si6850167pab.60.2016.03.14.18.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 18:04:20 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id u190so3737358pfb.3
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 18:04:20 -0700 (PDT)
Date: Tue, 15 Mar 2016 10:05:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 2/5] mm/zsmalloc: remove shrinker compaction
 callbacks
Message-ID: <20160315010542.GB2126@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314063207.GD10675@bbox>
 <20160314074523.GB542@swordfish>
 <20160315005249.GB19514@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160315005249.GB19514@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (03/15/16 09:52), Minchan Kim wrote:
[..]
> > > I suggested to remove shrinker compaction but while I review your
> > > first patch in this thread, I thought we need upper-bound to
> > > compact zspage so background work can bail out for latency easily.
> > > IOW, the work could give up the job. In such case, we might need
> > > fall-back scheme to continue the job. And I think that could be
> > > a shrinker.
> > > 
> > > What do you think?
> > 
> > wouldn't this unnecessarily complicate the whole thing? we would
> > have
> >  a) a compaction that can be triggered by used space
> 
> Maybe, user space? :)

haha, yes!  sorry, I do quite a lot of typos.

> >  b) a compaction from zs_free() that can bail out
> >  c) a compaction triggered by the shrinker.
> > 
> > all 3 three can run simultaneously.
> 
> Yeb.
> 
> > 
> > 
> > _if_ we can keep every class below its watermark, we can reduce the
> > need of "c)".
> 
> But the problem is timing. We cannot guarantee when background
> compaction triggers while shrinker is interop with VM so we should
> do the job instantly for the system.

we can have pool's compaction-kthread that we will wake_up()
every time we need a compaction, with no dependency on workqueue
or shrinker.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
