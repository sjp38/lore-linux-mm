Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E988A6B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 07:03:33 -0400 (EDT)
Message-ID: <4CAC577F.9040401@rsk.demon.co.uk>
Date: Wed, 06 Oct 2010 12:03:27 +0100
From: Richard Kennedy <richard@rsk.demon.co.uk>
MIME-Version: 1.0
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
In-Reply-To: <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On 06/10/10 09:01, Pekka Enberg wrote:
> (Adding more people who've taken interest in slab performance in the
> past to CC.)
> 
> On Tue, Oct 5, 2010 at 9:57 PM, Christoph Lameter <cl@linux.com> wrote:
>> V3->V4:
>> - Lots of debugging
>> - Performance optimizations (more would be good)...
>> - Drop per slab locking in favor of per node locking for
>>  partial lists (queuing implies freeing large amounts of objects
>>  to per node lists of slab).
>> - Implement object expiration via reclaim VM logic.
>>
>> The following is a release of an allocator based on SLAB
>> and SLUB that integrates the best approaches from both allocators. The
>> per cpu queuing is like in SLAB whereas much of the infrastructure
>> comes from SLUB.
>>
>> After this patches SLUB will track the cpu cache contents
>> like SLAB attemped to. There are a number of architectural differences:
>>
>> 1. SLUB accurately tracks cpu caches instead of assuming that there
>>   is only a single cpu cache per node or system.
>>
>> 2. SLUB object expiration is tied into the page reclaim logic. There
>>   is no periodic cache expiration.
>>
>> 3. SLUB caches are dynamically configurable via the sysfs filesystem.
>>
>> 4. There is no per slab page metadata structure to maintain (aside
>>   from the object bitmap that usually fits into the page struct).
>>
>> 5. Has all the resiliency and diagnostic features of SLUB.
>>
>> The unified allocator is a merging of SLUB with some queuing concepts from
>> SLAB and a new way of managing objects in the slabs using bitmaps. Memory
>> wise this is slightly more inefficient than SLUB (due to the need to place
>> large bitmaps --sized a few words--in some slab pages if there are more
>> than BITS_PER_LONG objects in a slab) but in general does not increase space
>> use too much.
>>
>> The SLAB scheme of not touching the object during management is adopted.
>> The unified allocator can efficiently free and allocate cache cold objects
>> without causing cache misses.
>>


Hi Christoph,
What tree are these patches against ? I'm getting patch failures on the
main tree.

regards
Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
