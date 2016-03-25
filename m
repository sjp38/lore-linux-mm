Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 54D6A6B0005
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 07:54:46 -0400 (EDT)
Received: by mail-oi0-f46.google.com with SMTP id r187so96079391oih.3
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 04:54:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fk3si5147217obb.101.2016.03.25.04.54.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Mar 2016 04:54:45 -0700 (PDT)
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for wb_start_writeback
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201603242303.CEJ65666.VOOFJLFQOMtFSH@I-love.SAKURA.ne.jp>
	<20160324141714.aa9ccff6d5df5d2974eb86f8@linux-foundation.org>
In-Reply-To: <20160324141714.aa9ccff6d5df5d2974eb86f8@linux-foundation.org>
Message-Id: <201603252054.ADH30264.OJQFFLMOHFSOVt@I-love.SAKURA.ne.jp>
Date: Fri, 25 Mar 2016 20:54:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, tj@kernel.org

Andrew Morton wrote:
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> >  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
> >  	 * wakeup the thread for old dirty data writeback
> >  	 */
> > -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> > +	work = kzalloc(sizeof(*work),
> > +		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
> >  	if (!work) {
> >  		trace_writeback_nowork(wb);
> >  		wb_wakeup(wb);
> 
> Oh geeze.  fs/fs-writeback.c has grown waaay too many GFP_ATOMICs :(
> 
> How does this actually all work?  afaict if we fail this
> wb_writeback_work allocation, wb_workfn->wb_do_writeback will later say
> "hey, there are no work items!" and will do nothing at all.  Or does
> wb_workfn() fall into write-1024-pages-anyway mode and if so, how did
> it know how to do that?
> 
> If we had (say) a mempool of wb_writeback_work's (at least for for
> wb_start_writeback), would that help anything?  Or would writeback
> simply fail shortly afterwards for other reasons?
> 

I tried http://lkml.kernel.org/r/20160318133417.GB30225@dhcp22.suse.cz which would
reduce number of wb_writeback_work allocations compared to this patch, and I got
http://lkml.kernel.org/r/201603172035.CJH95337.SOJOFFFHMLOQVt@I-love.SAKURA.ne.jp
where wb_workfn() got stuck after all when we started using memory reserves.

Having a mempool for wb_writeback_work is not sufficient. There are allocations
after wb_workfn() is called. All allocations (GFP_NOFS or GFP_NOIO) needed for
doing writeback operation are expected to be satisfied. If we let GFP_NOFS and
GFP_NOIO allocations to fail rather than selecting next OOM victim by calling
the OOM killer when the page allocator declared OOM, we will loose data which was
supposed to be flushed asynchronously. Who is happy with buffered writes which
discard data (and causes filesystem errors such as remounting read-only,
followed by killing almost all processes like SysRq-i due to userspace programs
being unable to write data to filesystem) simply because the system was OOM at
that moment? Basically, any allocation (GFP_NOFS or GFP_NOIO) needed for doing
writeback operation is __GFP_NOFAIL because failing to flush data should not occur
unless one of power failure, kernel panic, kernel oops or hardware troubles
occurs. I hate failing to flush data simply because the system was OOM at that
moment, without selecting next OOM victim which would kill fewer processes
compared to consequences caused by filesystem errors.

I expect this patch to merely serve for stop bleeding after we started using
memory reserves. Nothing more. We will need to solve OOM-livelock situation
when we started using memory reserves by killing more processes by calling
the OOM killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
