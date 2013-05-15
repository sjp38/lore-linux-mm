Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 15 May 2013 14:24:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Message-ID: <20130515132453.GB11497@suse.de>
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
 <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130205120137.GG21389@suse.de>
 <20130206004234.GD11197@blaptop>
 <20130206095617.GN21389@suse.de>
 <5190AE4F.4000103@cn.fujitsu.com>
 <20130513091902.GP11497@suse.de>
 <5191B5B3.7080406@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5191B5B3.7080406@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Tue, May 14, 2013 at 11:55:31AM +0800, Tang Chen wrote:
> Hi Mel,
> 
> On 05/13/2013 05:19 PM, Mel Gorman wrote:
> >>For memory hot-remove case, the aio pages are pined in memory and making
> >>the pages cannot be offlined, furthermore, the pages cannot be removed.
> >>
> >>IIUC, you mean implement migrate_unpin() and migrate_pin() callbacks in aio
> >>subsystem, and call them when hot-remove code tries to offline
> >>pages, right ?
> >>
> >>If so, I'm wondering where should we put this callback pointers ?
> >>In struct page ?
> >>
> >
> >No, I would expect the callbacks to be part the address space operations
> >which can be found via page->mapping.
> >
> 
> Two more problems I don't quite understand.
> 

Bear in mind I've done no research on this particular problem. At best,
the migrate pin/unpin is the direction that I'd start with if I was tasked
with fixing this (which I'm not). Hence, I cannot answer your questions
at the level of detail you are looking for.

> 1. For an anonymous page, it has no address_space, and no address space
>    operation. But the aio ring problem just happened when dealing with
>    anonymous pages. Please refer to:
>    (https://lkml.org/lkml/2012/11/29/69)
> 

If it is to be an address space operations sturcture then you'll need a
pseudo mapping structure for anonymous pages that are pinned by aio --
similar in principal to how swapper_space is used for managing PageSwapCache 
or how anon_vma structures can be associated with a page.

However, I warn you that you may find that the address_space is the
wrong level to register such callbacks, it just seemed like the obvious
first choice. A potential alternative implementation is to create a 1:1
association between pages and a long-lived holder that is stored on a hash
table (similar style of arrangement as page_waitqueue).  A page is looked up
in the hash table and if an entry exists, it points to an callback structure
to the subsystem holding the pin. It's up to the subsystem to register the
callbacks when it is about to pin a page (get_user_pages_longlived(....,
&release_ops) and figure out how to release the pin safely.

> 2. How to find out the reason why page->count != 1 in
> migrate_page_move_mapping() ?
> 
>    In the problem we are dealing with, get_user_pages() is called to
> pin the pages
>    in memory. And the pages are migratable. So we want to decrease
> the page->count.
> 
>    But get_user_pages() is not the only reason leading to
> page->count increased.
>    How can I know when should decrease teh page->count or when should not ?
> 

You cannot just arbitrarily drop the page->count without causing problems. It
has to be released by the subsystem holding the pin because only it can
know when it's safe.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
