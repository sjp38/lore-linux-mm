Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C66B26B0003
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 21:51:50 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id o64so41071784pfb.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 18:51:50 -0800 (PST)
Received: from mgwkm02.jp.fujitsu.com (mgwkm02.jp.fujitsu.com. [202.219.69.169])
        by mx.google.com with ESMTPS id 3si16542084pfj.94.2015.12.17.18.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 18:51:50 -0800 (PST)
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id E89E7AC0115
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 11:51:45 +0900 (JST)
Subject: Re: [PATCH v2 7/7] Documentation: cgroup: add
 memory.swap.{current,max} description
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
 <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <567374AB.3010101@jp.fujitsu.com>
Date: Fri, 18 Dec 2015 11:51:23 +0900
MIME-Version: 1.0
In-Reply-To: <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 2015/12/17 21:30, Vladimir Davydov wrote:
> The rationale of separate swap counter is given by Johannes Weiner.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
> ---
> Changes in v2:
>   - Add rationale of separate swap counter provided by Johannes.
> 
>   Documentation/cgroup.txt | 33 +++++++++++++++++++++++++++++++++
>   1 file changed, 33 insertions(+)
> 
> diff --git a/Documentation/cgroup.txt b/Documentation/cgroup.txt
> index 31d1f7bf12a1..f441564023e1 100644
> --- a/Documentation/cgroup.txt
> +++ b/Documentation/cgroup.txt
> @@ -819,6 +819,22 @@ PAGE_SIZE multiple when read back.
>   		the cgroup.  This may not exactly match the number of
>   		processes killed but should generally be close.
>   
> +  memory.swap.current
> +
> +	A read-only single value file which exists on non-root
> +	cgroups.
> +
> +	The total amount of swap currently being used by the cgroup
> +	and its descendants.
> +
> +  memory.swap.max
> +
> +	A read-write single value file which exists on non-root
> +	cgroups.  The default is "max".
> +
> +	Swap usage hard limit.  If a cgroup's swap usage reaches this
> +	limit, anonymous meomry of the cgroup will not be swapped out.
> +
>   
>   5-2-2. General Usage
>   
> @@ -1291,3 +1307,20 @@ allocation from the slack available in other groups or the rest of the
>   system than killing the group.  Otherwise, memory.max is there to
>   limit this type of spillover and ultimately contain buggy or even
>   malicious applications.
> +
> +The combined memory+swap accounting and limiting is replaced by real
> +control over swap space.
> +
> +The main argument for a combined memory+swap facility in the original
> +cgroup design was that global or parental pressure would always be
> +able to swap all anonymous memory of a child group, regardless of the
> +child's own (possibly untrusted) configuration.  However, untrusted
> +groups can sabotage swapping by other means - such as referencing its
> +anonymous memory in a tight loop - and an admin can not assume full
> +swappability when overcommitting untrusted jobs.
> +
> +For trusted jobs, on the other hand, a combined counter is not an
> +intuitive userspace interface, and it flies in the face of the idea
> +that cgroup controllers should account and limit specific physical
> +resources.  Swap space is a resource like all others in the system,
> +and that's why unified hierarchy allows distributing it separately.
> 
Could you give here a hint how to calculate amount of swapcache,
counted both in memory.current and swap.current ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
