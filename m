Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 07ECE6B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:52:50 -0500 (EST)
Date: Fri, 25 Jan 2013 15:52:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 2/6] memcg: split part of memcg creation to
 css_online
Message-Id: <20130125155249.402c40dd.akpm@linux-foundation.org>
In-Reply-To: <1358862461-18046-3-git-send-email-glommer@parallels.com>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
	<1358862461-18046-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Tue, 22 Jan 2013 17:47:37 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch is a preparatory work for later locking rework to get rid of
> big cgroup lock from memory controller code.

Is this complete?  From my reading, the patch is also a bugfix.  It
prevents stale tunable values from getting installed into new children?

> The memory controller uses some tunables to adjust its operation. Those
> tunables are inherited from parent to children upon children
> intialization. For most of them, the value cannot be changed after the
> parent has a new children.
> 
> cgroup core splits initialization in two phases: css_alloc and css_online.
> After css_alloc, the memory allocation and basic initialization are
> done. But the new group is not yet visible anywhere, not even for cgroup
> core code. It is only somewhere between css_alloc and css_online that it
> is inserted into the internal children lists. Copying tunable values in
> css_alloc will lead to inconsistent values: the children will copy the
> old parent values, that can change between the copy and the moment in
> which the groups is linked to any data structure that can indicate the
> presence of children.

That describes the problem, but not the fix.  Don't we need something
like "therefore move the propagation of tunables into the css_online
handler".

What remains unclear is how we prevent races during the operation of
the css_online handler.  Suppose mem_cgroup_css_online() is
mid-execution and userspace comes in and starts modifying the parent's
tunables?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
