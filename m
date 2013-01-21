Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 2FF476B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 02:58:36 -0500 (EST)
Message-ID: <50FCF539.6070000@parallels.com>
Date: Mon, 21 Jan 2013 11:58:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/7] memcg: fast hierarchy-aware child test.
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-5-git-send-email-glommer@parallels.com> <20130118160610.GI10701@dhcp22.suse.cz>
In-Reply-To: <20130118160610.GI10701@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/18/2013 08:06 PM, Michal Hocko wrote:
>> +	/* bounce at first found */
>> > +	for_each_mem_cgroup_tree(iter, memcg) {
> This will not work. Consider you will see a !online memcg. What happens?
> mem_cgroup_iter will css_get group that it returns and css_put it when
> it visits another one or finishes the loop. So your poor iter will be
> released before it gets born. Not good.
> 
Reading this again, I don't really follow. The iterator is not supposed
to put() anything it hasn't get()'d before, so we will never release the
group. Note that if it ever appears in here, the css refcnt is expected
to be at least 1 already.

The online test relies on the memcg refcnt, not on the css refcnt.

Actually, now that the value setting is all done in css_online, the css
refcnt should be enough to denote if the cgroup already has children,
without a memcg-specific test. The css refcnt is bumped somewhere
between alloc and online. Unless Tejun objects it, I think I will just
get rid of the online test, and rely on the fact that if the iterator
sees any children, we should already online.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
