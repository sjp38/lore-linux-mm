Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F3EFF6B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:39:22 -0400 (EDT)
Received: from huawei.com (szxga04-in [172.24.2.12])
 by szxga04-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M3Z001HHOKRPJ@szxga04-in.huawei.com> for
 linux-mm@kvack.org; Mon, 14 May 2012 09:38:51 +0800 (CST)
Received: from szxrg01-dlp.huawei.com ([172.24.2.119])
 by szxga04-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0M3Z003MOOKRY2@szxga04-in.huawei.com> for
 linux-mm@kvack.org; Mon, 14 May 2012 09:38:51 +0800 (CST)
Date: Mon, 14 May 2012 09:38:36 +0800
From: Li Zefan <lizefan@huawei.com>
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
In-reply-to: <1336767077-25351-3-git-send-email-glommer@parallels.com>
Message-id: <4FB0621C.3010604@huawei.com>
MIME-version: 1.0
Content-type: text/plain; charset=GB2312
Content-transfer-encoding: 7BIT
References: <1336767077-25351-1-git-send-email-glommer@parallels.com>
 <1336767077-25351-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

> +static void disarm_static_keys(struct mem_cgroup *memcg)

> +{
> +#ifdef CONFIG_INET
> +	if (memcg->tcp_mem.cg_proto.activated)
> +		static_key_slow_dec(&memcg_socket_limit_enabled);
> +#endif
> +}


Move this inside the ifdef/endif below ?

Otherwise I think you'll get compile error if !CONFIG_INET...

> +
>  #ifdef CONFIG_INET
>  struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>  {
> @@ -452,6 +462,11 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>  }
>  EXPORT_SYMBOL(tcp_proto_cgroup);
>  #endif /* CONFIG_INET */
> +#else
> +static inline void disarm_static_keys(struct mem_cgroup *memcg)
> +{
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
