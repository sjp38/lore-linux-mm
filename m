Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C236D9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:34:09 -0400 (EDT)
Received: by pacan13 with SMTP id an13so129091355pac.1
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:34:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fg4si46681334pdb.98.2015.07.21.16.34.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:34:08 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:34:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm v9 1/8] memcg: add page_cgroup_ino helper
Message-Id: <20150721163407.4e198dfcf61eebbbc49731c2@linux-foundation.org>
In-Reply-To: <aa0190b76489260b4d1b65cdfa65221f4e6390f5.1437303956.git.vdavydov@parallels.com>
References: <cover.1437303956.git.vdavydov@parallels.com>
	<aa0190b76489260b4d1b65cdfa65221f4e6390f5.1437303956.git.vdavydov@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, 19 Jul 2015 15:31:10 +0300 Vladimir Davydov <vdavydov@parallels.com> wrote:

> This function returns the inode number of the closest online ancestor of
> the memory cgroup a page is charged to. It is required for exporting
> information about which page is charged to which cgroup to userspace,
> which will be introduced by a following patch.
> 
> ...
>

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -441,6 +441,29 @@ struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
>  	return &memcg->css;
>  }
>  
> +/**
> + * page_cgroup_ino - return inode number of the memcg a page is charged to
> + * @page: the page
> + *
> + * Look up the closest online ancestor of the memory cgroup @page is charged to
> + * and return its inode number or 0 if @page is not charged to any cgroup. It
> + * is safe to call this function without holding a reference to @page.
> + */
> +unsigned long page_cgroup_ino(struct page *page)

Shouldn't it return an ino_t?

> +{
> +	struct mem_cgroup *memcg;
> +	unsigned long ino = 0;
> +
> +	rcu_read_lock();
> +	memcg = READ_ONCE(page->mem_cgroup);
> +	while (memcg && !(memcg->css.flags & CSS_ONLINE))
> +		memcg = parent_mem_cgroup(memcg);
> +	if (memcg)
> +		ino = cgroup_ino(memcg->css.cgroup);
> +	rcu_read_unlock();
> +	return ino;
> +}

The function is racy, isn't it?  There's nothing to prevent this inode
from getting torn down and potentially reallocated one nanosecond after
page_cgroup_ino() returns?  If so, it is only safely usable by things
which don't care (such as procfs interfaces) and this should be
documented in some fashion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
