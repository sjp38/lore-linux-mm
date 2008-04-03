From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v5)
Date: Thu, 3 Apr 2008 15:41:06 +0900
Message-ID: <20080403154106.39f26460.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080403055901.31796.41411.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761177AbYDCGh0@vger.kernel.org>
In-Reply-To: <20080403055901.31796.41411.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

just nitpicks ;)

On Thu, 03 Apr 2008 11:29:01 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

>  #define mm_match_cgroup(mm, cgroup)	\
> -	((cgroup) == rcu_dereference((mm)->mem_cgroup))
> +	((cgroup) == mem_cgroup_from_task((mm)->owner))
>  

After this patch, above should be 
==
#define mm_match_cgroup_css(mm, css, subsys_id)
	((css) == task_subsys_state((mm)->owner, subsys_id) 
==
This generic macro may be good for your purpose.


>  #endif
> diff -puN init/Kconfig~memory-controller-add-mm-owner init/Kconfig
> --- linux-2.6.25-rc8/init/Kconfig~memory-controller-add-mm-owner	2008-04-03 10:08:23.000000000 +0530
> +++ linux-2.6.25-rc8-balbir/init/Kconfig	2008-04-03 10:08:23.000000000 +0530
> @@ -371,9 +371,21 @@ config RESOURCE_COUNTERS
>            infrastructure that works with cgroups
>  	depends on CGROUPS
>  
> +config MM_OWNER
> +	bool "Enable ownership of mm structure"
> +	help
> +	  This option enables mm_struct's to have an owner. The advantage
> +	  of this approach is that it allows for several independent memory
> +	  based cgorup controllers to co-exist independently without too
> +	  much space overhead
	 Above is an explanation for this patch.
	  More simple text is better... How about
	 ==
	  This is necessary for some cgroup subsystem related to memory management.
	 ==
> +
> +	  This feature adds fork/exit overhead. So enable this only if
> +	  you need resource controllers
> +


>  config CGROUP_MEM_RES_CTLR
>  	bool "Memory Resource Controller for Control Groups"
>  	depends on CGROUPS && RESOURCE_COUNTERS
> +	select MM_OWNER

I don't like "select"....this should be
	depends on CGROUPS && RESOURCE_COUNTERS && MM_OWNER

Thanks,
-Kame
