Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 3C6D16B00C8
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:59:29 -0500 (EST)
Message-ID: <50B8D7D9.9010800@parallels.com>
Date: Fri, 30 Nov 2012 19:59:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] replace cgroup_lock with local lock in memcg
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <20121130155228.GE3873@htj.dyndns.org>
In-Reply-To: <20121130155228.GE3873@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 11/30/2012 07:52 PM, Tejun Heo wrote:
> Hey, Glauber.
> 
> I don't know enough about memcg to be acking this but overall it looks
> pretty good to me.
> 
> On Fri, Nov 30, 2012 at 05:31:22PM +0400, Glauber Costa wrote:
>> For the problem of attaching tasks, I am using something similar to cpusets:
>> when task attaching starts, we will flip a flag "attach_in_progress", that will
>> be flipped down when it finishes. This way, all readers can know that a task is
>> joining the group and take action accordingly. With this, we can guarantee that
>> the behavior of move_charge_at_immigrate continues safe
> 
> Yeap, attach_in_progress is useful if there are some conditions which
> shouldn't change between ->can_attach() and ->attach().  With the
> immigrate thing gone, this no longer is necessary, right?
> 

Yes and no. While it can help with immigrate, we still have kmem that
needs to be protected against tasks joining.

However, kmem is easier. If attach_in_progress is ever positive, it
means that a task is joining, and it is already unacceptable for kmem -
so we can fail right away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
