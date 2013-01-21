Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DC6916B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:11:52 -0500 (EST)
Message-ID: <50FD5AC0.9020406@parallels.com>
Date: Mon, 21 Jan 2013 19:12:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
References: <1358766813-15095-1-git-send-email-glommer@parallels.com> <1358766813-15095-5-git-send-email-glommer@parallels.com> <20130121144919.GO7798@dhcp22.suse.cz>
In-Reply-To: <20130121144919.GO7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/21/2013 06:49 PM, Michal Hocko wrote:
> On Mon 21-01-13 15:13:31, Glauber Costa wrote:
>> After the preparation work done in earlier patches, the cgroup_lock can
>> be trivially replaced with a memcg-specific lock. This is an automatic
>> translation in every site the values involved were queried.
>>
>> The sites were values are written, however, used to be naturally called
>> under cgroup_lock. This is the case for instance of the css_online
>> callback. For those, we now need to explicitly add the memcg_lock.
>>
>> Also, now that the memcg_mutex is available, there is no need to abuse
>> the set_limit mutex in kmemcg value setting. The memcg_mutex will do a
>> better job, and we now resort to it.
> 
> You will hate me for this because I should have said that in the
> previous round already (but I will use "I shown a mercy on you and
> that blinded me" for my defense).
> I am not so sure it will do a better job (it is only kmem that uses both
> locks). I thought that memcg_mutex is just a first step and that we move
> to a more finer grained locking later (a too general documentation of
> the lock even asks for it).  So I would keep the limit mutex and figure
> whether memcg_mutex could be split up even further.
> 
> Other than that the patch looks good to me
> 
By now I have more than enough reasons to hate you, so this one won't
add much. Even then, don't worry. Beer resets it all.

That said, I disagree with you.

As you noted yourself, kmem needs both locks:
1) cgroup_lock, because we need to prevent creation of sub-groups.
2) set_limit lock, because we need one - any one - memcg global lock be
held while we are manipulating the kmem-specific data structures, and we
would like to spread cgroup_lock all around for that.

I now regret not having created the memcg_mutex for that: I'd be now
just extending it to other users, instead of trying a replacement.

So first of all, if the limit mutex is kept, we would *still* need to
hold the memcg mutex to avoid children appearing. If we *ever* switch to
a finer-grained lock(*), we will have to hold that lock anyway. So why
hold set_limit_mutex??

(*) None of the operations protected by this mutex are fast paths...


>> With this, all the calls to cgroup_lock outside cgroup core are gone.
> 
> OK, Tejun will be happy ;)
> 
He paid me ice cream.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
