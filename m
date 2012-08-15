Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E2F436B002B
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 10:02:03 -0400 (EDT)
Message-ID: <502BABCF.7020608@parallels.com>
Date: Wed, 15 Aug 2012 18:01:51 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 06/11] memcg: kmem controller infrastructure
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-7-git-send-email-glommer@parallels.com> <20120814172540.GD6905@dhcp22.suse.cz> <502B6F00.8040207@parallels.com> <20120815130952.GI23985@dhcp22.suse.cz>
In-Reply-To: <20120815130952.GI23985@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 08/15/2012 05:09 PM, Michal Hocko wrote:
> On Wed 15-08-12 13:42:24, Glauber Costa wrote:
> [...]
>>>> +
>>>> +	ret = 0;
>>>> +
>>>> +	if (!memcg)
>>>> +		return ret;
>>>> +
>>>> +	_memcg = memcg;
>>>> +	ret = __mem_cgroup_try_charge(NULL, gfp, delta / PAGE_SIZE,
>>>> +	    &_memcg, may_oom);
>>>
>>> This is really dangerous because atomic allocation which seem to be
>>> possible could result in deadlocks because of the reclaim. 
>>
>> Can you elaborate on how this would happen?
> 
> Say you have an atomic allocation and we hit the limit so we get either
> to reclaim which can sleep or to oom which can sleep as well (depending
> on the oom_control).
> 

I see now, you seem to be right.

How about we change the following code in mem_cgroup_do_charge:

        if (gfp_mask & __GFP_NORETRY)
                return CHARGE_NOMEM;

to:

        if ((gfp_mask & __GFP_NORETRY) || (gfp_mask & __GFP_ATOMIC))
                return CHARGE_NOMEM;

?

Would this take care of the issue ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
