Date: Fri, 28 Mar 2008 19:55:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
Message-Id: <20080328195516.494edde3.kamezawa.hiroyu@jp.fujitsu.com>
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
> -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> +struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  {
>  	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>  				struct mem_cgroup, css);
> @@ -250,12 +250,17 @@ void mm_init_cgroup(struct mm_struct *mm
>  
>  	mem = mem_cgroup_from_task(p);
>  	css_get(&mem->css);
> -	mm->mem_cgroup = mem;
>  }
>  
>  void mm_free_cgroup(struct mm_struct *mm)
>  {
> -	css_put(&mm->mem_cgroup->css);
> +	struct mem_cgroup *mem;
> +
> +	/*
> +	 * TODO: Should we assign mm->owner to NULL here?
> +	 */
> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> +	css_put(&mem->css);
>  }
>  
How about changing this css_get()/css_put() from accounting against mm_struct
to accouting against task_struct ?
It seems simpler way after this mm->owner change.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
