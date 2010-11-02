Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E1BEE8D0001
	for <linux-mm@kvack.org>; Tue,  2 Nov 2010 01:07:59 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA250Ugk030050
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 01:00:30 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA257vOX350014
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 01:07:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA257u5W025710
	for <linux-mm@kvack.org>; Tue, 2 Nov 2010 03:07:57 -0200
Date: Tue, 2 Nov 2010 10:37:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] cgroup: prefer [kv]zalloc over [kv]malloc+memset in
 memory controller code.
Message-ID: <20101102050752.GG3769@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1011012038490.12889@swampdragon.chaosbits.net>
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

* Jesper Juhl <jj@chaosbits.net> [2010-11-01 20:40:56]:

> Hi (please CC me on replies),
> 
> 
> Apologies to those who receive this multiple times. I screwed up the To: 
> field in my original mail :-(
> 
> 
> In mem_cgroup_alloc() we currently do either kmalloc() or vmalloc() then 
> followed by memset() to zero the memory. This can be more efficiently 
> achieved by using kzalloc() and vzalloc().
> 
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> ---
>  memcontrol.c |    5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9a99cfa..90da698 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4199,14 +4199,13 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
> 
>  	/* Can be very big if MAX_NUMNODES is very big */
>  	if (size < PAGE_SIZE)
> -		mem = kmalloc(size, GFP_KERNEL);
> +		mem = kzalloc(size, GFP_KERNEL);
>  	else
> -		mem = vmalloc(size);
> +		mem = vzalloc(size);
> 
>  	if (!mem)
>  		return NULL;
> 
> -	memset(mem, 0, size);
>  	mem->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
>  	if (!mem->stat) {
>  		if (size < PAGE_SIZE)
>

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
