Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A3AB86B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 14:46:26 -0500 (EST)
Received: by bkty12 with SMTP id y12so1878427bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 11:46:25 -0800 (PST)
Message-ID: <4F46978E.2090605@openvz.org>
Date: Thu, 23 Feb 2012 23:46:22 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 02/21] memcg: make mm_match_cgroup() hirarchical
References: <20120223133728.12988.5432.stgit@zurg> <20120223135146.12988.47611.stgit@zurg> <20120223180352.GA1701@cmpxchg.org>
In-Reply-To: <20120223180352.GA1701@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>

Johannes Weiner wrote:
> On Thu, Feb 23, 2012 at 05:51:46PM +0400, Konstantin Khlebnikov wrote:
>> Check mm-owner cgroup membership hierarchically.
>
> I think this one cat just beat up this other cat in front of my
> window, yelling something about money and missing product.  Anyway, I
> already forgot why we want this patch.  Could you describe that in the
> changelog, please?

Yeah, sorry for lack of comment.

This test is used in rmap walker at checling page referencies in reclaimer.
Memory cgroup shrinker want to skip all referencies outside of cgroup hierarchy
which is currently under reclaim.

Actually this patch does not important for this set and can be dropped without problems,
it does not share any context with other patches. Next patch is more important because
it fixes global reclaimer and required for further cleanups.

>
>> @@ -821,6 +821,26 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>   				struct mem_cgroup, css);
>>   }
>>
>> +/**
>> + * mm_match_cgroup - cgroup hierarchy mm membership test
>> + * @mm		mm_struct to test
>> + * @cgroup	target cgroup
>> + *
>> + * Returns true if mm belong this cgroup or any its child in hierarchy
>> + */
>> +int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
>> +{
>> +	struct mem_cgroup *memcg;
>> +
>> +	rcu_read_lock();
>> +	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
>> +	while (memcg != cgroup&&  memcg&&  memcg->use_hierarchy)
>> +		memcg = parent_mem_cgroup(memcg);
>> +	rcu_read_unlock();
>> +
>> +	return cgroup == memcg;
>> +}
>
> Please don't duplicate mem_cgroup_same_or_subtree()'s functionality in
> a worse way.  The hierarchy information is kept in a stack such that
> ancestry can be detected in linear time, check out css_is_ancestor().

Ok, there will be something like that:

+bool mm_match_cgroup(const struct mm_struct *mm,
+                    const struct mem_cgroup *cgroup)
+{
+       struct mem_cgroup *memcg;
+       bool ret;
+
+       rcu_read_lock();
+       memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+       ret = memcg && mem_cgroup_same_or_subtree(cgroup, memcg);
+       rcu_read_unlock();
+
+       return ret;
+}
+

>
> If you don't want to nest rcu_read_lock(), you could push the
> rcu_read_lock() from css_is_ancestor() into its sole user and provide
> a __mem_cgroup_is_ancestor() that assumes rcu already read-locked.
>
> No?

It is not a problem.

looks like mem_cgroup_same_or_subtree() check something different,
because it does not check ->use_hierarchy flag on tested cgroup, only on target cgroup.

Or just all this hierarchical stuff is out of sync in different parts of code.
For example memcg_get_hierarchical_limit() start from deepest cgroup and go upper
while ->use_hierarchy is set.

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
