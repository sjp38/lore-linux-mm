Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id AD9C56B0253
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 00:09:22 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id n5so149336892pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 21:09:22 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id c90si17007903pfd.233.2016.03.17.21.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 21:09:22 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id n5so149336624pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 21:09:22 -0700 (PDT)
Date: Fri, 18 Mar 2016 13:10:42 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160318041042.GD572@swordfish>
References: <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
 <20160314074159.GA542@swordfish>
 <20160315004611.GA19514@bbox>
 <20160315013303.GC2126@swordfish>
 <20160315061723.GB25154@bbox>
 <20160317012929.GA489@swordfish>
 <20160318011741.GD2154@bbox>
 <20160318020029.GC572@swordfish>
 <20160318040349.GA13476@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160318040349.GA13476@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (03/18/16 13:03), Minchan Kim wrote:
[..]
> > I have some concerns here. WQ_MEM_RECLAIM implies that there is a kthread
> > attached to wq, a rescuer thread, which will be idle until wq declares mayday.
> > But the kthread will be allocated anyway. And we can queue only one global
> > compaction work at a time; so wq does not buy us a lot here and a simple
> > wake_up_process() looks much better. it make sense to use wq if we can have
> > N compaction jobs queued, like I did in my initial patch, but otherwise
> > it's sort of overkill, isn't it?
[..]
> If we can use normal wq rather than WQ_MEM_RECLAIM, wq doesn't need
> own kthread attached the work. Right? If so, we can blow away that
> resource reservation problem.

right. if shrinker callbacks will be around (and it seems
they will), then we don't have to guarantee any forward
progress in background compaction. so yes, we can use normal
wq and there is no need in WQ_MEM_RECLAIM.

[..]
> > so you want to have
> > 
> > 	zs_free()
> > 		check pool watermark
> > 			queue class compaction
> 
> No queue class compaction.
> 
> > 			queue pool compaction
> 
> Yes. queue pool compaction.
> 
> > 
> > ?
> > 
> > I think a simpler one will be to just queue global compaction, if pool
> > is fragmented -- compact everything, like we do in shrinker callback.
> 
> That's what I said. :)

ah, ok.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
