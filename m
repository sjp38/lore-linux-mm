Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id B403890008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 04:27:17 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id w7so3852814lbi.10
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 01:27:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a4si10865749lbm.77.2014.10.30.01.27.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 01:27:15 -0700 (PDT)
Date: Thu, 30 Oct 2014 09:27:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030082712.GB4664@dhcp22.suse.cz>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, peterz@infradead.org, linux-mm@kvack.org

On Wed 29-10-14 21:44:24, Sasha Levin wrote:
> Commit "mm: memcontrol: fix missed end-writeback page accounting" has changed
> the behaviour of mem_cgroup_begin_page_stat() to not always set the "locked"
> parameter.
> 
> We should initialize it at the callers to prevent garbage being used in a
> later call to mem_cgroup_end_page_stat().

The contract is that if the returned memcg is non-NULL then the locked
is always initialized. Nobody but mem_cgroup_end_page_stat should touch
this variable and this function makes sure it uses it properly. Similar
applies to flags which is initialized only if we really take the slow
path (has a meaning only if locked == true).

So this is not really needed. Was this triggered by a compiler warning?

> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  mm/page-writeback.c |    4 ++--
>  mm/rmap.c           |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 19ceae8..7a02c97 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -2329,7 +2329,7 @@ int test_clear_page_writeback(struct page *page)
>  	struct address_space *mapping = page_mapping(page);
>  	unsigned long memcg_flags;
>  	struct mem_cgroup *memcg;
> -	bool locked;
> +	bool locked = false;
>  	int ret;
>  
>  	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
> @@ -2366,7 +2366,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
>  	struct address_space *mapping = page_mapping(page);
>  	unsigned long memcg_flags;
>  	struct mem_cgroup *memcg;
> -	bool locked;
> +	bool locked = false;
>  	int ret;
>  
>  	memcg = mem_cgroup_begin_page_stat(page, &locked, &memcg_flags);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 19886fb..4a4dc84 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1044,7 +1044,7 @@ void page_add_file_rmap(struct page *page)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned long flags;
> -	bool locked;
> +	bool locked = false;
>  
>  	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
>  	if (atomic_inc_and_test(&page->_mapcount)) {
> @@ -1058,7 +1058,7 @@ static void page_remove_file_rmap(struct page *page)
>  {
>  	struct mem_cgroup *memcg;
>  	unsigned long flags;
> -	bool locked;
> +	bool locked = false;
>  
>  	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
>  
> -- 
> 1.7.10.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
