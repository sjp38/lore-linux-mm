Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 57F786B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:34:17 -0500 (EST)
Message-ID: <50FD6003.8060703@parallels.com>
Date: Mon, 21 Jan 2013 19:34:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
References: <1358766813-15095-1-git-send-email-glommer@parallels.com> <1358766813-15095-5-git-send-email-glommer@parallels.com> <20130121144919.GO7798@dhcp22.suse.cz> <50FD5AC0.9020406@parallels.com> <20130121152032.GP7798@dhcp22.suse.cz>
In-Reply-To: <20130121152032.GP7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/21/2013 07:20 PM, Michal Hocko wrote:
> On Mon 21-01-13 19:12:00, Glauber Costa wrote:
>> On 01/21/2013 06:49 PM, Michal Hocko wrote:
>>> On Mon 21-01-13 15:13:31, Glauber Costa wrote:
>>>> After the preparation work done in earlier patches, the cgroup_lock can
>>>> be trivially replaced with a memcg-specific lock. This is an automatic
>>>> translation in every site the values involved were queried.
>>>>
>>>> The sites were values are written, however, used to be naturally called
>>>> under cgroup_lock. This is the case for instance of the css_online
>>>> callback. For those, we now need to explicitly add the memcg_lock.
>>>>
>>>> Also, now that the memcg_mutex is available, there is no need to abuse
>>>> the set_limit mutex in kmemcg value setting. The memcg_mutex will do a
>>>> better job, and we now resort to it.
>>>
>>> You will hate me for this because I should have said that in the
>>> previous round already (but I will use "I shown a mercy on you and
>>> that blinded me" for my defense).
>>> I am not so sure it will do a better job (it is only kmem that uses both
>>> locks). I thought that memcg_mutex is just a first step and that we move
>>> to a more finer grained locking later (a too general documentation of
>>> the lock even asks for it).  So I would keep the limit mutex and figure
>>> whether memcg_mutex could be split up even further.
>>>
>>> Other than that the patch looks good to me
>>>
>> By now I have more than enough reasons to hate you, so this one won't
>> add much. Even then, don't worry. Beer resets it all.
>>
>> That said, I disagree with you.
>>
>> As you noted yourself, kmem needs both locks:
>> 1) cgroup_lock, because we need to prevent creation of sub-groups.
>> 2) set_limit lock, because we need one - any one - memcg global lock be
>> held while we are manipulating the kmem-specific data structures, and we
>> would like to spread cgroup_lock all around for that.
>>
>> I now regret not having created the memcg_mutex for that: I'd be now
>> just extending it to other users, instead of trying a replacement.
>>
>> So first of all, if the limit mutex is kept, we would *still* need to
>> hold the memcg mutex to avoid children appearing. If we *ever* switch to
>> a finer-grained lock(*), we will have to hold that lock anyway. So why
>> hold set_limit_mutex??
> 
> Yeah but memcg is not just kmem, is it? 

No, it belongs to all of us. It is usually called collaboration, but in
the memcg context, we can say we are accomplices.

> See mem_cgroup_resize_limit for
> example. Why should it be linearized with, say, a new group creation.

Because it is simpler to use the same lock, and all those operations are
not exactly frequent.

> Same thing with memsw.

See, I'm not the only culprit!

> Besides that you know what those two locks are
> intended for. memcg_mutex to prevent from races with a new group
> creation and the limit lock for races with what-ever limit setting.
> This sounds much more specific than

Again: Can I keep holding the set_limit_mutex? Sure I can. But we still
need to hold both, because kmemcg is also forbidden for groups that
already have tasks. And the reason why kmemcg holds the set_limit mutex
is just to protect from itself, then there is no *need* to hold any
extra lock (and we'll never be able to stop holding the creation lock,
whatever it is). So my main point here is not memcg_mutex vs
set_limit_mutex, but rather, memcg_mutex is needed anyway, and once it
is taken, the set_limit_mutex *can* be held, but doesn't need to.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
