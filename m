Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id C79256B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 06:46:03 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so40441484wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:46:03 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id db8si4449889wjc.63.2015.08.26.03.46.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 03:46:02 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so40440831wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:46:01 -0700 (PDT)
Date: Wed, 26 Aug 2015 12:46:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists
 that can be mem-controlled
Message-ID: <20150826104559.GG25196@dhcp22.suse.cz>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 24-08-15 13:09:43, Mel Gorman wrote:
> David Rientjes correctly pointed out that the "root cpuset may not exclude
> mems on the system so, even if mounted, there's no need to check or be
> worried about concurrent change when there is only one cpuset".

Hmm, but cpuset_inc() is called only from cpuset_css_online and only
when it is called with non-NULL css->parent AFAICS. This means that the
static key should be still false after the root cpuset is created.

> The three checks for cpusets_enabled() care whether a cpuset exists that
> can limit memory, not that cpuset is enabled as such. This patch replaces
> cpusets_enabled() with cpusets_mems_enabled() which checks if at least one
> cpuset exists that can limit memory and updates the appropriate call sites.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/cpuset.h | 16 +++++++++-------
>  mm/page_alloc.c        |  2 +-
>  2 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 6eb27cb480b7..1e823870987e 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -17,10 +17,6 @@
>  #ifdef CONFIG_CPUSETS
>  
>  extern struct static_key cpusets_enabled_key;
> -static inline bool cpusets_enabled(void)
> -{
> -	return static_key_false(&cpusets_enabled_key);
> -}
>  
>  static inline int nr_cpusets(void)
>  {
> @@ -28,6 +24,12 @@ static inline int nr_cpusets(void)
>  	return static_key_count(&cpusets_enabled_key) + 1;
>  }
>  
> +/* Returns true if a cpuset exists that can set cpuset.mems */
> +static inline bool cpusets_mems_enabled(void)
> +{
> +	return nr_cpusets() > 1;
> +}
> +
>  static inline void cpuset_inc(void)
>  {
>  	static_key_slow_inc(&cpusets_enabled_key);
> @@ -104,7 +106,7 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>   */
>  static inline unsigned int read_mems_allowed_begin(void)
>  {
> -	if (!cpusets_enabled())
> +	if (!cpusets_mems_enabled())
>  		return 0;
>  
>  	return read_seqcount_begin(&current->mems_allowed_seq);
> @@ -118,7 +120,7 @@ static inline unsigned int read_mems_allowed_begin(void)
>   */
>  static inline bool read_mems_allowed_retry(unsigned int seq)
>  {
> -	if (!cpusets_enabled())
> +	if (!cpusets_mems_enabled())
>  		return false;
>  
>  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> @@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>  
>  #else /* !CONFIG_CPUSETS */
>  
> -static inline bool cpusets_enabled(void) { return false; }
> +static inline bool cpusets_mems_enabled(void) { return false; }
>  
>  static inline int cpuset_init(void) { return 0; }
>  static inline void cpuset_init_smp(void) {}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 62ae28d8ae8d..2c1c3bf54d15 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>  		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
>  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
>  				continue;
> -		if (cpusets_enabled() &&
> +		if (cpusets_mems_enabled() &&
>  			(alloc_flags & ALLOC_CPUSET) &&
>  			!cpuset_zone_allowed(zone, gfp_mask))
>  				continue;
> -- 
> 2.4.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
