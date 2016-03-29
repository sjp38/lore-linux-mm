Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 09E906B0262
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 12:49:50 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id p65so35530895wmp.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 09:49:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mc5si35285887wjb.99.2016.03.29.09.49.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 09:49:14 -0700 (PDT)
Date: Tue, 29 Mar 2016 18:49:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-ID: <20160329164942.GA10963@quack.suse.cz>
References: <201603242303.CEJ65666.VOOFJLFQOMtFSH@I-love.SAKURA.ne.jp>
 <20160324141714.aa9ccff6d5df5d2974eb86f8@linux-foundation.org>
 <20160329085434.GB3228@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160329085434.GB3228@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>

On Tue 29-03-16 10:54:35, Michal Hocko wrote:
> On Thu 24-03-16 14:17:14, Andrew Morton wrote:
> > On Thu, 24 Mar 2016 23:03:16 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> > 
> > > Andrew, can you take this patch?
> > 
> > Tejun.
> > 
> > > ----------------------------------------
> > > >From 5d43acbc5849a63494a732e39374692822145923 Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Sun, 13 Mar 2016 23:03:05 +0900
> > > Subject: [PATCH] mm,writeback: Don't use memory reserves for
> > >  wb_start_writeback
> > > 
> > > When writeback operation cannot make forward progress because memory
> > > allocation requests needed for doing I/O cannot be satisfied (e.g.
> > > under OOM-livelock situation), we can observe flood of order-0 page
> > > allocation failure messages caused by complete depletion of memory
> > > reserves.
> > > 
> > > This is caused by unconditionally allocating "struct wb_writeback_work"
> > > objects using GFP_ATOMIC from PF_MEMALLOC context.
> > > 
> > > __alloc_pages_nodemask() {
> > >   __alloc_pages_slowpath() {
> > >     __alloc_pages_direct_reclaim() {
> > >       __perform_reclaim() {
> > >         current->flags |= PF_MEMALLOC;
> > >         try_to_free_pages() {
> > >           do_try_to_free_pages() {
> > >             wakeup_flusher_threads() {
> > >               wb_start_writeback() {
> > >                 kzalloc(sizeof(*work), GFP_ATOMIC) {
> > >                   /* ALLOC_NO_WATERMARKS via PF_MEMALLOC */
> > >                 }
> > >               }
> > >             }
> > >           }
> > >         }
> > >         current->flags &= ~PF_MEMALLOC;
> > >       }
> > >     }
> > >   }
> > > }
> > > 
> > > Since I/O is stalling, allocating writeback requests forever shall deplete
> > > memory reserves. Fortunately, since wb_start_writeback() can fall back to
> > > wb_wakeup() when allocating "struct wb_writeback_work" failed, we don't
> > > need to allow wb_start_writeback() to use memory reserves.
> > > 
> > > ...
> > >
> > > --- a/fs/fs-writeback.c
> > > +++ b/fs/fs-writeback.c
> > > @@ -929,7 +929,8 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> > >  	 * This is WB_SYNC_NONE writeback, so if allocation fails just
> > >  	 * wakeup the thread for old dirty data writeback
> > >  	 */
> > > -	work = kzalloc(sizeof(*work), GFP_ATOMIC);
> > > +	work = kzalloc(sizeof(*work),
> > > +		       GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
> > >  	if (!work) {
> > >  		trace_writeback_nowork(wb);
> > >  		wb_wakeup(wb);
> > 
> > Oh geeze.  fs/fs-writeback.c has grown waaay too many GFP_ATOMICs :(
> > 
> > How does this actually all work?
> 
> Jack has explained it a bit
> http://lkml.kernel.org/r/20160318131136.GE7152@quack.suse.cz
> 
> > afaict if we fail this
> > wb_writeback_work allocation, wb_workfn->wb_do_writeback will later say
> > "hey, there are no work items!" and will do nothing at all.  Or does
> > wb_workfn() fall into write-1024-pages-anyway mode and if so, how did
> > it know how to do that?

We will end up in wb_do_writeback() which finds there's no work item so it
falls back to doing default background writeback (i.e., write out until
number of dirty pages is below background_dirty_limit).

> > If we had (say) a mempool of wb_writeback_work's (at least for for
> > wb_start_writeback), would that help anything?  Or would writeback
> > simply fail shortly afterwards for other reasons?

Not sure mempools would significantly improve the situation. Writeback code
is able to deal with the failed allocation so I think the issue remains
more with writeback code mostly pointlessly exhausting memory reserves with
atomic allocations.

I think it is somewhat dumb from do_try_to_free_pages() that it calls
wakeup_flusher_threads() so often (I guess it can quickly end up asking to
write more than it is ever sensible to ask). Admittedly it is also dumb from
the writeback code that it is not able to merge requests for writeback - we
could easily merge items created by wb_start_writeback() with matching
'reason' and 'range_cyclic'.

I'm not sure how easy it is to fix the first thing, I think improving the
second one may be worth it and I can have a look at that.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
