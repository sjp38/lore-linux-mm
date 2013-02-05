Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 5 Feb 2013 14:25:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] mm: hotplug: implement non-movable version of
 get_user_pages() to kill long-time pin pages
Message-ID: <20130205052517.GH2610@blaptop>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <20130205005859.GE2610@blaptop>
 <51108DC8.4090704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51108DC8.4090704@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Lin,

On Tue, Feb 05, 2013 at 12:42:48PM +0800, Lin Feng wrote:
> Hi Minchan,
> 
> On 02/05/2013 08:58 AM, Minchan Kim wrote:
> > Hello,
> > 
> > On Mon, Feb 04, 2013 at 06:04:06PM +0800, Lin Feng wrote:
> >> Currently get_user_pages() always tries to allocate pages from movable zone,
> >> as discussed in thread https://lkml.org/lkml/2012/11/29/69, in some case users
> >> of get_user_pages() is easy to pin user pages for a long time(for now we found
> >> that pages pinned as aio ring pages is such case), which is fatal for memory
> >> hotplug/remove framework.
> >>
> >> So the 1st patch introduces a new library function called
> >> get_user_pages_non_movable() to pin pages only from zone non-movable in memory.
> >> It's a wrapper of get_user_pages() but it makes sure that all pages come from
> >> non-movable zone via additional page migration.
> >>
> >> The 2nd patch gets around the aio ring pages can't be migrated bug caused by
> >> get_user_pages() via using the new function. It only works when configed with
> >> CONFIG_MEMORY_HOTREMOVE, otherwise it uses the old version of get_user_pages().
> > 
> > CMA has same issue but the problem is the driver developers or any subsystem
> > using GUP can't know their pages is in CMA area or not in advance.
> > So all of client of GUP should use GUP_NM to work them with CMA/MEMORY_HOTPLUG well?
> > Even some driver module in embedded side doesn't open their source code.
> Yes, it somehow depends on the users of GUP. In MEMORY_HOTPLUG case, as for most users
> of GUP, they will release the pinned pages immediately and to such users they should get
> a good performance, using the old style interface is a smart way. And we had better just
> deal with the cases we have to by using the new interface.

Hmm, I think you can't make sure most of user for MEMORY_HOTPLUG will release pinned pages
immediately. Because MEMORY_HOTPLUG could be used for embedded system for reducing power
by PASR and some drivers in embedded could use GUP anytime and anywhere. They can't know
in advance they will use pinned pages long time or release in short time because it depends
on some event like user's response which is very not predetermined.
So for solving it, we can add some WARN_ON in CMA/MEMORY_HOTPLUG part just in case of
failing migration by page count and then, investigate they are really using GUP and it's
REALLY a culprit. If so, yell to them "Please use GUP_NM instead"?

Yes. it could be done but it would be rather trobulesome job.

>   
> > 
> > I would like to make GUP smart so it allocates a page from non-movable/non-cma area
> > when memory-hotplug/cma is enabled(CONFIG_MIGRATE_ISOLATE). Yeb. it might hurt GUP
> > performance but it is just trade-off for using CMA/memory-hotplug, IMHO. :(
> As I debuged the get_user_pages(), I found that some pages is already there and may be
> allocated before we call get_user_pages(). __get_user_pages() have following logic to
> handle such case.
> 1786                         while (!(page = follow_page(vma, start, foll_flags))) {
> 1787                                 int ret;
> To such case an additional alloc-flag or such doesn't work, it's difficult to keep GUP
> as smart as we want :( , so I worked out the migration approach to get around and 
> avoid messing up the current code :)

I didn't look at your code in detail yet but What's wrong following this?

Change curret GUP with old_GUP.

#ifdef CONFIG_MIGRATE_ISOLATE

int get_user_pages_non_movable()
{
        ..
        old_get_user_pages()
        ..
}

int get_user_pages()
{
        return get_user_pages_non_movable();
}
#else
int get_user_pages()
{
        return old_get_user_pages()
}
#endif

> 
> thanks,
> linfeng 
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
