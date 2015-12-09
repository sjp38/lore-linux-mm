Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 29C746B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 13:59:10 -0500 (EST)
Received: by wmww144 with SMTP id w144so235611621wmw.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 10:59:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 76si13836642wms.44.2015.12.09.10.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 10:59:08 -0800 (PST)
Date: Wed, 9 Dec 2015 13:58:58 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: only manage socket pressure for
 CONFIG_INET
Message-ID: <20151209185858.GA2342@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
 <2564892.qO1q7YJ6Nb@wuerfel>
 <7343206.sFybcLLUN2@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7343206.sFybcLLUN2@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 09, 2015 at 05:32:16PM +0100, Arnd Bergmann wrote:
> When IPV4 support is disabled, the memcg->socket_pressure field is
> not defined and we get a build error from the vmpressure code:
> 
> mm/vmpressure.c: In function 'vmpressure':
> mm/vmpressure.c:287:9: error: 'struct mem_cgroup' has no member named 'socket_pressure'
>     memcg->socket_pressure = jiffies + HZ;
> mm/built-in.o: In function `mem_cgroup_css_free':
> :(.text+0x1c03a): undefined reference to `tcp_destroy_cgroup'
> mm/built-in.o: In function `mem_cgroup_css_online':
> :(.text+0x1c20e): undefined reference to `tcp_init_cgroup'
> 
> This puts the code causing this in the same #ifdef that guards the
> struct member and the TCP implementation.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 20cc40e66c42 ("mm: memcontrol: hook up vmpressure to socket pressure")

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6faea81e66d7..73cd572167bb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4220,13 +4220,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
>  	if (ret)
>  		return ret;
>  
> +#ifdef CONFIG_INET
>  #ifdef CONFIG_MEMCG_LEGACY_KMEM
>  	ret = tcp_init_cgroup(memcg);
>  	if (ret)
>  		return ret;
>  #endif

The calls to tcp_init_cgroup() appear earlier in the series than "mm:
memcontrol: hook up vmpressure to socket pressure". However, they get
moved around a few times so fixing it earlier means respinning the
series. Andrew, it's up to you whether we take the bisectability hit
for !CONFIG_INET && CONFIG_MEMCG (how common is this?) or whether you
want me to resend the series.

Sorry about the trouble. I don't have a git tree on kernel.org because
we don't really use git in -mm, but the downside is that we don't get
the benefits of the automatic build testing for all kinds of configs.
I'll try to set up a git tree to expose series to full build coverage
before they hit -mm and -next.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
