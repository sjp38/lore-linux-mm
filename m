Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id F0A9E6B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 02:18:09 -0400 (EDT)
Message-ID: <501231F0.8050505@huawei.com>
Date: Fri, 27 Jul 2012 14:15:12 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
References: <87ipdjc15j.fsf@skywalker.in.ibm.com> <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120719165046.GO24336@google.com> <1342799140.2583.6.camel@twins> <20120720200542.GD21218@google.com>
In-Reply-To: <20120720200542.GD21218@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, cgroups@vger.kernel.org, linux-mm@kvack.org, glommer@parallels.com

On 2012/7/21 4:05, Tejun Heo wrote:

> Hey, Peter.
> 
> On Fri, Jul 20, 2012 at 05:45:40PM +0200, Peter Zijlstra wrote:
>>> So, Peter, why does cpuset mangle with cgroup_mutex?  What guarantees
>>> does it need?  Why can't it work on "changed" notification while
>>> caching the current css like blkcg does?
>>
>> I've no clue sorry.. /me goes stare at this stuff.. Looks like something
>> Paul Menage did when he created cgroups. I'll have to have a hard look
>> at all that to untangle this. Not something obvious to me.
> 
> Yeah, it would be great if this can be untangled.  I really don't see
> any other reasonable way out of this circular locking mess.  If cpuset
> needs stable css association across certain period, the RTTD is
> caching the css by holding its ref and synchronize modifications to
> that cache, rather than synchronizing cgroup operations themselves.
> 


The cgroup core was extracted from cpuset, so they are deeply tangled.

There are several issues to resolve with regard to removing cgroup lock from cpuset.

- there are places that the cgroup hierarchy is travelled. This should be
easy, as cpuset can be made to maintain its hierarchy.

- cpuset disallows clearing cpuset.mems/cpuset.cpus if the cgroup is not empty,
which can be guaranteed only by cgroup lock.

- cpuset disallows a task be attached to a cgroup with empty cpuset.mems/cpuset.cpus,
which again can be guarantted only by cgroup lock.

- cpuset may move tasks from a cgroup to another cgroup (Glauber mentioned this).

- maybe other cases I overlooked..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
