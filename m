Date: Fri, 28 Mar 2008 19:48:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
Message-Id: <20080328194839.fe6ffa52.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 13:53:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> 
> This patch removes the mem_cgroup member from mm_struct and instead adds
> an owner. This approach was suggested by Paul Menage. The advantage of
> this approach is that, once the mm->owner is known, using the subsystem
> id, the cgroup can be determined. It also allows several control groups
> that are virtually grouped by mm_struct, to exist independent of the memory
> controller i.e., without adding mem_cgroup's for each controller,
> to mm_struct.
> 
> The code initially assigns mm->owner to the task and then after the
> thread group leader is identified. The mm->owner is changed to the thread
> group leader of the task later at the end of copy_process.
> 
Hmm, I like this approach. 

-a bit off topic-
BTW, could you move mem_cgroup_from_task() to include/linux/memcontrol.h ?

Then, I'll add an interface like
mem_cgroup_charge_xxx(struct page *page, struct mem_cgroup *mem, gfp_mask mask)

This can be called in following way:
mem_cgroup_charge_xxx(page, mem_cgroup_from_task(current), GFP_XXX);
and I don't have to access mm_struct's member in this case.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
