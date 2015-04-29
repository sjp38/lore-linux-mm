Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5D36A6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 14:23:19 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so34948884pab.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 11:23:19 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id di10si40612963pdb.34.2015.04.29.11.23.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 11:23:18 -0700 (PDT)
Subject: Re: [PATCH 0/9] mm: improve OOM mechanism v2
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201504281934.IIH81695.LOHJQMOFStFFVO@I-love.SAKURA.ne.jp>
	<20150428135535.GE2659@dhcp22.suse.cz>
	<201504290050.FDE18274.SOJVtFLOMOQFFH@I-love.SAKURA.ne.jp>
	<20150429125506.GB7148@cmpxchg.org>
	<20150429144031.GB31341@dhcp22.suse.cz>
In-Reply-To: <20150429144031.GB31341@dhcp22.suse.cz>
Message-Id: <201504300227.JCJ81217.FHOLSQVOFFJtMO@I-love.SAKURA.ne.jp>
Date: Thu, 30 Apr 2015 02:27:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, david@fromorbit.com, rientjes@google.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 29-04-15 08:55:06, Johannes Weiner wrote:
> > What we can do to mitigate this is tie the timeout to the setting of
> > TIF_MEMDIE so that the wait is not 5s from the point of calling
> > out_of_memory() but from the point of where TIF_MEMDIE was set.
> > Subsequent allocations will then go straight to the reserves.
> 
> That would deplete the reserves very easily. Shouldn't we rather
> go other way around? Allow OOM killer context to dive into memory
> reserves some more (ALLOC_OOM on top of current ALLOC flags and
> __zone_watermark_ok would allow an additional 1/4 of the reserves) and
> start waiting for the victim after that reserve is depleted. We would
> still have some room for TIF_MEMDIE to allocate, the reserves consumption
> would be throttled somehow and the holders of resources would have some
> chance to release them and allow the victim to die.

Does OOM killer context mean memory allocations which can call out_of_memory()?
If yes, there is no guarantee that such memory reserve is used by threads which
the OOM victim is waiting for, for they might do only !__GFP_FS allocations.
Likewise, there is possibility that such memory reserve is used by threads
which the OOM victim is not waiting for, for malloc() + memset() causes
__GFP_FS allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
