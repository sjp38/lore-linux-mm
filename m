Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2CF2A6B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 09:16:16 -0400 (EDT)
Date: Tue, 7 Sep 2010 15:16:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memory hotplug: use unified logic for is_removable
 and offline_pages
Message-ID: <20100907131612.GA23617@tiehlicka.suse.cz>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
 <20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com>
 <20100906093042.GB23089@tiehlicka.suse.cz>
 <AANLkTikOi6BqXs2wiLetFP9OgYtXD+vbC+Ez8a7z0dcU@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikOi6BqXs2wiLetFP9OgYtXD+vbC+Ez8a7z0dcU@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon 06-09-10 22:30:43, Hiroyuki Kamezawa wrote:
> 2010/9/6 Michal Hocko <mhocko@suse.cz>:
> > On Mon 06-09-10 14:47:16, KAMEZAWA Hiroyuki wrote:
[...]
> >> Changelog: 2010/09/06
> >> ?- added comments.
> >> ?- removed zone->lock.
> >> ?- changed the name of the function to be is_pageblock_removable_async().
> >> ? ?because I removed the zone->lock.
> >
> > wouldn't be __is_pageblock_removable a better name? _async suffix is
> > usually used for asynchronous operations and this is just a function
> > withtout locks.
> >
> rename as _is_pagebloc_removable_nolock().

Sounds good as well.

[...]
> >> +bool is_pageblock_removable_async(struct page *page)
> >> +{
> >> + ? ? struct zone *zone = page_zone(page);
> >> + ? ? unsigned long flags;
> >> + ? ? int num;
> >> + ? ? /* Don't take zone->lock interntionally. */
> >
> > Could you add the reason?
> > Don't take zone-> lock intentionally because we are called from the
> > userspace (sysfs interface).
> >
> I don't like to assume caller context which will limit the callers.
> 
> /* holding zone->lock or not is caller's job. */

Sure, but I think that if you explicitely mention that the lock is not
held intentionaly then it would be good to provide some reasonining.

> 
> 
> > [...]
> >> ? ? ? /* All pageblocks in the memory block are likely to be hot-removable */
> >> Index: kametest/include/linux/memory_hotplug.h
> >> ===================================================================
> >> --- kametest.orig/include/linux/memory_hotplug.h
> >> +++ kametest/include/linux/memory_hotplug.h
> >> @@ -69,6 +69,7 @@ extern void online_page(struct page *pag
> >> ?/* VM interface that may be used by firmware interface */
> >> ?extern int online_pages(unsigned long, unsigned long);
> >> ?extern void __offline_isolated_pages(unsigned long, unsigned long);
> >
> > #ifdef CONFIG_HOTREMOVE
> >
> >> +extern bool is_pageblock_removable_async(struct page *page);
> >
> > #else
> > #define is_pageblock_removable_async(p) 0
> > #endif
> > ?
> 
> Is this function is called even if HOTREMOVE is off ?
> If so, the caller is buggy. I'll check tomorrow.

It is not, but then it should be defined under CONFIG_HOTREMOVE without
#else part, shoudln't it?

> 
> Thanks,
> -Kame

Thanks!
-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
