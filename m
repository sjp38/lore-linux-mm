Message-ID: <493F2737.9060901@cn.fujitsu.com>
Date: Wed, 10 Dec 2008 10:19:35 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com> <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +static bool memcg_is_obsolete(struct mem_cgroup *mem)
> +{

Will this function be called with mem->css.refcnt == 0? If yes, then
this function is racy.

cg = mem->css.cgroup
				cgroup_diput()
				  mem_cgroup_destroy()
				    mem->css.cgroup = NULL;
				  kfree(cg);
if (!cg || cgroup_is_removed(cg)...)

(accessing invalid cg)

> +	struct cgroup *cg = mem->css.cgroup;
> +	/*
> +	 * "Being Removed" means pre_destroy() handler is called.
> +	 * After  "pre_destroy" handler is called, memcg should not
> +	 * have any additional charges.
> +	 * This means there are small races for mis-accounting. But this
> +	 * mis-accounting should happen only under swap-in opration.
> +	 * (Attachin new task will fail if cgroup is under rmdir()).
> +	 */
> +
> +	if (!cg || cgroup_is_removed(cg) || cgroup_is_being_removed(cg))
> +		return true;
> +	return false;
> +}
> +

...

>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {
> -	mem_cgroup_free(mem_cgroup_from_cont(cont));
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont):
> +	mem_cgroup_free(mem);
> +	/* forget */
> +	mem->css.cgroup = NULL;

mem might already be destroyed by mem_cgroup_free(mem).

>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
