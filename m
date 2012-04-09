Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 04A956B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 01:58:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 279B33EE0B5
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:58:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 046DC45DE50
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:58:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E9045DE4E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:58:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5FBA1DB803E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:58:08 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AE391DB8038
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:58:08 +0900 (JST)
Message-ID: <4F827A01.4000302@jp.fujitsu.com>
Date: Mon, 09 Apr 2012 14:56:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V5 09/14] memcg: track resource index in cftype private
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1333738260-1329-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/04/07 3:50), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This helps in using same memcg callbacks for non reclaim resource
> control files.
>


please modify the changelog. This doesn't explain any contents in this patch.

 - add 'index' field to memcg files's attribute
 - support hugetlb type.
 - support modification of hugetlb res_counter.

Thanks,
-Kame

 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/memcontrol.c |   27 +++++++++++++++++++++------
>  1 file changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0a1f776..3bb3b42 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -381,9 +381,14 @@ enum charge_type {
>  #define _MEM			(0)
>  #define _MEMSWAP		(1)
>  #define _OOM_TYPE		(2)
> -#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
> -#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
> -#define MEMFILE_ATTR(val)	((val) & 0xffff)
> +#define _MEMHUGETLB		(3)
> +
> +/*  0 ... val ...16.... x...24...idx...32*/
> +#define __MEMFILE_PRIVATE(idx, x, val)	(((idx) << 24) | ((x) << 16) | (val))
> +#define MEMFILE_PRIVATE(x, val)		__MEMFILE_PRIVATE(0, x, val)
> +#define MEMFILE_TYPE(val)		(((val) >> 16) & 0xff)
> +#define MEMFILE_IDX(val)		(((val) >> 24) & 0xff)
> +#define MEMFILE_ATTR(val)		((val) & 0xffff)
>  /* Used for OOM nofiier */
>  #define OOM_CONTROL		(0)
>  
> @@ -4003,7 +4008,7 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  	char str[64];
>  	u64 val;
> -	int type, name, len;
> +	int type, name, len, idx;
>  
>  	type = MEMFILE_TYPE(cft->private);
>  	name = MEMFILE_ATTR(cft->private);
> @@ -4024,6 +4029,10 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  		else
>  			val = res_counter_read_u64(&memcg->memsw, name);
>  		break;
> +	case _MEMHUGETLB:
> +		idx = MEMFILE_IDX(cft->private);
> +		val = res_counter_read_u64(&memcg->hugepage[idx], name);
> +		break;
>  	default:
>  		BUG();
>  	}
> @@ -4061,7 +4070,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  			break;
>  		if (type == _MEM)
>  			ret = mem_cgroup_resize_limit(memcg, val);
> -		else
> +		else if (type == _MEMHUGETLB) {
> +			int idx = MEMFILE_IDX(cft->private);
> +			ret = res_counter_set_limit(&memcg->hugepage[idx], val);
> +		} else
>  			ret = mem_cgroup_resize_memsw_limit(memcg, val);
>  		break;
>  	case RES_SOFT_LIMIT:
> @@ -4127,7 +4139,10 @@ static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)
>  	case RES_MAX_USAGE:
>  		if (type == _MEM)
>  			res_counter_reset_max(&memcg->res);
> -		else
> +		else if (type == _MEMHUGETLB) {
> +			int idx = MEMFILE_IDX(event);
> +			res_counter_reset_max(&memcg->hugepage[idx]);
> +		} else
>  			res_counter_reset_max(&memcg->memsw);
>  		break;
>  	case RES_FAILCNT:



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
