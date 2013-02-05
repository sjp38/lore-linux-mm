Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5110A442.5000707@cn.fujitsu.com>
Date: Tue, 05 Feb 2013 14:18:42 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm: hotplug: implement non-movable version of get_user_pages()
 to kill long-time pin pages
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <20130205005859.GE2610@blaptop> <51108DC8.4090704@cn.fujitsu.com> <20130205052517.GH2610@blaptop>
In-Reply-To: <20130205052517.GH2610@blaptop>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org



On 02/05/2013 01:25 PM, Minchan Kim wrote:
> Hi Lin,
> 
> On Tue, Feb 05, 2013 at 12:42:48PM +0800, Lin Feng wrote:
>> Hi Minchan,
>>
>> On 02/05/2013 08:58 AM, Minchan Kim wrote:
>>> Hello,
>>>
>>> On Mon, Feb 04, 2013 at 06:04:06PM +0800, Lin Feng wrote:
>>>> Currently get_user_pages() always tries to allocate pages from movable zone,
>>>> as discussed in thread https://lkml.org/lkml/2012/11/29/69, in some case users
>>>> of get_user_pages() is easy to pin user pages for a long time(for now we found
>>>> that pages pinned as aio ring pages is such case), which is fatal for memory
>>>> hotplug/remove framework.
>>>>
>>>> So the 1st patch introduces a new library function called
>>>> get_user_pages_non_movable() to pin pages only from zone non-movable in memory.
>>>> It's a wrapper of get_user_pages() but it makes sure that all pages come from
>>>> non-movable zone via additional page migration.
>>>>
>>>> The 2nd patch gets around the aio ring pages can't be migrated bug caused by
>>>> get_user_pages() via using the new function. It only works when configed with
>>>> CONFIG_MEMORY_HOTREMOVE, otherwise it uses the old version of get_user_pages().
>>>
>>> CMA has same issue but the problem is the driver developers or any subsystem
>>> using GUP can't know their pages is in CMA area or not in advance.
>>> So all of client of GUP should use GUP_NM to work them with CMA/MEMORY_HOTPLUG well?
>>> Even some driver module in embedded side doesn't open their source code.
>> Yes, it somehow depends on the users of GUP. In MEMORY_HOTPLUG case, as for most users
>> of GUP, they will release the pinned pages immediately and to such users they should get
>> a good performance, using the old style interface is a smart way. And we had better just
>> deal with the cases we have to by using the new interface.
> 
> Hmm, I think you can't make sure most of user for MEMORY_HOTPLUG will release pinned pages
> immediately. Because MEMORY_HOTPLUG could be used for embedded system for reducing power
> by PASR and some drivers in embedded could use GUP anytime and anywhere. They can't know
> in advance they will use pinned pages long time or release in short time because it depends
> on some event like user's response which is very not predetermined.
> So for solving it, we can add some WARN_ON in CMA/MEMORY_HOTPLUG part just in case of
> failing migration by page count and then, investigate they are really using GUP and it's
> REALLY a culprit. If so, yell to them "Please use GUP_NM instead"?
> 
> Yes. it could be done but it would be rather trobulesome job.
Yes WARN_ON may be easy while troubleshooting for finding the immigrate-able page is 
a big job.
If we want to kill all the potential immigrate-able pages caused by GUP we'd better use the
*non_movable* version of GUP.
But in some server environment we want to keep the performance but also want to use hotremove
feature in case. Maybe patch the place as we need is a trade off for such support.

Mel also said in the last discussion:

On 11/30/2012 07:00 PM, Mel Gorman wrote:> On Thu, Nov 29, 2012 at 11:55:02PM -0800, Andrew Morton wrote:
>> Well, that's a fairly low-level implementation detail.  A more typical
>> approach would be to add a new get_user_pages_non_movable() or such. 
>> That would probably have the same signature as get_user_pages(), with
>> one additional argument.  Then get_user_pages() becomes a one-line
>> wrapper which passes in a particular value of that argument.
>>
> 
> That is going in the direction that all pinned pages become MIGRATE_UNMOVABLE
> allocations.  That will impact THP availability by increasing the number
> of MIGRATE_UNMOVABLE blocks that exist and it would hit every user --
> not just those that care about ZONE_MOVABLE.
> 
> I'm likely to NAK such a patch if it's only about node hot-remove because
> it's much more of a corner case than wanting to use THP.
> 
> I would prefer if get_user_pages() checked if the page it was about to
> pin was in ZONE_MOVABLE and if so, migrate it at that point before it's
> pinned. It'll be expensive but will guarantee ZONE_MOVABLE availability
> if that's what they want. The CMA people might also want to take
> advantage of this if the page happened to be in the MIGRATE_CMA
> pageblock.
> 

So it may not a good idea that we all fall into calling the *non_movable* version of
GUP when CONFIG_MIGRATE_ISOLATE is on. What do you think?

> #ifdef CONFIG_MIGRATE_ISOLATE
> 
> int get_user_pages_non_movable()
> {
>         ..
>         old_get_user_pages()
>         ..
> }
> 
> int get_user_pages()
> {
>         return get_user_pages_non_movable();
> }
> #else
> int get_user_pages()
> {
>         return old_get_user_pages()
> }
> #endif


thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
