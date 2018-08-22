Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 749BB6B24EF
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 10:58:51 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id g126-v6so1077821ywg.20
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 07:58:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a189-v6sor386750ywf.353.2018.08.22.07.58.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 07:58:50 -0700 (PDT)
Date: Wed, 22 Aug 2018 07:58:46 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 2/3] proc/kpagecgroup: report also inode numbers of
 offline cgroups
Message-ID: <20180822145846.GT3978217@devbig004.ftw2.facebook.com>
References: <153414348591.737150.14229960913953276515.stgit@buzz>
 <153414348994.737150.10057219558779418929.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153414348994.737150.10057219558779418929.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Mon, Aug 13, 2018 at 09:58:10AM +0300, Konstantin Khlebnikov wrote:
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 19a4348974a4..7ef6ea9d5e4a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -333,6 +333,7 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
>  /**
>   * page_cgroup_ino - return inode number of the memcg a page is charged to
>   * @page: the page
> + * @online: return closest online ancestor
>   *
>   * Look up the closest online ancestor of the memory cgroup @page is charged to
>   * and return its inode number or 0 if @page is not charged to any cgroup. It
> @@ -343,14 +344,14 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
>   * after page_cgroup_ino() returns, so it only should be used by callers that
>   * do not care (such as procfs interfaces).
>   */
> -ino_t page_cgroup_ino(struct page *page)
> +ino_t page_cgroup_ino(struct page *page, bool online)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned long ino = 0;
>  
>  	rcu_read_lock();
>  	memcg = READ_ONCE(page->mem_cgroup);
> -	while (memcg && !(memcg->css.flags & CSS_ONLINE))
> +	while (memcg && online && !(memcg->css.flags & CSS_ONLINE))
>  		memcg = parent_mem_cgroup(memcg);
>  	if (memcg)
>  		ino = cgroup_ino(memcg->css.cgroup);

We pin the ino till the cgroup is actually released now but that's an
implementation detail which may change in the future, so I'm not sure
this is a good idea.  Can you instead use the 64bit filehandle exposed
by kernfs?  That's currently also based on ino (+gen) but it's
something guarnateed to stay unique per cgroup and you can easily get
to the cgroup using the fh too.

Thanks.

-- 
tejun
