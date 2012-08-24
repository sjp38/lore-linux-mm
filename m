Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id C86826B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 01:27:47 -0400 (EDT)
Message-ID: <50370FEE.40106@parallels.com>
Date: Fri, 24 Aug 2012 09:23:58 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 09/11] memcg: propagate kmem limiting information to
 children
References: <1344517279-30646-1-git-send-email-glommer@parallels.com> <1344517279-30646-10-git-send-email-glommer@parallels.com> <20120817090005.GC18600@dhcp22.suse.cz> <502E0BC3.8090204@parallels.com> <20120817093504.GE18600@dhcp22.suse.cz> <502E17C4.7060204@parallels.com> <20120817103550.GF18600@dhcp22.suse.cz> <502E1E90.1080805@parallels.com> <20120821075430.GA19797@dhcp22.suse.cz> <50335341.6010400@parallels.com> <20120821100007.GE19797@dhcp22.suse.cz> <xr93fw7fbumo.fsf@gthelen.mtv.corp.google.com> <503496D9.3020806@parallels.com> <xr93a9xmwly7.fsf@gthelen.mtv.corp.google.com> <5035E1D6.6010503@parallels.com> <xr93harsvpxx.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr93harsvpxx.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 08/24/2012 09:06 AM, Greg Thelen wrote:
> On Thu, Aug 23 2012, Glauber Costa wrote:
> 
>> On 08/23/2012 03:23 AM, Greg Thelen wrote:
>>> On Wed, Aug 22 2012, Glauber Costa wrote:
>>>
>>>>>>>
>>>>>>> I am fine with either, I just need a clear sign from you guys so I don't
>>>>>>> keep deimplementing and reimplementing this forever.
>>>>>>
>>>>>> I would be for make it simple now and go with additional features later
>>>>>> when there is a demand for them. Maybe we will have runtimg switch for
>>>>>> user memory accounting as well one day.
>>>>>>
>>>>>> But let's see what others think?
>>>>>
>>>>> In my use case memcg will either be disable or (enabled and kmem
>>>>> limiting enabled).
>>>>>
>>>>> I'm not sure I follow the discussion about history.  Are we saying that
>>>>> once a kmem limit is set then kmem will be accounted/charged to memcg.
>>>>> Is this discussion about the static branches/etc that are autotuned the
>>>>> first time is enabled?  
>>>>
>>>> No, the question is about when you unlimit a former kmem-limited memcg.
>>>>
>>>>> The first time its set there parts of the system
>>>>> will be adjusted in such a way that may impose a performance overhead
>>>>> (static branches, etc).  Thereafter the performance cannot be regained
>>>>> without a reboot.  This makes sense to me.  Are we saying that
>>>>> kmem.limit_in_bytes will have three states?
>>>>
>>>> It is not about performance, about interface.
>>>>
>>>> Michal says that once a particular memcg was kmem-limited, it will keep
>>>> accounting pages, even if you make it unlimited. The limits won't be
>>>> enforced, for sure - there is no limit, but pages will still be accounted.
>>>>
>>>> This simplifies the code galore, but I worry about the interface: A
>>>> person looking at the current status of the files only, without
>>>> knowledge of past history, can't tell if allocations will be tracked or not.
>>>
>>> In the current patch set we've conflating enabling kmem accounting with
>>> the kmem limit value (RESOURCE_MAX=disabled, all_other_values=enabled).
>>>
>>> I see no problem with simpling the kernel code with the requirement that
>>> once a particular memcg enables kmem accounting that it cannot be
>>> disabled for that memcg.
>>>
>>> The only question is the user space interface.  Two options spring to
>>> mind:
>>> a) Close to current code.  Once kmem.limit_in_bytes is set to
>>>    non-RESOURCE_MAX, then kmem accounting is enabled and cannot be
>>>    disabled.  Therefore the limit cannot be set to RESOURCE_MAX
>>>    thereafter.  The largest value would be something like
>>>    RESOURCE_MAX-PAGE_SIZE.  An admin wondering if kmem is enabled only
>>>    has to cat kmem.limit_in_bytes - if it's less than RESOURCE_MAX, then
>>>    kmem is enabled.
>>>
>>
>> If we need to choose between them, I like this better than your (b).
>> At least it is all clear, and "fix" the history problem, since it is
>> possible to look up the status of the files and figure it out.
>>
>>> b) Or, if we could introduce a separate sticky kmem.enabled file.  Once
>>>    set it could not be unset.  Kmem accounting would only be enabled if
>>>    kmem.enabled=1.
>>>
>>> I think (b) is clearer.
>>>
>> Depends on your definition of clearer. We had a knob for
>> kmem_independent in the beginning if you remember, and it was removed.
>> The main reason being knobs complicate minds, and we happen to have a
>> very natural signal for this. I believe the same reasoning applies here.
> 
> Sounds good to me, so let's go with (a).
> 
Michal, what do you think ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
