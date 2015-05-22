Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D0D4782A14
	for <linux-mm@kvack.org>; Fri, 22 May 2015 19:29:13 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so2094945wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 16:29:13 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v9si446167wib.90.2015.05.22.16.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 16:29:12 -0700 (PDT)
Date: Fri, 22 May 2015 19:28:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 11/51] memcg: implement mem_cgroup_css_from_page()
Message-ID: <20150522232831.GB6485@cmpxchg.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-12-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432329245-5844-12-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Fri, May 22, 2015 at 05:13:25PM -0400, Tejun Heo wrote:
> +/**
> + * mem_cgroup_css_from_page - css of the memcg associated with a page
> + * @page: page of interest
> + *
> + * This function is guaranteed to return a valid cgroup_subsys_state and
> + * the returned css remains accessible until @page is released.
> + */
> +struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page)
> +{
> +	if (page->mem_cgroup)
> +		return &page->mem_cgroup->css;
> +	return &root_mem_cgroup->css;
> +}

replace_page_cache() can clear page->mem_cgroup even when the page
still has references, so unfortunately you must hold the page lock
when calling this function.

I haven't checked how you use this - chances are you always have the
page locked anyways - but it probably needs a comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
