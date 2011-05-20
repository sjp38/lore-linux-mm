Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 56D0B900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 19:56:53 -0400 (EDT)
Received: by bwz17 with SMTP id 17so5093795bwz.14
        for <linux-mm@kvack.org>; Fri, 20 May 2011 16:56:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110520144935.3bfdb2e2.akpm@linux-foundation.org>
References: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520124636.45c26cfa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110520144935.3bfdb2e2.akpm@linux-foundation.org>
Date: Sat, 21 May 2011 08:56:46 +0900
Message-ID: <BANLkTi=Ap=NdZ+05UjjEsC5f5wdjo9yvew@mail.gmail.com>
Subject: Re: [PATCH 6/8] memcg asynchronous memory reclaim interface
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>

2011/5/21 Andrew Morton <akpm@linux-foundation.org>:
> On Fri, 20 May 2011 12:46:36 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> This patch adds a logic to keep usage margin to the limit in asynchronou=
s way.
>> When the usage over some threshould (determined automatically), asynchro=
nous
>> memory reclaim runs and shrink memory to limit - MEMCG_ASYNC_STOP_MARGIN=
.
>>
>> By this, there will be no difference in total amount of usage of cpu to
>> scan the LRU
>
> This is not true if "don't writepage at all (revisit this when
> dirty_ratio comes.)" is true. =A0Skipping over dirty pages can cause
> larger amounts of CPU consumption.
>
>> but we'll have a chance to make use of wait time of applications
>> for freeing memory. For example, when an application read a file or sock=
et,
>> to fill the newly alloated memory, it needs wait. Async reclaim can make=
 use
>> of that time and give a chance to reduce latency by background works.
>>
>> This patch only includes required hooks to trigger async reclaim and use=
r interfaces.
>> Core logics will be in the following patches.
>>
>>
>> ...
>>
>> =A0/*
>> + * For example, with transparent hugepages, memory reclaim scan at hitt=
ing
>> + * limit can very long as to reclaim HPAGE_SIZE of memory. This increas=
es
>> + * latency of page fault and may cause fallback. At usual page allocati=
on,
>> + * we'll see some (shorter) latency, too. To reduce latency, it's appre=
ciated
>> + * to free memory in background to make margin to the limit. This consu=
mes
>> + * cpu but we'll have a chance to make use of wait time of applications
>> + * (read disk etc..) by asynchronous reclaim.
>> + *
>> + * This async reclaim tries to reclaim HPAGE_SIZE * 2 of pages when mar=
gin
>> + * to the limit is smaller than HPAGE_SIZE * 2. This will be enabled
>> + * automatically when the limit is set and it's greater than the thresh=
old.
>> + */
>> +#if HPAGE_SIZE !=3D PAGE_SIZE
>> +#define MEMCG_ASYNC_LIMIT_THRESH =A0 =A0 =A0(HPAGE_SIZE * 64)
>> +#define MEMCG_ASYNC_MARGIN =A0 =A0 =A0 =A0 (HPAGE_SIZE * 4)
>> +#else /* make the margin as 4M bytes */
>> +#define MEMCG_ASYNC_LIMIT_THRESH =A0 =A0 =A0(128 * 1024 * 1024)
>> +#define MEMCG_ASYNC_MARGIN =A0 =A0 =A0 =A0 =A0 =A0(8 * 1024 * 1024)
>> +#endif
>
> Document them, please. =A0How are they used, what are their units.
>

will do.


>> +static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem);
>> +
>> +/*
>> =A0 * The memory controller data structure. The memory controller contro=
ls both
>> =A0 * page cache and RSS per cgroup. We would eventually like to provide
>> =A0 * statistics based on the statistics developed by Rik Van Riel for c=
lock-pro,
>> @@ -278,6 +303,12 @@ struct mem_cgroup {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 unsigned long =A0 move_charge_at_immigrate;
>> =A0 =A0 =A0 /*
>> + =A0 =A0 =A0* Checks for async reclaim.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 unsigned long =A0 async_flags;
>> +#define AUTO_ASYNC_ENABLED =A0 (0)
>> +#define USE_AUTO_ASYNC =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1)
>
> These are really confusing. =A0I looked at the implementation and at the
> documentation file and I'm still scratching my head. =A0I can't work out
> why they exist. =A0With the amount of effort I put into it ;)
>
> Also, AUTO_ASYNC_ENABLED and USE_AUTO_ASYNC have practically the same
> meaning, which doesn't help things.
>
Ah, yes it's confusing.

> Some careful description at this place in the code might help clear
> things up.
>
yes, I'll fix and add text, consider better name.

> Perhaps s/USE_AUTO_ASYNC/AUTO_ASYNC_IN_USE/ is what you meant.
>
Ah, good name :)

>>
>> ...
>>
>> +static void mem_cgroup_may_async_reclaim(struct mem_cgroup *mem)
>> +{
>> + =A0 =A0 if (!test_bit(USE_AUTO_ASYNC, &mem->async_flags))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 if (res_counter_margin(&mem->res) <=3D MEMCG_ASYNC_MARGIN) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Fill here */
>> + =A0 =A0 }
>> +}
>
> I'd expect a function called foo_may_bar() to return a bool.
>
ok,

> But given the lack of documentation and no-op implementation, I have o
> idea what's happening here!
>
yes. Hmm, maybe adding an empty function here and comments on the
function will make this better.

Thank you for review.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
