Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id CAA3B6B0044
	for <linux-mm@kvack.org>; Mon, 12 Mar 2012 08:40:01 -0400 (EDT)
Message-ID: <4F5DEE42.6050607@parallels.com>
Date: Mon, 12 Mar 2012 16:38:26 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: cgroups@vger.kernel.org, suleiman@google.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +int
> +memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, long long delta)
> +{
> +	struct res_counter *fail_res;
> +	struct mem_cgroup *_memcg;
> +	int may_oom, ret;
> +
> +	may_oom = (gfp&  __GFP_WAIT)&&  (gfp&  __GFP_FS)&&
> +	    !(gfp&  __GFP_NORETRY);
> +
> +	ret = 0;
> +
> +	_memcg = memcg;
> +	if (memcg&&  !mem_cgroup_test_flag(memcg,
> +	    MEMCG_INDEPENDENT_KMEM_LIMIT)) {
> +		ret = __mem_cgroup_try_charge(NULL, gfp, delta / PAGE_SIZE,
> +		&_memcg, may_oom);
> +		if (ret == -ENOMEM)
> +			return ret;
> +	}
> +
> +	if (memcg&&  _memcg == memcg)
> +		ret = res_counter_charge(&memcg->kmem, delta,&fail_res);
> +
> +	return ret;
> +}
> +
> +void
Ok.

So I've spent most of the day today trying to come up with a way not to 
kill the whole performance we gain from consume_stock() by this 
res_counter_charge() to kmem afterwards...

You mentioned you want to still be able to bill to memcg->kmem mostly 
for debugging/display purposes. So we're surely not using all of the 
res_counter infrastructure (limiting, soft limits, etc)

I was thinking: Can't we have a percpu_counter that we use for this 
purpose when !kmem_independent ?

we may not even need to bloat the struct, since we can fold it into a 
union with struct res_counter kmem (which is bigger than a percpu 
counter anyway).

We just need to be a bit more careful not to allow kmem_independent to 
change when we already have charges to any of them (but we need to do it 
anyway)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
