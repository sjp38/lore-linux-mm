Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 17 May 2013 10:37:18 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
Message-ID: <20130517143718.GK1008@kvack.org>
References: <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de> <5191B5B3.7080406@cn.fujitsu.com> <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5195A3F4.70803@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On Fri, May 17, 2013 at 11:28:52AM +0800, Tang Chen wrote:
> Hi Benjamin,
> 
> Thank you very much for your idea. :)
> 
> I have no objection to your idea, but seeing from your patch, this only
> works for aio subsystem because you changed the way to allocate the aio
> ring pages, with a file mapping.

That is correct.  There is no way you're going to be able to solve this 
problem without dealing with the issue on a subsystem by subsystem basis.

> So far as I know, not only aio, but also other subsystems, such CMA, will
> also have problem like this. The page cannot be migrated because it is
> pinned in memory. So I think we should work out a common way to solve how
> to migrate pinned pages.

A generic approach would require hardware support, but I doubt that is 
going to happen.

> I'm working in the way Mel has said, migrate_unpin() and migrate_pin()
> callbacks. But as you saw, I met some problems, like I don't where to put
> these two callbacks. And discussed with you guys, I want to try this:
> 
> 1. Add a new member to struct page, used to remember the pin holders of
>    this page, including the pin and unpin callbacks and the necessary data.
>    This is more like a callback chain.
>    (I'm worry about this step, I'm not sure if it is good enough. After 
> all,
>     we need a good place to put the callbacks.)

Putting function pointers into struct page is not going to happen.  You'd 
be adding a significant amount of memory overhead for something that is 
never going to be used on the vast majority of systems (2 function pointers 
would be 16 bytes per page on a 64 bit system).  Keep in mind that distro 
kernels tend to enable almost all config options on their kernels, so the 
overhead of any approach has to make sense for the users of the kernel that 
will never make use of this kind of migration.

> And then, like Mel said,
> 
> 2. Implement the callbacks in the subsystems, and register them to the
>    new member in struct page.

No, the hook should be in the address_space_operations.  We already have 
a pointer to an address space in struct page.  This avoids adding more 
overhead to struct page.

> 3. Call these callbacks before and after migration.

How is that better than using the existing hook in address_space_operations?

> I think I'll send a RFC patch next week when I finished the outline. I'm
> just thinking of finding a common way to solve this problem that all the
> other subsystems will benefit.

Before pursuing this approach, make sure you've got buy-in for all of the 
overhead you're adding to the system.  I don't think that growing struct 
page is going to be an acceptable design choice given the amount of 
overhead it will incur.

> Thanks. :)

Cheers,

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
