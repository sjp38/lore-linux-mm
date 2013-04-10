Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B8AFD6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 21:03:09 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id o13so7777qaj.20
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 18:03:08 -0700 (PDT)
Message-ID: <5164BA45.6090304@gmail.com>
Date: Wed, 10 Apr 2013 09:03:01 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from
 zram in-memory)
References: <1365400862-9041-1-git-send-email-minchan@kernel.org> <f3c8ef05-a880-47db-86dd-156038fc7d0f@default> <20130409012719.GB3467@blaptop> <c3d40e0f-68b3-45a4-9251-a97c59a50b2e@default>
In-Reply-To: <c3d40e0f-68b3-45a4-9251-a97c59a50b2e@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Bob Liu <bob.liu@oracle.com>, Shuah Khan <shuah@gonehiking.org>

Hi Dan,
On 04/10/2013 04:25 AM, Dan Magenheimer wrote:
>> From: Minchan Kim [mailto:minchan@kernel.org]
>> Subject: Re: zsmalloc defrag (Was: [PATCH] mm: remove compressed copy from zram in-memory)
>>
>> Hi Dan,
>>
>> On Mon, Apr 08, 2013 at 09:32:38AM -0700, Dan Magenheimer wrote:
>>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>>> Sent: Monday, April 08, 2013 12:01 AM
>>>> Subject: [PATCH] mm: remove compressed copy from zram in-memory
>>> (patch removed)
>>>
>>>> Fragment ratio is almost same but memory consumption and compile time
>>>> is better. I am working to add defragment function of zsmalloc.
>>> Hi Minchan --
>>>
>>> I would be very interested in your design thoughts on
>>> how you plan to add defragmentation for zsmalloc.  In
>> What I can say now about is only just a word "Compaction".
>> As you know, zsmalloc has a transparent handle so we can do whatever
>> under user. Of course, there is a tradeoff between performance
>> and memory efficiency. I'm biased to latter for embedded usecase.
> Have you designed or implemented this yet?  I have a couple
> of concerns:
>
> 1) The handle is transparent to the "user", but it is still a form
>     of a "pointer" to a zpage.  Are you planning on walking zram's
>     tables and changing those pointers?  That may be OK for zram
>     but for more complex data structures than tables (as in zswap
>     and zcache) it may not be as easy, due to races, or as efficient
>     because you will have to walk potentially very large trees.
> 2) Compaction in the kernel is heavily dependent on page migration
>     and page migration is dependent on using flags in the struct page.

Which flag?

>     There's a lot of code in those two code modules and there
>     are going to be a lot of implementation differences between
>     compacting pages vs compacting zpages.
>
> I'm also wondering if you will be implementing "variable length
> zspages".  Without that, I'm not sure compaction will help
> enough.  (And that is a good example of the difference between
> the kernel page compaction design/code and zspage compaction.)
>
>>> particular, I am wondering if your design will also
>>> handle the requirements for zcache (especially for
>>> cleancache pages) and perhaps also for ramster.
>> I don't know requirements for cleancache pages but compaction is
>> general as you know well so I expect you can get a benefit from it
>> if you are concern on memory efficiency but not sure it's valuable
>> to compact cleancache pages for getting more slot in RAM.
>> Sometime, just discarding would be much better, IMHO.
> Zcache has page reclaim.  Zswap has zpage reclaim.  I am
> concerned that these continue to work in the presence of
> compaction.   With no reclaim at all, zram is a simpler use
> case but if you implement compaction in a way that can't be
> used by either zcache or zswap, then zsmalloc is essentially
> forking.

I fail to understand "then zsmalloc is essentially forking.", could you 
explain more?

>
>>> In https://lkml.org/lkml/2013/3/27/501 I suggested it
>>> would be good to work together on a common design, but
>>> you didn't reply.  Are you thinking that zsmalloc
>> I saw the thread but explicit agreement is really matter?
>> I believe everybody want it although they didn't reply. :)
>>
>> You can make the design/post it or prototyping/post it.
>> If there are some conflit with something in my brain,
>> I will be happy to feedback. :)
>>
>> Anyway, I think my above statement "COMPACTION" would be enough to
>> express my current thought to avoid duplicated work and you can catch up.
>>
>> I will get around to it after LSF/MM.
>>
>>> improvements should focus only on zram, in which case
>> Just focusing zsmalloc.
> Right.  Again, I am asking if you are changing zsmalloc in
> a way that helps zram but hurts zswap and makes it impossible
> for zcache to ever use the improvements to zsmalloc.
>
> If so, that's fine, but please make it clear that is your goal.
>
>>> we may -- and possibly should -- end up with a different
>>> allocator for frontswap-based/cleancache-based compression
>>> in zcache (and possibly zswap)?
>>> I'm just trying to determine if I should proceed separately
>>> with my design (with Bob Liu, who expressed interest) or if
>>> it would be beneficial to work together.
>> Just posting and if it affects zsmalloc/zram/zswap and goes the way
>> I don't want, I will involve the discussion because our product uses
>> zram heavily and consider zswap, too.
>>
>> I really appreciate your enthusiastic collaboration model to find
>> optimal solution!
> My goal is to have compression be an integral part of Linux
> memory management.  It may be tied to a config option, but
> the goal is that distros turn it on by default.  I don't think
> zsmalloc meets that objective yet, but it may be fine for
> your needs.  If so it would be good to understand exactly why
> it doesn't meet the other zproject needs.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
