Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 2347F6B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 11:17:25 -0400 (EDT)
Message-ID: <51BB33FE.1020403@yandex-team.ru>
Date: Fri, 14 Jun 2013 19:17:18 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Avoid direct compaction if possible
References: <51BB1802.8050108@yandex-team.ru> <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com>
In-Reply-To: <0000013f4319cb46-a5a3de58-1207-4037-ae39-574b58135ea2-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: penberg@kernel.org, mpm@selenic.com, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, glommer@parallels.com, hannes@cmpxchg.org, minchan@kernel.org, jiang.liu@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 14.06.2013 18:32, Christoph Lameter wrote:
> On Fri, 14 Jun 2013, Roman Gushchin wrote:
>
>> Slub tries to allocate contiguous pages even if memory is fragmented and
>> there are no free contiguous pages. In this case it calls direct compaction
>> to allocate contiguous page. Compaction requires the taking of some heavily
>> contended locks (e.g. zone locks). So, running compaction (direct and using
>> kswapd) simultaneously on several processors can cause serious performance
>> issues.
>
> The main thing that this patch does is to add a nocompact flag to the page
> allocator. That needs to be a separate patch. Also fix the description.
> Slub does not invoke compaction. The page allocator initiates compaction
> under certain conditions.

Ok, I'll do.

>
>> It's possible to avoid such problems (or at least to make them less probable)
>> by avoiding direct compaction. If it's not possible to allocate a contiguous
>> page without compaction, slub will fall back to order 0 page(s). In this case
>> kswapd will be woken to perform asynchronous compaction. So, slub can return
>> to default order allocations as soon as memory will be de-fragmented.
>
> Sounds like a good idea. Do you have some numbers to show the effect of
> this patch?

No.
It seems that any numbers here depend on memory fragmentation,
so it's not easy to make a reproducible measurement. If you have
any ideas here, you are welcome.

But there is an actual problem, that this patch solves.
Sometimes I saw the following issue on some machines:
all CPUs are performing compaction, system time is about 80%,
system is completely unreliable. It occurs only on machines
with specific workload (distributed data storage system, so,
intensive disk i/o is performed). A system can fall into
this state fast and unexpectedly or by progressive degradation.

This patch solves this problem.

Thank you for your comments and suggestions!

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
