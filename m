Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id AEE816B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 14:48:20 -0400 (EDT)
Received: by mail-ve0-f202.google.com with SMTP id ox1so252571veb.5
        for <linux-mm@kvack.org>; Sun, 04 Aug 2013 11:48:19 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH V5 3/8] memcg: check for proper lock held in mem_cgroup_update_page_stat
References: <1375357402-9811-1-git-send-email-handai.szj@taobao.com>
	<1375357946-10228-1-git-send-email-handai.szj@taobao.com>
Date: Sun, 04 Aug 2013 11:48:18 -0700
Message-ID: <xr93a9kxwavh.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, glommer@gmail.com, fengguang.wu@intel.com, akpm@linux-foundation.org, Sha Zhengju <handai.szj@taobao.com>

On Thu, Aug 01 2013, Sha Zhengju wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
>
> We should call mem_cgroup_begin_update_page_stat() before
> mem_cgroup_update_page_stat() to get proper locks, however the
> latter doesn't do any checking that we use proper locking, which
> would be hard. Suggested by Michal Hock we could at least test for
                                     ^^ Hocko
> rcu_read_lock_held() because RCU is held if !mem_cgroup_disabled().
>
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

Reviewed-by: Greg Thelen <gthelen@google.com>

> ---
>  mm/memcontrol.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7691cef..4a55d46 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2301,6 +2301,7 @@ void mem_cgroup_update_page_stat(struct page *page,
>  	if (mem_cgroup_disabled())
>  		return;
>  
> +	VM_BUG_ON(!rcu_read_lock_held());
>  	memcg = pc->mem_cgroup;
>  	if (unlikely(!memcg || !PageCgroupUsed(pc)))
>  		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
