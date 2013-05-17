Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5195A3F4.70803@cn.fujitsu.com>
Date: Fri, 17 May 2013 11:28:52 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com> <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de> <5191B5B3.7080406@cn.fujitsu.com> <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org>
In-Reply-To: <20130517002349.GI1008@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Benjamin,

Thank you very much for your idea. :)

I have no objection to your idea, but seeing from your patch, this only
works for aio subsystem because you changed the way to allocate the aio
ring pages, with a file mapping.

So far as I know, not only aio, but also other subsystems, such CMA, will
also have problem like this. The page cannot be migrated because it is
pinned in memory. So I think we should work out a common way to solve how
to migrate pinned pages.

I'm working in the way Mel has said, migrate_unpin() and migrate_pin()
callbacks. But as you saw, I met some problems, like I don't where to put
these two callbacks. And discussed with you guys, I want to try this:

1. Add a new member to struct page, used to remember the pin holders of
    this page, including the pin and unpin callbacks and the necessary data.
    This is more like a callback chain.
    (I'm worry about this step, I'm not sure if it is good enough. After 
all,
     we need a good place to put the callbacks.)

And then, like Mel said,

2. Implement the callbacks in the subsystems, and register them to the
    new member in struct page.

3. Call these callbacks before and after migration.


I think I'll send a RFC patch next week when I finished the outline. I'm
just thinking of finding a common way to solve this problem that all the
other subsystems will benefit.

Thanks. :)


On 05/17/2013 08:23 AM, Benjamin LaHaise wrote:
> On Thu, May 16, 2013 at 01:54:18PM +0800, Tang Chen wrote:
> ...
>> OK, I'll try to figure out a proper place to put the callbacks.
>> But I think we need to add something new to struct page. I'm just
>> not sure if it is OK. Maybe we can discuss more about it when I send
>> a RFC patch.
> ...
>
> I ended up working on this a bit today, and managed to cobble together
> something that somewhat works -- please see the patch below.  It still is
> not completely tested, and it has a rather nasty bug owing to the fact
> that the file descriptors returned by anon_inode_getfile() all share the
> same inode (read: more than one instance of aio does not work), but it
> shows the basic idea.  Also, bad things probably happen if someone does
> an mremap() on the aio ring buffer.  I'll polish this off sometime next
> week after the long weekend if noone beats me to it.
>
> 		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
