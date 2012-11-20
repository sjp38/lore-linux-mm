Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id EF4CA6B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 14:31:21 -0500 (EST)
Date: Tue, 20 Nov 2012 11:31:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFT PATCH v1 1/5] mm: introduce new field "managed_pages" to
 struct zone
Message-Id: <20121120113119.38d2a635.akpm@linux-foundation.org>
In-Reply-To: <50AB9A0B.9090105@gmail.com>
References: <20121115112454.e582a033.akpm@linux-foundation.org>
	<1353254850-27336-1-git-send-email-jiang.liu@huawei.com>
	<1353254850-27336-2-git-send-email-jiang.liu@huawei.com>
	<20121119153832.437c7e59.akpm@linux-foundation.org>
	<50AB9A0B.9090105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Nov 2012 22:56:11 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> On 11/20/2012 07:38 AM, Andrew Morton wrote:
> > On Mon, 19 Nov 2012 00:07:26 +0800
> > Jiang Liu <liuj97@gmail.com> wrote:
>
> ...
>
> > Also, the existing comment tells us that spanned_pages and
> > present_pages are protected by span_seqlock but has not been updated to
> > describe the locking (if any) for managed_pages.
> How about this?
>
> ...
>

Looks nice.
 
> >> +	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
> >> +		if (!is_highmem(z))
> > 
> > Needs a comment explaining why we skip the highmem zone, please.
> How about this?
>
> ...
>

Ditto.

> >> @@ -106,6 +106,7 @@ static void get_page_bootmem(unsigned long info,  struct page *page,
> >>  void __ref put_page_bootmem(struct page *page)
> >>  {
> >>  	unsigned long type;
> >> +	static DEFINE_MUTEX(ppb_lock);
> >>  
> >>  	type = (unsigned long) page->lru.next;
> >>  	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
> >> @@ -115,7 +116,9 @@ void __ref put_page_bootmem(struct page *page)
> >>  		ClearPagePrivate(page);
> >>  		set_page_private(page, 0);
> >>  		INIT_LIST_HEAD(&page->lru);
> >> +		mutex_lock(&ppb_lock);
> >>  		__free_pages_bootmem(page, 0);
> >> +		mutex_unlock(&ppb_lock);
> > 
> > The mutex is odd.  Nothing in the changelog, no code comment. 
> > __free_pages_bootmem() is called from a lot of places but only this one
> > has locking.  I'm madly guessing that the lock is here to handle two or
> > more concurrent memory hotpluggings, but I shouldn't need to guess!!
> Actually I'm a little hesitate whether we should add a lock here.
> 
> All callers of __free_pages_bootmem() other than put_page_bootmem() should
> only be used at startup time. And currently the only caller of put_page_bootmem()
> has already been protected by pgdat_resize_lock(pgdat, &flags). So there's
> no real need for lock, just defensive.
> 
> I'm not sure which is the best solution here.
> 1) add a comments into __free_pages_bootmem() to state that the caller should
>    serialize themselves.
> 2) Use a dedicated lock to serialize updates to zone->managed_pages, this need
>    modifications to page_alloc.c and memory_hotplug.c.
> 3) The above solution to serialize in put_page_bootmem().
> What's your suggestions here?

Firstly, let's be clear about what *data* we're protecting here.  I
think it's only ->managed_pages?

I agree that no locking is needed during the init-time code.

So afaict we only need be concerned about concurrent updates to
->managed_pages via memory hotplug, and lock_memory_hotplug() is
sufficient there.  We don't need to be concerned about readers of
managed_pages because it is an unsigned long (a u64 on 32-bit machines
would be a problem).

All correct?  If so, the code is OK as-is and this can all be
described/formalised in code comments.  If one wants to be really
confident, we could do something along the lines of

void mod_zone_managed_pages(struct zone *zone, signed long delta)
{
	WARN_ON(system_state != SYSTEM_BOOTING &&
		!is_locked_memory_hotplug());
	zone->managed_pages += delta;
}

And yes, is_locked_memory_hotplug() is a dopey name. 
[un]lock_memory_hotplug() should have been called
memory_hotplug_[un]lock()!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
