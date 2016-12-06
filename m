Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 703356B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 05:38:51 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j92so239600531ioi.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 02:38:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e205si13672123ioa.58.2016.12.06.02.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Dec 2016 02:38:50 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20161201152517.27698-1-mhocko@kernel.org>
	<20161201152517.27698-3-mhocko@kernel.org>
	<201612052245.HDB21880.OHJMOOQFFSVLtF@I-love.SAKURA.ne.jp>
	<20161205141009.GJ30758@dhcp22.suse.cz>
In-Reply-To: <20161205141009.GJ30758@dhcp22.suse.cz>
Message-Id: <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
Date: Tue, 6 Dec 2016 19:38:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 05-12-16 22:45:19, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > __alloc_pages_may_oom makes sure to skip the OOM killer depending on
> > > the allocation request. This includes lowmem requests, costly high
> > > order requests and others. For a long time __GFP_NOFAIL acted as an
> > > override for all those rules. This is not documented and it can be quite
> > > surprising as well. E.g. GFP_NOFS requests are not invoking the OOM
> > > killer but GFP_NOFS|__GFP_NOFAIL does so if we try to convert some of
> > > the existing open coded loops around allocator to nofail request (and we
> > > have done that in the past) then such a change would have a non trivial
> > > side effect which is not obvious. Note that the primary motivation for
> > > skipping the OOM killer is to prevent from pre-mature invocation.
> > > 
> > > The exception has been added by 82553a937f12 ("oom: invoke oom killer
> > > for __GFP_NOFAIL"). The changelog points out that the oom killer has to
> > > be invoked otherwise the request would be looping for ever. But this
> > > argument is rather weak because the OOM killer doesn't really guarantee
> > > any forward progress for those exceptional cases - e.g. it will hardly
> > > help to form costly order - I believe we certainly do not want to kill
> > > all processes and eventually panic the system just because there is a
> > > nasty driver asking for order-9 page with GFP_NOFAIL not realizing all
> > > the consequences - it is much better this request would loop for ever
> > > than the massive system disruption, lowmem is also highly unlikely to be
> > > freed during OOM killer and GFP_NOFS request could trigger while there
> > > is still a lot of memory pinned by filesystems.
> > 
> > I disagree. I believe that panic caused by OOM killer is much much better
> > than a locked up system. I hate to add new locations that can lockup inside
> > page allocator. This is __GFP_NOFAIL and reclaim has failed.
> 
> As a matter of fact any __GFP_NOFAIL can lockup inside the allocator.

You are trying to increase possible locations of lockups by changing
default behavior of __GFP_NOFAIL.

> Full stop. There is no guaranteed way to make a forward progress with
> the current page allocator implementation.

Then, will you accept kmallocwd until page allocator implementation
can provide a guaranteed way to make a forward progress?

> 
> So we are somewhere in the middle between pre-mature and pointless
> system disruption (GFP_NOFS with a lots of metadata or lowmem request)
> where the OOM killer even might not help and potential lockup which is
> inevitable with the current design. Dunno about you but I would rather
> go with the first option. To be honest I really fail to understand your
> line of argumentation. We have this
> 	do {
> 		cond_resched();
> 	} while (!(page = alloc_page(GFP_NOFS)));
> vs.
> 	page = alloc_page(GFP_NOFS | __GFP_NOFAIL);
> 
> the first one doesn't invoke OOM killer while the later does. This
> discrepancy just cannot make any sense... The same is true for
> 
> 	alloc_page(GFP_DMA) vs alloc_page(GFP_DMA|__GFP_NOFAIL)
> 
> Now we can discuss whether it is a _good_ idea to not invoke OOM killer
> for those exceptions but whatever we do __GFP_NOFAIL is not a way to
> give such a subtle side effect. Or do you disagree even with that?

"[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath"
silently changes __GFP_NOFAIL vs. __GFP_NORETRY priority.

Currently, __GFP_NORETRY is stronger than __GFP_NOFAIL; __GFP_NOFAIL
allocation requests fail without invoking the OOM killer when both
__GFP_NORETRY and __GFP_NOFAIL are given.

With [PATCH 1/2], __GFP_NOFAIL becomes stronger than __GFP_NORETRY;
__GFP_NOFAIL allocation requests will loop forever without invoking
the OOM killer when both __GFP_NORETRY and __GFP_NOFAIL are given.

Those callers which prefer lockup over panic can specify both
__GFP_NORETRY and __GFP_NOFAIL. You are trying to change behavior of
__GFP_NOFAIL without asking whether existing __GFP_NOFAIL users
want to invoke the OOM killer.

And the story is not specific to existing __GFP_NOFAIL users;
it applies to existing GFP_NOFS users as well.

Quoting from http://lkml.kernel.org/r/20161125131806.GB24353@dhcp22.suse.cz :
> > Will you look at http://marc.info/?t=120716967100004&r=1&w=2 which lead to
> > commit a02fe13297af26c1 ("selinux: prevent rentry into the FS") and commit
> > 869ab5147e1eead8 ("SELinux: more GFP_NOFS fixups to prevent selinux from
> > re-entering the fs code") ? My understanding is that mkdir() system call
> > caused memory allocation for inode creation and that memory allocation
> > caused memory reclaim which had to be !__GFP_FS.
> 
> I will have a look later, thanks for the points.

What is your answer to this problem? For those who prefer panic over lockup,
please provide a mean to invoke the OOM killer (e.g. __GFP_WANT_OOM_KILLER).

If you provide __GFP_WANT_OOM_KILLER, you can change

-#define GFP_KERNEL      (__GFP_RECLAIM | __GFP_IO | __GFP_FS)
+#define GFP_KERNEL      (__GFP_RECLAIM | __GFP_IO | __GFP_FS | __GFP_WANT_OOM_KILLER)

in gfp.h and add __GFP_WANT_OOM_KILLER to any existing __GFP_NOFAIL/GFP_NOFS
users who prefer panic over lockup. Then, I think I'm fine with

-	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
-		return true;
+	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_WANT_OOM_KILLER))
+		return false;

in out_of_memory().

As you know, quite few people are responding to discussions regarding
almost OOM situation. Changing default behavior without asking existing
users is annoying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
