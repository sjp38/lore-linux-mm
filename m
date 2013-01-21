Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 24BD26B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 03:41:17 -0500 (EST)
Message-ID: <50FCFF34.9070308@parallels.com>
Date: Mon, 21 Jan 2013 12:41:24 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-5-git-send-email-glommer@parallels.com> <20130118160610.GI10701@dhcp22.suse.cz> <50FCF539.6070000@parallels.com> <20130121083418.GA7798@dhcp22.suse.cz>
In-Reply-To: <20130121083418.GA7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/21/2013 12:34 PM, Michal Hocko wrote:
> On Mon 21-01-13 11:58:49, Glauber Costa wrote:
>> On 01/18/2013 08:06 PM, Michal Hocko wrote:
>>>> +	/* bounce at first found */
>>>>> +	for_each_mem_cgroup_tree(iter, memcg) {
>>> This will not work. Consider you will see a !online memcg. What happens?
>>> mem_cgroup_iter will css_get group that it returns and css_put it when
>>> it visits another one or finishes the loop. So your poor iter will be
>>> released before it gets born. Not good.
>>>
>> Reading this again, I don't really follow. The iterator is not supposed
>> to put() anything it hasn't get()'d before, so we will never release the
>> group. Note that if it ever appears in here, the css refcnt is expected
>> to be at least 1 already.
>>
>> The online test relies on the memcg refcnt, not on the css refcnt.
> 
> Bahh, yeah, sorry about the confusion. Damn, it's not the first time I
> managed to mix those two...
> 
You're excused. This time.

>> Actually, now that the value setting is all done in css_online, the css
>> refcnt should be enough to denote if the cgroup already has children,
>> without a memcg-specific test. The css refcnt is bumped somewhere
>> between alloc and online. 
> 
> Yes, in init_cgroup_css.
Yes, but that should not matter. We should not depend on anything more
general than "between alloc and online".

> 
>> Unless Tejun objects it, I think I will just get rid of the online
>> test, and rely on the fact that if the iterator sees any children, we
>> should already online.
> 
> Which means that we are back to list_empty(&cgrp->children) test, aren't
> we. 

As long as cgroup core keeps using a list yes.
The css itself won't go away, regardless of the infrastructure cgroup
uses internally. So I do believe this is stronger long term.

Note that we have been arguing here about the css_refcnt, but we don't
actually refer to it: we do css_get and let cgroup core do whatever it
pleases it internally.


> If you really insist on not using
> children directly then do something like:
> 	struct cgroup *pos;
> 
> 	if (!memcg->use_hierarchy)
> 		cgroup_for_each_child(pos, memcg->css.cgroup)
> 			return true;
> 
> 	return false;
> 
I don't oppose that.

> This still has an issue that a change (e.g. vm_swappiness) that requires
> this check will fail even though the child creation fails after it is
> made visible (e.g. during css_online).
> 
Is it a problem ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
