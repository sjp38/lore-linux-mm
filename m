Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 349376B0074
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:15:09 -0500 (EST)
Message-ID: <50B743A1.4040405@parallels.com>
Date: Thu, 29 Nov 2012 15:14:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
In-Reply-To: <1354138460-19286-1-git-send-email-tj@kernel.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/29/2012 01:34 AM, Tejun Heo wrote:
> This patchset decouples cpuset locking from cgroup_mutex.  After the
> patchset, cpuset uses cpuset-specific cpuset_mutex instead of
> cgroup_mutex.  This also removes the lockdep warning triggered during
> cpu offlining (see 0009).
> 
> Note that this leaves memcg as the only external user of cgroup_mutex.
> Michal, Kame, can you guys please convert memcg to use its own locking
> too?

Not totally. There is still one mention to the cgroup_lock():

static void cpuset_do_move_task(struct task_struct *tsk,
                                struct cgroup_scanner *scan)
{
        struct cgroup *new_cgroup = scan->data;

        cgroup_lock();
        cgroup_attach_task(new_cgroup, tsk);
        cgroup_unlock();
}

And similar problem to this, is the one we have in memcg: We need to
somehow guarantee that no tasks will join the cgroup for some time -
this is why we hold the lock in memcg.

Just calling a function that internally calls the cgroup lock won't do
much, since it won't solve any dependencies - where it is called matters
little.

What I'll try to do, is to come with another specialized lock in cgroup
just for this case. So after taking the cgroup lock, we would also take
an extra lock if we are adding another entry - be it task or children -
to the cgroup.

cpuset and memcg could then take that lock as well, explicitly or
implicitly.

How does it sound?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
