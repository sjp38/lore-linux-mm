Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <50B88A8A.9020802@cn.fujitsu.com>
Date: Fri, 30 Nov 2012 18:29:30 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com> <20121129153930.477e9709.akpm@linux-foundation.org> <50B82B0D.8010206@cn.fujitsu.com> <20121129215749.acfd872a.akpm@linux-foundation.org> <50B859C6.3020707@cn.fujitsu.com> <20121129235502.05223586.akpm@linux-foundation.org>
In-Reply-To: <20121129235502.05223586.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lin Feng <linfeng@cn.fujitsu.com>



On 11/30/2012 03:55 PM, Andrew Morton wrote:
> On Fri, 30 Nov 2012 15:01:26 +0800 Lin Feng <linfeng@cn.fujitsu.com> wrote:
> 
>>
>>
>> On 11/30/2012 01:57 PM, Andrew Morton wrote:
>>> On Fri, 30 Nov 2012 11:42:05 +0800 Lin Feng <linfeng@cn.fujitsu.com> wrote:
>>>
>>>> hi Andrew,
>>>>
>>>> On 11/30/2012 07:39 AM, Andrew Morton wrote:
>>>>> Tricky.
>>>>>
>>>>> I expect the same problem would occur with pages which are under
>>>>> O_DIRECT I/O.  Obviously O_DIRECT pages won't be pinned for such long
>>>>> periods, but the durations could still be lengthy (seconds).
>>>> the offline retry timeout duration is 2 minutes, so to O_DIRECT pages 
>>>> seem maybe not a problem for the moment.
>>>>>
>>>>> Worse is a futex page, which could easily remain pinned indefinitely.
>>>>>
>>>>> The best I can think of is to make changes in or around
>>>>> get_user_pages(), to steal the pages from userspace and replace them
>>>>> with non-movable ones before pinning them.  The performance cost of
>>>>> something like this would surely be unacceptable for direct-io, but
>>>>> maybe OK for the aio ring and futexes.
>>>> thanks for your advice.
>>>> I want to limit the impact as little as possible, as mentioned above,
>>>> direct-io seems not a problem, we needn't touch them. Maybe we can 
>>>> just change the use of get_user_pages()(in or around) such as aio 
>>>> ring pages. I will try to find a way to do this.
>>>
>>> What about futexes?
>> hi Andrew,
>>
>> Yes, better to find an approach to solve them all.
>>  
>> But I'm worried about that if we just confine get_user_pages() to use 
>> none-movable pages, it will drain the none-movable pages soon. Because
>> there are many places using get_user_pages() such as some drivers. 
> 
> Obviously we shouldn't change get_user_pages() for all callers.
> 
>> IMHO in most cases get_user_pages() callers should release the pages soon, 
>> so pages allocated from movable zone should be OK. But I'm not sure if
>> we get such rule upon get_user_pages(). 
>> And in other cases we specify get_user_pages() to allocate pages from
>> none-movable zone. 
>>
>> So could we add a zone-alloc flags when we call get_user_pages()?
> 
> Well, that's a fairly low-level implementation detail.  A more typical
> approach would be to add a new get_user_pages_non_movable() or such. 
> That would probably have the same signature as get_user_pages(), with
> one additional argument.  Then get_user_pages() becomes a one-line
> wrapper which passes in a particular value of that argument.
> 
> But that means we'd also have to add get_user_pages_fast_non_movable()
> and things might become a bit stupid.  A better approach might be to
hi Andrew,

Thanks for your patient reply.

What I can think out is like following:
inline int generic_get_user_pages(..., int movable_flag)
{
	if (0 == movable_flag)
		return get_user_pages();
	else if (1 == movable_flag)
		return get_user_pages_non_movable();
}
Yes, that seems to add a lot of duplicated codes.

> add a new library function which callers can use before (or after?)
> calling get_user_pages[_fast]().
Sorry, I'm not quite understand what "library function" function means..
Does it means a function aids get_user_pages() or totally wraps/replaces 
get_user_pages(), or none of above?

Thanks,
linfeng
> 
> Unsure.  It's the sort of thing where one has to dive in and try a few
> things.
ah, maybe more complicated than as I can expect..
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
