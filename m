Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 6 Feb 2013 09:56:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130206095617.GN21389@suse.de>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
 <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130205120137.GG21389@suse.de>
 <20130206004234.GD11197@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130206004234.GD11197@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 06, 2013 at 09:42:34AM +0900, Minchan Kim wrote:
> On Tue, Feb 05, 2013 at 12:01:37PM +0000, Mel Gorman wrote:
> > On Tue, Feb 05, 2013 at 05:21:52PM +0800, Lin Feng wrote:
> > > get_user_pages() always tries to allocate pages from movable zone, which is not
> > >  reliable to memory hotremove framework in some case.
> > > 
> > > This patch introduces a new library function called get_user_pages_non_movable()
> > >  to pin pages only from zone non-movable in memory.
> > > It's a wrapper of get_user_pages() but it makes sure that all pages come from
> > > non-movable zone via additional page migration.
> > > 
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: Mel Gorman <mgorman@suse.de>
> > > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> > > Cc: Jeff Moyer <jmoyer@redhat.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Zach Brown <zab@redhat.com>
> > > Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> > > Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> > > Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> > 
> > I already had started the review of V1 before this was sent
> > unfortunately. However, I think the feedback I gave for V1 is still
> > valid so I'll wait for comments on that review before digging further.
> 
> Mel, Andrew
> 
> Sorry for making noise if you already confirmed the direction but I have a concern
> about that.

I haven't confirmed any sort of direction, nor do I determine the
direction for memory hot-remove which I'm only paying vague attention to.
I stated a while ago that I think the use of ZONE_MOVABLE is a bad idea
for "guaranteeing" memory hot-remove and is already going the "wrong"
direction. That's just my opinion.

This patch is about mitigating (but not solving) the problem of long-lived
pins. In the general case, about all I could think of for that is that the
kernel would have to warn the administrator what applications had pinned
the memory and wait for the user to shut them down. To guarantee anything,
it would be necessary for subsystems to implement a callback for migration
to unpin pages, barrier operations until migration completes and pin the
new pfns.

> Because IMHO, we can't expect most of user for MEMORY_HOTPLUG will release
> pinned pages immediately.

Indeed not, but it's not really what this patch is about. This patch is
about moving the pages before they get permanently pinned. It mitigates
the problem but does not solve it because there is no guarantee that the
driver pinning a page will flag it properly.

> In addtion, MEMORY_HOTPLUG could be used for embedded system
> for reducing power by PASR and some drivers in embedded could use GUP anytime and anywhere.
> They can't know in advance they will use pinned pages long time or release in short time
> because it depends on some event like user's response which is very not predetermined.

True. This patch does not solve that problem.

> So for solving it, we can add some WARN_ON in CMA/MEMORY_HOTPLUG part just in case of
> failing migration by page count and then, investigate they are really using GUP and
> it's REALLY a culprit. If so, yell to them "Please use GUP_NM instead"?

Within the context of this patch, that is their main option. Finding
who is holding the pin is a problem. For userspace-pinned buffers it's
straight-forward as rmap will identify what processes are holding the
pin (page->list vmas->mm, lookup all tasks until p->mm == mm) and report
that. For driver-related pins, it's not as straight-forward. I guess there
could be callback to give meaningful information on it but no guarantee
that drivers pinning pages will implement it. In that case all you could do
was dump page->mapping and punt it at a kernel developer to figure out the
responsible driver. This might be managable for memory hot-remove where
there is an administator but may not work at all for embedded users.

There is the possibility that callbacks could be introduced for
migrate_unpin() and migrate_pin() that takes a list of PFN pairs
(old,new). The unpin callback should release the old PFNs and barrier
against any operations until the migrate_pfn() callback is called with
the updated pfns to be repinned. Again it would fully depend on subsystems
implementing it properly.

The callback interface would be more robust but puts a lot more work on
the driver side where your milage will vary.

> Yes. it could be done but it would be rather trobulesome job. Even it couldn't be triggered
> during QE phase so that trouble doesn't end until all guys uses GUP_NM.
> Let's consider another case. Some driver pin the page in very short time
> so he decide to use GUP instead of GUP_NM but someday, someuser start to use the driver
> very often so although pinning time is very short, it could be forever pinning effect
> if the use calls it very often. In the end, we should change it with GUP_NM, again.
> IMHO, In future, we ends up changing most of GUP user with GUP_NM if CMA and MEMORY_HOTPLUG
> is available all over the world.
> 

Same thing, callbacks to unpin and barrier would handle such a case by
effectively freezing the driver or subsystem responsible for the page.

> So, what's wrong if we replace get_user_pages with get_user_pages_non_movable
> in MEMORY_HOTPLUG/CMA without exposing get_user_pages_non_movable?
> 
> I mean this
> 
> #ifdef CONFIG_MIGRATE_ISOLATE
> int get_user_pages()
> {
>         return __get_user_pages_non_movable();
> }
> #else
> int get_user_pages()
> {
>         return old_get_user_pages();
> }
> #endif
> 

That will migrate everything out of ZONE_MOVABLE every time it's pinned.
One consequence is that direct IO can never use ZONE_MOVABLE on these
systems. It'll create a variation of the lowmem exhaustion problem.

> IMHO, get_user_pages isn't performance sensitive function. If user was sensitive
> about it, he should have tried get_user_pages_fast.

That opens a different cans of works. get_user_pages is part of the
gup_fast slowpath.

> THP degradation by increasing MIGRATE_UNMOVABLE?

The patch should not be converting MIGRATE_MOVABLE requests to
MIGRATE_UNMOVABLE. I covered this in the review of v1.

> Lin said most of GUP pages release the page in short so is it really problem?
> Even in embedded, we don't use THP yet but CMA and GUP call would be not too often
> but failing of CMA would be critical.
> 

To guarantee CMA can migrate pages pinned by drivers I think you need
migrate-related callsbacks to unpin, barrier the driver until migration
completes and repin.

I do not know, or at least have no heard, of anyone working on such a
scheme.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
