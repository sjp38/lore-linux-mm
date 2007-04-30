Date: Mon, 30 Apr 2007 23:33:13 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: vm changes from linux-2.6.14 to linux-2.6.15
In-Reply-To: <20070430.150407.07642146.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0704302329390.3178@mtfhpc.demon.co.uk>
References: <1177852457.4390.26.camel@localhost.localdomain>
 <Pine.LNX.4.61.0704302159140.3178@mtfhpc.demon.co.uk>
 <20070430145414.88fda272.akpm@linux-foundation.org>
 <20070430.150407.07642146.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, andrea@suse.de, wli@holomorphy.com, sparclinux@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

Is this just sun4c or does it affect other sparc32 architectures.

Regards
 	Mark Fortescue.

On Mon, 30 Apr 2007, David Miller wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 30 Apr 2007 14:54:14 -0700
>
>> On Mon, 30 Apr 2007 22:36:27 +0100 (BST)
>> Mark Fortescue <mark@mtfhpc.demon.co.uk> wrote:
>>
>>> Hi all,
>>>
>>> I have tracked down a failure to successfully load/run the init task on my
>>> Sparcstation 1 clone (SS1) and Sparcstation 2 (SS2), sparc32 sun4c
>>> systems, to a patch:
>>>
>>>    commit 1a44e149084d772a1bcf4cdbdde8a013a8a1cfde.
>>>    [PATCH] .text page fault SMP scalability optimization
>>>
>>> Removing this patch fixes the issue and allows me to use kernels later
>>> than v2.5.14. (tested using linux-2.6.20.9).
>>>
>>> Given the comment provided by the git bisect, backing out this patch will
>>> probably have undesirable conseqnences for other platforms (especially
>>> powerpc64) so, if an architecture independent solution is not available,
>>> some/all of the code in handle_pte_fault() in mm/memory.c will need be to
>>> made architecture dependent.
>>>
>>> I am not sufficiently familear with the how the SS1/SS2 mmu works and how
>>> the linux memory management system works to understand why this patch
>>> prevents my sun4c SS1/SS2 systems from working.
>>>
>>> Advice and help on the approch to take and any code changes regarding this
>>> issue would be most welcome.
>>>
>>
>> Interesting - thanks for working that out.  Let's keep linux-mm on cc please.
>
> You can't elide the update_mmu_cache() call on sun4c because that will
> miss some critical TLB setups which are performed there.
>
> The sun4c TLB has two tiers of entries:
>
> 1) segment maps, these hold ptes for a range of addresses
> 2) ptes, mapped into segment maps
>
> update_mmu_cache() on sun4c take care of allocating and setting
> up the segment maps, so if you elide the call this never happens
> and we fault forever.
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
