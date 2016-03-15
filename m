Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D60976B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 20:51:59 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 124so3492554pfg.0
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:51:59 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id sk6si6784881pab.138.2016.03.14.17.51.58
        for <linux-mm@kvack.org>;
        Mon, 14 Mar 2016 17:51:59 -0700 (PDT)
Date: Tue, 15 Mar 2016 09:52:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v3 2/5] mm/zsmalloc: remove shrinker compaction
 callbacks
Message-ID: <20160315005249.GB19514@bbox>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-3-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314063207.GD10675@bbox>
 <20160314074523.GB542@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314074523.GB542@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 14, 2016 at 04:45:23PM +0900, Sergey Senozhatsky wrote:
> On (03/14/16 15:32), Minchan Kim wrote:
> > On Thu, Mar 03, 2016 at 11:46:00PM +0900, Sergey Senozhatsky wrote:
> > > Do not register shrinker compaction callbacks anymore, since
> > > now we shedule class compaction work each time its fragmentation
> > > value goes above the watermark.
> > 
> > I suggested to remove shrinker compaction but while I review your
> > first patch in this thread, I thought we need upper-bound to
> > compact zspage so background work can bail out for latency easily.
> > IOW, the work could give up the job. In such case, we might need
> > fall-back scheme to continue the job. And I think that could be
> > a shrinker.
> > 
> > What do you think?
> 
> wouldn't this unnecessarily complicate the whole thing? we would
> have
>  a) a compaction that can be triggered by used space

Maybe, user space? :)

>  b) a compaction from zs_free() that can bail out
>  c) a compaction triggered by the shrinker.
> 
> all 3 three can run simultaneously.

Yeb.

> 
> 
> _if_ we can keep every class below its watermark, we can reduce the
> need of "c)".

But the problem is timing. We cannot guarantee when background
compaction triggers while shrinker is interop with VM so we should
do the job instantly for the system.


> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
