Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 05B846B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 05:09:34 -0500 (EST)
Received: by mail-la0-f49.google.com with SMTP id er20so6503506lab.8
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 02:09:33 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ji2si22165971lbc.126.2013.11.29.02.09.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 02:09:33 -0800 (PST)
Message-ID: <529867CE.4040004@parallels.com>
Date: Fri, 29 Nov 2013 14:09:18 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix kmem_account_flags check in memcg_can_account_kmem()
References: <1385567162-14973-1-git-send-email-vdavydov@parallels.com> <20131129094502.GD25893@dhcp22.suse.cz>
In-Reply-To: <20131129094502.GD25893@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 11/29/2013 01:45 PM, Michal Hocko wrote:
> On Wed 27-11-13 19:46:01, Vladimir Davydov wrote:
>> We should start kmem accounting for a memory cgroup only after both its
>> kmem limit is set (KMEM_ACCOUNTED_ACTIVE) and related call sites are
>> patched (KMEM_ACCOUNTED_ACTIVATED).
> This should be vice-versa, no? ACTIVE is set after
> static_key_slow_inc(&memcg_kmem_enabled_key) AFAICS.
>
>> Currently memcg_can_account_kmem() allows kmem accounting even if only
>> one of the conditions is true.
>> Fix it.
> It would be nice to describe, what is the actual problem here. I assume
> this is a charge vs. enable race. Let me try
>
> So we have KMEM_ACCOUNTED_ACTIVATED (set by memcg_update_cache_sizes)
> but the static key is not enabled yet (so KMEM_ACCOUNTED_ACTIVE is not
> set yet). memcg_can_account_kmem is called from 2 contexts during charge
> 	- memcg_kmem_get_cache via __memcg_kmem_get_cache
> 	- memcg_kmem_newpage_charge via __memcg_kmem_newpage_charge
>
> both of them start by checking memcg_kmem_enabled which is our
> static key before memcg_can_account_kmem. This would suggest that
> static_key+ACTIVE check memcg_can_account_kmem is sufficient. No?

Yes, I guess you're perfectly right and we don't need the ACTIVATED bit 
at all. I'll look at this deeper and send a patch removing it if it 
doesn't break something.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
