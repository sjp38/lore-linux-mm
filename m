Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 2D0546B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 15:53:07 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id g10so1324363qah.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2013 12:53:06 -0700 (PDT)
Date: Thu, 13 Jun 2013 12:53:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 5/9] memcg: use css_get/put when charging/uncharging
 kmem
Message-ID: <20130613195300.GE13970@mtj.dyndns.org>
References: <51B98D17.2050902@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B98D17.2050902@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jun 13, 2013 at 05:12:55PM +0800, Li Zefan wrote:
> Sorry for updating the patchset so late.
> 
> I've made some changes for the memory barrier thing, and I agree with
> Michal that there can be improvement but can be a separate patch.
> 
> If this version is ok for everyone, I'll send the whole patchset out
> to Andrew.

Can you please post an updated patch as reply to the original patch?
It's a bit difficult to follow things.

> =========================
> 
> Use css_get/put instead of mem_cgroup_get/put.
> 
> We can't do a simple replacement, because here mem_cgroup_put()
> is called during mem_cgroup_css_free(), while mem_cgroup_css_free()
> won't be called until css refcnt goes down to 0.
> 
> Instead we increment css refcnt in mem_cgroup_css_offline(), and
> then check if there's still kmem charges. If not, css refcnt will
> be decremented immediately, otherwise the refcnt won't be decremented
> when kmem charges goes down to 0.
> 
> v3:
> - changed wmb() to smp_smb(), and moved it to memcg_kmem_mark_dead(),
>   and added comment.
> 
> v2:
> - added wmb() in kmem_cgroup_css_offline(), pointed out by Michal
> - revised comments as suggested by Michal
> - fixed to check if kmem is activated in kmem_cgroup_css_offline()
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.cz>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Tejun Heo <tj@kernel.org>

But let's please remove the barrier dancing.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
