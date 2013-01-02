Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 760CF6B0074
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 00:12:21 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 06/13] cpuset: cleanup cpuset[_can]_attach()
In-Reply-To: <20121226120415.GA18193@mtj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org> <1354138460-19286-7-git-send-email-tj@kernel.org> <50DACF5B.6050705@huawei.com> <20121226120415.GA18193@mtj.dyndns.org>
Date: Wed, 02 Jan 2013 15:12:15 +1030
Message-ID: <87zk0s5h7c.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>
Cc: paul@paulmenage.org, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tejun Heo <tj@kernel.org> writes:

> (cc'ing Rusty, hi!)
>
> Hello, Li.
>
> On Wed, Dec 26, 2012 at 06:20:11PM +0800, Li Zefan wrote:
>> On 2012/11/29 5:34, Tejun Heo wrote:
>> > cpuset_can_attach() prepare global variables cpus_attach and
>> > cpuset_attach_nodemask_{to|from} which are used by cpuset_attach().
>> > There is no reason to prepare in cpuset_can_attach().  The same
>> > information can be accessed from cpuset_attach().
>> > 
>> > Move the prepartion logic from cpuset_can_attach() to cpuset_attach()
>> > and make the global variables static ones inside cpuset_attach().
>> > 
>> > While at it, convert cpus_attach to cpumask_t from cpumask_var_t.
>> > There's no reason to mess with dynamic allocation on a static buffer.
>> > 
>> 
>> But Rusty had been deprecating the use of cpumask_t. I don't know why
>> the final deprecation hasn't been completed yet.
>
> Hmmm?  cpumask_t can't be used for stack but other than that I don't
> see how it would be deprecated completely.  Rusty, can you please
> chime in?

The long-never-quite-complete-plan was for struct cpumask to be
undefined when CONFIG_CPUMASK_OFFSTACK=y.  That means noone can declare
them, or pass them on the stack, since they'll get a compiler error.

Now, there are some cases where it really is a reason to use a static
bitmap, and 1/2 a K of wasted space be damned.  There's a
deliberately-ugly way of doing that: declare a bitmap and use
to_cpumask().  Of course, if we ever really want to remove NR_CPUS and
make it completely generic, we have to kill all these too, but noone is
serious about that.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
