Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 3A7B86B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 08:25:08 -0400 (EDT)
Date: Mon, 13 May 2013 14:25:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2 2/3] memcg: alter
 mem_cgroup_{update,inc,dec}_page_stat() args to memcg pointer
Message-ID: <20130513122504.GA5246@dhcp22.suse.cz>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
 <1368421524-4937-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368421524-4937-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

On Mon 13-05-13 13:05:24, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Change the first argument of mem_cgroup_{update,inc,dec}_page_stat() from
> 'struct page *' to 'struct mem_cgroup *', and so move PageCgroupUsed(pc)
> checking out of mem_cgroup_update_page_stat(). This is a prepare patch for
> the following memcg page stat lock simplifying.

No, please do not do this because it just spreads memcg specific code
out of memcontrol.c. Besides that the patch is not correct.
[...]
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1109,12 +1109,24 @@ void page_add_file_rmap(struct page *page)
>  {
>  	bool locked;
>  	unsigned long flags;
> +	struct page_cgroup *pc;
> +	struct mem_cgroup *memcg = NULL;
>  
>  	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> +	pc = lookup_page_cgroup(page);
> +
> +	rcu_read_lock();
> +	memcg = pc->mem_cgroup;

a) unnecessary RCU take for memcg disabled and b) worse KABOOM in that case
as page_cgroup is NULL. We really do not want to put
mem_cgroup_disabled() tests all over the place. The idea behind
mem_cgroup_begin_update_page_stat was to be almost a noop for !memcg
(and the real noop for !CONFIG_MEMCG).

so Nak to this approach
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
