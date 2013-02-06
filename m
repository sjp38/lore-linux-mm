Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 6 Feb 2013 09:42:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130206004234.GD11197@blaptop>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
 <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130205120137.GG21389@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130205120137.GG21389@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Feb 05, 2013 at 12:01:37PM +0000, Mel Gorman wrote:
> On Tue, Feb 05, 2013 at 05:21:52PM +0800, Lin Feng wrote:
> > get_user_pages() always tries to allocate pages from movable zone, which is not
> >  reliable to memory hotremove framework in some case.
> > 
> > This patch introduces a new library function called get_user_pages_non_movable()
> >  to pin pages only from zone non-movable in memory.
> > It's a wrapper of get_user_pages() but it makes sure that all pages come from
> > non-movable zone via additional page migration.
> > 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> > Cc: Jeff Moyer <jmoyer@redhat.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Zach Brown <zab@redhat.com>
> > Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> > Reviewed-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
> > Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> 
> I already had started the review of V1 before this was sent
> unfortunately. However, I think the feedback I gave for V1 is still
> valid so I'll wait for comments on that review before digging further.

Mel, Andrew

Sorry for making noise if you already confirmed the direction but I have a concern
about that. Because IMHO, we can't expect most of user for MEMORY_HOTPLUG will release
pinned pages immediately. In addtion, MEMORY_HOTPLUG could be used for embedded system
for reducing power by PASR and some drivers in embedded could use GUP anytime and anywhere.
They can't know in advance they will use pinned pages long time or release in short time
because it depends on some event like user's response which is very not predetermined.
So for solving it, we can add some WARN_ON in CMA/MEMORY_HOTPLUG part just in case of
failing migration by page count and then, investigate they are really using GUP and
it's REALLY a culprit. If so, yell to them "Please use GUP_NM instead"?
Yes. it could be done but it would be rather trobulesome job. Even it couldn't be triggered
during QE phase so that trouble doesn't end until all guys uses GUP_NM.
Let's consider another case. Some driver pin the page in very short time
so he decide to use GUP instead of GUP_NM but someday, someuser start to use the driver
very often so although pinning time is very short, it could be forever pinning effect
if the use calls it very often. In the end, we should change it with GUP_NM, again.
IMHO, In future, we ends up changing most of GUP user with GUP_NM if CMA and MEMORY_HOTPLUG
is available all over the world.

So, what's wrong if we replace get_user_pages with get_user_pages_non_movable
in MEMORY_HOTPLUG/CMA without exposing get_user_pages_non_movable?

I mean this

#ifdef CONFIG_MIGRATE_ISOLATE
int get_user_pages()
{
        return __get_user_pages_non_movable();
}
#else
int get_user_pages()
{
        return old_get_user_pages();
}
#endif

IMHO, get_user_pages isn't performance sensitive function. If user was sensitive
about it, he should have tried get_user_pages_fast.
THP degradation by increasing MIGRATE_UNMOVABLE?
Lin said most of GUP pages release the page in short so is it really problem?
Even in embedded, we don't use THP yet but CMA and GUP call would be not too often
but failing of CMA would be critical.

I'd like to hear opinions.

> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
