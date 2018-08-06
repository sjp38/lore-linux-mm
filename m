Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31CCB6B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 04:43:01 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5-v6so9452016ioh.4
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 01:43:01 -0700 (PDT)
Received: from us.icdsoft.com (us.icdsoft.com. [192.252.146.184])
        by mx.google.com with ESMTPS id v127-v6si4164273ith.121.2018.08.06.01.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 01:42:59 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
From: Georgi Nikolov <gnikolov@icdsoft.com>
Message-ID: <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
Date: Mon, 6 Aug 2018 11:42:48 +0300
MIME-Version: 1.0
In-Reply-To: <20180802085043.GC10808@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Florian Westphal <fw@strlen.de>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 08/02/2018 11:50 AM, Michal Hocko wrote:
> On Wed 01-08-18 19:03:03, Georgi Nikolov wrote:
>> *Georgi Nikolov*
>> System Administrator
>> www.icdsoft.com <http://www.icdsoft.com>
>>
>> On 08/01/2018 11:33 AM, Michal Hocko wrote:
>>> On Wed 01-08-18 09:34:23, Vlastimil Babka wrote:
>>>> On 07/31/2018 04:05 PM, Florian Westphal wrote:
>>>>> Georgi Nikolov <gnikolov@icdsoft.com> wrote:
>>>>>>> No, I think that's rather for the netfilter folks to decide. However, it
>>>>>>> seems there has been the debate already [1] and it was not found. The
>>>>>>> conclusion was that __GFP_NORETRY worked fine before, so it should work
>>>>>>> again after it's added back. But now we know that it doesn't...
>>>>>>>
>>>>>>> [1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u
>>>>>> Yes i see. I will add Florian Westphal to CC list. netfilter-devel is
>>>>>> already in this list so probably have to wait for their opinion.
>>>>> It hasn't changed, I think having OOM killer zap random processes
>>>>> just because userspace wants to import large iptables ruleset is not a
>>>>> good idea.
>>>> If we denied the allocation instead of OOM (e.g. by using
>>>> __GFP_RETRY_MAYFAIL), a slightly smaller one may succeed, still leaving
>>>> the system without much memory, so it will invoke OOM killer sooner or
>>>> later anyway.
>>>>
>>>> I don't see any silver-bullet solution, unfortunately. If this can be
>>>> abused by (multiple) namespaces, then they have to be contained by
>>>> kmemcg as that's the generic mechanism intended for this. Then we could
>>>> use the __GFP_RETRY_MAYFAIL.
>>>> The only limit we could impose to outright deny the allocation (to
>>>> prevent obvious bugs/admin mistakes or abuses) could be based on the
>>>> amount of RAM, as was suggested in the old thread.
>> Can we make this configurable - on/off switch or size above which
>> to pass GFP_NORETRY.
> Yet another tunable? How do you decide which one to select? Seriously,
> configuration knobs sound attractive but they are rarely a good idea.
> Either we trust privileged users or we don't and we have kmem accounting
> for that.
>
>> Probably hard coded based on amount of RAM is a good idea too.
> How do you scale that?
>
> In other words, why don't we simply do the following? Note that this is
> not tested. I have also no idea what is the lifetime of this allocation.
> Is it bound to any specific process or is it a namespace bound? If the
> later then the memcg OOM killer might wipe the whole memcg down without
> making any progress. This would make the whole namespace unsuable until
> somebody intervenes. Is this acceptable?
> ---
> From 4dec96eb64954a7e58264ed551afadf62ca4c5f7 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 2 Aug 2018 10:38:57 +0200
> Subject: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too
>  easilly
>
> eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
> in xt_alloc_table_info()") has unintentionally fortified
> xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
> the vmalloc fallback. Later on there was a syzbot report that this
> can lead to OOM killer invocations when tables are too large and
> 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> has been merged to restore the original behavior. Georgi Nikolov however
> noticed that he is not able to install his iptables anymore so this can
> be seen as a regression.
>
> The primary argument for 0537250fdc6c was that this allocation path
> shouldn't really trigger the OOM killer and kill innocent tasks. On the
> other hand the interface requires root and as such should allow what the
> admin asks for. Root inside a namespaces makes this more complicated
> because those might be not trusted in general. If they are not then such
> namespaces should be restricted anyway. Therefore drop the __GFP_NORETRY
> and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.
>
> Fixes: 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> Reported-by: Georgi Nikolov <gnikolov@icdsoft.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  net/netfilter/x_tables.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index d0d8397c9588..b769408e04ab 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -1178,12 +1178,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if (sz < sizeof(*info) || sz >= XT_MAX_TABLE_SIZE)
>  		return NULL;
>  
> -	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
> -	 * work reasonably well if sz is too large and bail out rather
> -	 * than shoot all processes down before realizing there is nothing
> -	 * more to reclaim.
> -	 */
> -	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> +	info = kvmalloc(sz, GFP_KERNEL | __GFP_ACCOUNT);
>  	if (!info)
>  		return NULL;
>  

I will check if this change fixes the problem.

Regards,

--
Georgi Nikolov
