Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 79E3A6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 05:07:59 -0400 (EDT)
Received: by wijp11 with SMTP id p11so21736011wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:07:59 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id az6si17779867wib.48.2015.10.22.02.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 02:07:58 -0700 (PDT)
Received: by wijp11 with SMTP id p11so21735422wij.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 02:07:58 -0700 (PDT)
Date: Thu, 22 Oct 2015 11:07:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: eliminate root memory.current
Message-ID: <20151022090756.GB26854@dhcp22.suse.cz>
References: <1445453394-15156-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1445453394-15156-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

On Wed 21-10-15 14:49:54, Johannes Weiner wrote:
> memory.current on the root level doesn't add anything that wouldn't be
> more accurate and detailed using system statistics. It already doesn't
> include slabs, and it'll be a pain to keep in sync when further memory
> types are accounted in the memory controller. Remove it.
> 
> Note that this applies to the new unified hierarchy interface only.

OK, I can understand your reasoning, other knobs are !root as well.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

After the bug mentioned below is fixed
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Tejun, we should probably do this with the other controllers too.
> I don't think it makes sense anywhere to shoddily duplicate the
> system statistics on the controller root levels.
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4f04510..c71fe40 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5022,7 +5022,7 @@ static void mem_cgroup_bind(struct cgroup_subsys_state *root_css)
>  static u64 memory_current_read(struct cgroup_subsys_state *css,
>  			       struct cftype *cft)
>  {
> -	return mem_cgroup_usage(mem_cgroup_from_css(css), false);
> +	return page_counter_read(&mem_cgroup_from_css(css)->memory);

We want that in bytes though.

>  }
>  
>  static int memory_low_show(struct seq_file *m, void *v)
> @@ -5134,6 +5134,7 @@ static int memory_events_show(struct seq_file *m, void *v)
>  static struct cftype memory_files[] = {
>  	{
>  		.name = "current",
> +		.flags = CFTYPE_NOT_ON_ROOT,
>  		.read_u64 = memory_current_read,
>  	},
>  	{
> -- 
> 2.6.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
