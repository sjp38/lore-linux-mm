Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <519AD6F8.2070504@cn.fujitsu.com>
Date: Tue, 21 May 2013 10:07:52 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de> <5191B5B3.7080406@cn.fujitsu.com> <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com> <20130517143718.GK1008@kvack.org>
In-Reply-To: <20130517143718.GK1008@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Benjamin,

Sorry for the late. Please see below.

On 05/17/2013 10:37 PM, Benjamin LaHaise wrote:
> On Fri, May 17, 2013 at 11:28:52AM +0800, Tang Chen wrote:
>> Hi Benjamin,
>>
>> Thank you very much for your idea. :)
>>
>> I have no objection to your idea, but seeing from your patch, this only
>> works for aio subsystem because you changed the way to allocate the aio
>> ring pages, with a file mapping.
>
> That is correct.  There is no way you're going to be able to solve this
> problem without dealing with the issue on a subsystem by subsystem basis.
>

Yes, I understand that. We need subsystem work anyway.


>> I'm working in the way Mel has said, migrate_unpin() and migrate_pin()
>> callbacks. But as you saw, I met some problems, like I don't where to put
>> these two callbacks. And discussed with you guys, I want to try this:
>>
>> 1. Add a new member to struct page, used to remember the pin holders of
>>     this page, including the pin and unpin callbacks and the necessary data.
>>     This is more like a callback chain.
>>     (I'm worry about this step, I'm not sure if it is good enough. After
>> all,
>>      we need a good place to put the callbacks.)
>
> Putting function pointers into struct page is not going to happen.  You'd
> be adding a significant amount of memory overhead for something that is
> never going to be used on the vast majority of systems (2 function pointers
> would be 16 bytes per page on a 64 bit system).  Keep in mind that distro
> kernels tend to enable almost all config options on their kernels, so the
> overhead of any approach has to make sense for the users of the kernel that
> will never make use of this kind of migration.

True. But I just cannot find a place to hold the callbacks.

>
>> 3. Call these callbacks before and after migration.
>
> How is that better than using the existing hook in address_space_operations?

I'm not saying using two callbacks before and after migration is better.
I don't want to use address_space_operations is because there is no such 
member
for anonymous pages.

In your idea, using a file mapping will create a 
address_space_operations. But
I really don't think we can modify the way of memory allocation for all the
subsystems who has this problem. Maybe not just aio and cma. That means if
you want to pin pages in memory, you have to use a file mapping. This makes
the memory allocation more complicated. And the idea should be known by all
the subsystem developers. Is that going to happen ?


I also thought about reuse one field of struct page. But as you said, there
may not be many users of this functionality. Reusing a field of struct page
will make things more complicated and lead to high coupling.


So, how about the other idea that Mel mentioned ?

We create a 1-1 mapping of pinned page ranges and the pinner (subsystem
callbacks and data), maybe a global list or a hash table. And then, we can
find the callbacks.


Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
