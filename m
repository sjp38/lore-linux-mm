Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AB94F6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 06:25:38 -0500 (EST)
Received: by iadj38 with SMTP id j38so5678207iad.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 03:25:38 -0800 (PST)
Message-ID: <4F16AC27.1080906@gmail.com>
Date: Wed, 18 Jan 2012 19:25:27 +0800
From: Sha <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org> <1326207772-16762-3-git-send-email-hannes@cmpxchg.org> <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com> <20120112085904.GG24386@cmpxchg.org> <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com> <20120113224424.GC1653@cmpxchg.org> <4F158418.2090509@gmail.com> <20120117145348.GA3144@cmpxchg.org> <CAFj3OHWY2Biw54gaGeH5fkxzgOhxn7NAibeYT_Jmga-_ypNSRg@mail.gmail.com> <20120118092509.GI24386@cmpxchg.org>
In-Reply-To: <20120118092509.GI24386@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/18/2012 05:25 PM, Johannes Weiner wrote:
> On Wed, Jan 18, 2012 at 03:17:25PM +0800, Sha wrote:
>>>> I don't think it solve the root of the problem, example:
>>>> root
>>>> ->  A (hard limit 20G, soft limit 12G, usage 20G)
>>>>    ->  A1 ( soft limit 2G,   usage 1G)
>>>>    ->  A2 ( soft limit 10G, usage 19G)
>>>>           ->B1 (soft limit 5G, usage 4G)
>>>>           ->B2 (soft limit 5G, usage 15G)
>>>>
>>>> Now A is hitting its hard limit and start hierarchical reclaim under A.
>>>> If we choose B1 to go through mem_cgroup_over_soft_limit, it will
>>>> return true because its parent A2 has a large usage and will lead to
>>>> priority=0 reclaiming. But in fact it should be B2 to be punished.
>>> Because A2 is over its soft limit, the whole hierarchy below it should
>>> be preferred over A1, so both B1 and B2 should be soft limit reclaimed
>>> to be consistent with behaviour at the root level.
>> Well it is just the behavior that I'm expecting actually. But with my
>> humble comprehension, I can't catch the soft-limit-based hierarchical
>> reclaiming under the target cgroup (A2) in the current implementation
>> or after the patch. Both the current mem_cgroup_soft_reclaim or
>> shrink_zone select victim sub-cgroup by mem_cgroup_iter, but it
>> doesn't take soft limit into consideration, do I left anything ?
> No, currently soft limits are ignored if pressure originates from
> below root_mem_cgroup.
>
> But iff soft limits are applied right now, they are applied
> hierarchically, see mem_cgroup_soft_limit_reclaim().
Er... I'm even more confused: mem_cgroup_soft_limit_reclaim indeed
choses the biggest soft-limit excessor first, but in the succeeding reclaim
mem_cgroup_hierarchical_reclaim just selects a child cgroup  by css_id
which has nothing to do with soft limit (see mem_cgroup_select_victim).
IMHO, it's not a genuine hierarchical reclaim.
I check this from the latest memcg-devel git tree (branch since-3.1)...

> In my opinion, the fact that soft limits are ignored when pressure is
> triggered sub-root_mem_cgroup is an artifact of the per-zone tree, so
> I allowed soft limits to be taken into account below root_mem_cgroup.
>
> But IMO, this is something different from how soft limit reclaim is
> applied once triggered: currently, soft limit reclaim applies to a
> whole hierarchy, including all children.  And this I left unchanged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
