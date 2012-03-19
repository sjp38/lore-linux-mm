Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 0FFAB6B004D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 18:21:00 -0400 (EDT)
Received: by yhr47 with SMTP id 47so7577166yhr.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 15:20:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F66E7D7.4040406@jp.fujitsu.com>
References: <4F66E6A5.10804@jp.fujitsu.com>
	<4F66E7D7.4040406@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 15:20:55 -0700
Message-ID: <CABCjUKAr+F=Pz-JCWfjGfyL4AcHt6m97p13=0VdwjeVm5SKW7w@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/3] memcg: reduce size of struct page_cgroup.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

2012/3/19 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Now, page_cgroup->flags has only 3bits. Considering alignment of
> struct mem_cgroup, which is allocated by kmalloc(), we can encode
> pointer to mem_cgroup and flags into a word.
>
> After this patch, pc->flags is encoded as
>
> =A063 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2 =A0 =A0 0
> =A0| pointer to memcg..........|flags|
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0include/linux/page_cgroup.h | =A0 15 ++++++++++++---
> =A01 files changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 92768cb..bca5447 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -1,6 +1,10 @@
> =A0#ifndef __LINUX_PAGE_CGROUP_H
> =A0#define __LINUX_PAGE_CGROUP_H
>
> +/*
> + * Because these flags are encoded into ->flags with a pointer,
> + * we cannot have too much flags.
> + */
> =A0enum {
> =A0 =A0 =A0 =A0/* flags for mem_cgroup */
> =A0 =A0 =A0 =A0PCG_LOCK, =A0/* Lock for pc->mem_cgroup and following bits=
. */
> @@ -9,6 +13,8 @@ enum {
> =A0 =A0 =A0 =A0__NR_PCG_FLAGS,
> =A0};
>
> +#define PCG_FLAGS_MASK ((1 << __NR_PCG_FLAGS) - 1)
> +
> =A0#ifndef __GENERATING_BOUNDS_H
> =A0#include <generated/bounds.h>
>
> @@ -21,10 +27,12 @@ enum {
> =A0* page_cgroup helps us identify information about the cgroup
> =A0* All page cgroups are allocated at boot or memory hotplug event,
> =A0* then the page cgroup for pfn always exists.
> + *
> + * flags and a pointer to memory cgroup are encoded into ->flags.
> + * Lower 3bits are used for flags and others are used for a pointer to m=
emcg.

Would it be worth adding a BUILD_BUG_ON(__NR_PCG_FLAGS > 3) ?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
