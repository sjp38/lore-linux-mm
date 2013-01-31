Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id F2B2F6B0027
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 01:19:07 -0500 (EST)
Message-ID: <510A0CD1.5090403@oracle.com>
Date: Thu, 31 Jan 2013 14:18:57 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/6] memcg: bypass swap accounting for the root memcg
References: <510658EE.9050006@oracle.com> <5107A211.50409@parallels.com>
In-Reply-To: <5107A211.50409@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lord Glauber Costa of Sealand <glommer@parallels.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, handai.szj@taobao.com

Hi Glauber,

Sorry for my late response!
On 01/29/2013 06:18 PM, Lord Glauber Costa of Sealand wrote:
> On 01/28/2013 02:54 PM, Jeff Liu wrote:
>> Root memcg with swap cgroup is special since we only do tracking but can
>> not set limits against it.  In order to facilitate the implementation of
>> the coming swap cgroup structures delay allocation mechanism, we can bypass
>> the default swap statistics upon the root memcg and figure it out through
>> the global stats instead as below:
>>
> I am sorry if this is was already discussed before, but:
>> root_memcg_swap_stat: total_swap_pages - nr_swap_pages - used_swap_pages_of_all_memcgs
>> memcg_total_swap_stats: root_memcg_swap_stat + other_memcg_swap_stats
>>
> 
> Shouldn't it *at least* be dependent on use_hierarchy?
Yeah, actually use_hierarchy only affects the total swap numbers. While
computing memcg_total_swap_stats, it's original
for_each_mem_cgroup_tree() way already handle the stuff about hierarchy
and here we do not change its behavior. What we do is adding the root's
local swap stat to total (since the root statistics are not accounting
anymore, the per cpu data is ZERO).

> 
> I don't see why root_memcg won't be always total_swap_pages -
> nr_swap_pages, since the root memcg is always viewed as a superset of
> the others, AFAIR.
> 
> Even if it is not the general case (which again, I really believe it
> is), it certainly is the case for hierarchy enabled setups.
I'm also confused a little by hierarchy recently especially the
corresponding behavior of root is different... But we may have to do
some modification just based on the current implementation as the plan
of getting rid of hierarchy is slow as Michal mentioned.

> 
> Also, I truly don't understand what is the business of
> root_memcg_swap_stat in non-root memcgs.
root_memcg_swap_stat represents swap numbers belonging to the root mem
cgroup. As its stats is 0 now, we need to fake it by the help of other
memcgs, that is: global_used_swap - swaps_used_by_other_memcgs(non-root
memcgs).


Thanks,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
