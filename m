Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 92DD06B00B5
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:10:09 -0500 (EST)
Message-ID: <50B8CC3D.3040901@parallels.com>
Date: Fri, 30 Nov 2012 19:09:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <50B8263C.7060908@jp.fujitsu.com> <50B875B4.2020507@parallels.com> <20121130092435.GD29317@dhcp22.suse.cz> <50B87F84.7040206@parallels.com> <20121130094959.GE29317@dhcp22.suse.cz> <50B883B5.8020705@parallels.com> <20121130145924.GA3873@htj.dyndns.org>
In-Reply-To: <20121130145924.GA3873@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, bsingharora@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/30/2012 06:59 PM, Tejun Heo wrote:
> Hello,
> 
> On Fri, Nov 30, 2012 at 02:00:21PM +0400, Glauber Costa wrote:
>> Now, what I am actually seeing with cgroup creation, is that the
>> children will copy a lot of the values from the parent, like swappiness,
>> hierarchy, etc. Once the child copies it, we should no longer be able to
>> change those values in the parent: otherwise we'll get funny things like
>> parent.use_hierarchy = 1, child.use_hierarchy = 0.
> 
> So, the best way to do this is from ->css_online().  If memcg
> synchronizes and inherits from ->css_online(), it can guarantee that
> the new cgroup will be visible in any following iterations.  Just have
> an online flag which is turned on and off from ->css_on/offline() and
> ignore any cgroups w/o online set.
> 
>> One option is to take a global lock in memcg_alloc_css(), and keep it
>> locked until we did all the cgroup bookkeeping, and then unlock it in
>> css_online. But I am guessing Tejun won't like it very much.
> 
> No, please *NEVER* *EVER* do that.  You'll be creating a bunch of
> locking dependencies as cgroup walks through different controllers.
> 
> memcg should be able to synchornize fully both css on/offlining and
> task attachments in memcg proper.  Let's please be boring about
> locking.
> 

Of course, there was a purely rhetorical statement, as indicated by
"Tejun won't like it very much" =p

Take a look at the final result, I just posted a couple of hours ago.
Let me know if there is still something extremely funny, and I'll look
into fixing it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
