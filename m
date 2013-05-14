Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5191B5B3.7080406@cn.fujitsu.com>
Date: Tue, 14 May 2013 11:55:31 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com> <1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com> <20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop> <20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com> <20130513091902.GP11497@suse.de>
In-Reply-To: <20130513091902.GP11497@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Hi Mel,

On 05/13/2013 05:19 PM, Mel Gorman wrote:
>> For memory hot-remove case, the aio pages are pined in memory and making
>> the pages cannot be offlined, furthermore, the pages cannot be removed.
>>
>> IIUC, you mean implement migrate_unpin() and migrate_pin() callbacks in aio
>> subsystem, and call them when hot-remove code tries to offline
>> pages, right ?
>>
>> If so, I'm wondering where should we put this callback pointers ?
>> In struct page ?
>>
>
> No, I would expect the callbacks to be part the address space operations
> which can be found via page->mapping.
>

Two more problems I don't quite understand.

1. For an anonymous page, it has no address_space, and no address space
    operation. But the aio ring problem just happened when dealing with
    anonymous pages. Please refer to:
    (https://lkml.org/lkml/2012/11/29/69)

    If we put the the callbacks in page->mapping->a_ops, the anonymous 
pages
    won't be able to use them.

    And we cannot give a default callback because the situation we are 
dealing
    with is a special situation.

    So where to put the callback for anonymous pages ?


2. How to find out the reason why page->count != 1 in 
migrate_page_move_mapping() ?

    In the problem we are dealing with, get_user_pages() is called to 
pin the pages
    in memory. And the pages are migratable. So we want to decrease the 
page->count.

    But get_user_pages() is not the only reason leading to page->count 
increased.
    How can I know when should decrease teh page->count or when should not ?

    The way I can figure out is to assign the callback pointer in 
get_user_pages()
    because it is get_user_pages() who pins the pages.


Thanks. :)








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
