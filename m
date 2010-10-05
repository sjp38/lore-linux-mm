Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CC3326B0078
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:19:01 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o957Ix5a004722
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 16:18:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E562445DE52
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 17:15:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E562445DE4F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 17:15:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BFE6E38002
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 16:18:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B05C5E18001
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 16:18:58 +0900 (JST)
Date: Tue, 5 Oct 2010 16:13:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 08/10] memcg: add cgroupfs interface to memcg dirty
 limits
Message-Id: <20101005161340.9bb7382e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1286175485-30643-9-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-9-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun,  3 Oct 2010 23:58:03 -0700
Greg Thelen <gthelen@google.com> wrote:

> Add cgroupfs interface to memcg dirty page limits:
>   Direct write-out is controlled with:
>   - memory.dirty_ratio
>   - memory.dirty_bytes
> 
>   Background write-out is controlled with:
>   - memory.dirty_background_ratio
>   - memory.dirty_background_bytes
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

a question below.


> ---
>  mm/memcontrol.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 89 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6ec2625..2d45a0a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -100,6 +100,13 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> +enum {
> +	MEM_CGROUP_DIRTY_RATIO,
> +	MEM_CGROUP_DIRTY_BYTES,
> +	MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> +	MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +};
> +
>  struct mem_cgroup_stat_cpu {
>  	s64 count[MEM_CGROUP_STAT_NSTATS];
>  };
> @@ -4292,6 +4299,64 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> +static u64 mem_cgroup_dirty_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
> +	bool root;
> +
> +	root = mem_cgroup_is_root(mem);
> +
> +	switch (cft->private) {
> +	case MEM_CGROUP_DIRTY_RATIO:
> +		return root ? vm_dirty_ratio : mem->dirty_param.dirty_ratio;
> +	case MEM_CGROUP_DIRTY_BYTES:
> +		return root ? vm_dirty_bytes : mem->dirty_param.dirty_bytes;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> +		return root ? dirty_background_ratio :
> +			mem->dirty_param.dirty_background_ratio;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> +		return root ? dirty_background_bytes :
> +			mem->dirty_param.dirty_background_bytes;
> +	default:
> +		BUG();
> +	}
> +}
> +
> +static int
> +mem_cgroup_dirty_write(struct cgroup *cgrp, struct cftype *cft, u64 val)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	int type = cft->private;
> +
> +	if (cgrp->parent == NULL)
> +		return -EINVAL;
> +	if ((type == MEM_CGROUP_DIRTY_RATIO ||
> +	     type == MEM_CGROUP_DIRTY_BACKGROUND_RATIO) && val > 100)
> +		return -EINVAL;
> +	switch (type) {
> +	case MEM_CGROUP_DIRTY_RATIO:
> +		memcg->dirty_param.dirty_ratio = val;
> +		memcg->dirty_param.dirty_bytes = 0;
> +		break;
> +	case MEM_CGROUP_DIRTY_BYTES:
> +		memcg->dirty_param.dirty_bytes = val;
> +		memcg->dirty_param.dirty_ratio  = 0;
> +		break;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_RATIO:
> +		memcg->dirty_param.dirty_background_ratio = val;
> +		memcg->dirty_param.dirty_background_bytes = 0;
> +		break;
> +	case MEM_CGROUP_DIRTY_BACKGROUND_BYTES:
> +		memcg->dirty_param.dirty_background_bytes = val;
> +		memcg->dirty_param.dirty_background_ratio = 0;
> +		break;


Curious....is this same behavior as vm_dirty_ratio ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
