Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CF2126B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:37:44 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so70888013wid.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:37:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id er3si1384025wib.114.2015.08.24.05.37.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:37:43 -0700 (PDT)
Subject: Re: [PATCH 04/12] mm, page_alloc: Only check cpusets when one exists
 that can be mem-controlled
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
 <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB1015.4080103@suse.cz>
Date: Mon, 24 Aug 2015 14:37:41 +0200
MIME-Version: 1.0
In-Reply-To: <1440418191-10894-5-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/24/2015 02:09 PM, Mel Gorman wrote:
> David Rientjes correctly pointed out that the "root cpuset may not exclude
> mems on the system so, even if mounted, there's no need to check or be
> worried about concurrent change when there is only one cpuset".
>
> The three checks for cpusets_enabled() care whether a cpuset exists that
> can limit memory, not that cpuset is enabled as such. This patch replaces
> cpusets_enabled() with cpusets_mems_enabled() which checks if at least one
> cpuset exists that can limit memory and updates the appropriate call sites.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>   include/linux/cpuset.h | 16 +++++++++-------
>   mm/page_alloc.c        |  2 +-
>   2 files changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 6eb27cb480b7..1e823870987e 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -17,10 +17,6 @@
>   #ifdef CONFIG_CPUSETS
>
>   extern struct static_key cpusets_enabled_key;
> -static inline bool cpusets_enabled(void)
> -{
> -	return static_key_false(&cpusets_enabled_key);
> -}
>
>   static inline int nr_cpusets(void)
>   {
> @@ -28,6 +24,12 @@ static inline int nr_cpusets(void)
>   	return static_key_count(&cpusets_enabled_key) + 1;
>   }
>
> +/* Returns true if a cpuset exists that can set cpuset.mems */
> +static inline bool cpusets_mems_enabled(void)
> +{
> +	return nr_cpusets() > 1;
> +}
> +

Hm, but this loses the benefits of static key branches?
How about something like:

   if (static_key_false(&cpusets_enabled_key))
	return nr_cpusets() > 1
   else
	return false;



>   static inline void cpuset_inc(void)
>   {
>   	static_key_slow_inc(&cpusets_enabled_key);
> @@ -104,7 +106,7 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
>    */
>   static inline unsigned int read_mems_allowed_begin(void)
>   {
> -	if (!cpusets_enabled())
> +	if (!cpusets_mems_enabled())
>   		return 0;
>
>   	return read_seqcount_begin(&current->mems_allowed_seq);
> @@ -118,7 +120,7 @@ static inline unsigned int read_mems_allowed_begin(void)
>    */
>   static inline bool read_mems_allowed_retry(unsigned int seq)
>   {
> -	if (!cpusets_enabled())
> +	if (!cpusets_mems_enabled())
>   		return false;

Actually I doubt it's much of benefit for these usages, even if the 
static key benefits are restored. If there's a single root cpuset, we 
would check the seqlock prior to this patch, now we'll check static key 
value (which should have the same cost?). With >1 cpusets, we would 
check seqlock prior to this patch, now we'll check static key value 
*and* the seqlock...

>
>   	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> @@ -139,7 +141,7 @@ static inline void set_mems_allowed(nodemask_t nodemask)
>
>   #else /* !CONFIG_CPUSETS */
>
> -static inline bool cpusets_enabled(void) { return false; }
> +static inline bool cpusets_mems_enabled(void) { return false; }
>
>   static inline int cpuset_init(void) { return 0; }
>   static inline void cpuset_init_smp(void) {}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 62ae28d8ae8d..2c1c3bf54d15 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2470,7 +2470,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
>   		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
>   			!zlc_zone_worth_trying(zonelist, z, allowednodes))
>   				continue;
> -		if (cpusets_enabled() &&
> +		if (cpusets_mems_enabled() &&
>   			(alloc_flags & ALLOC_CPUSET) &&
>   			!cpuset_zone_allowed(zone, gfp_mask))
>   				continue;

Here the benefits are less clear. I guess cpuset_zone_allowed() is 
potentially costly...

Heck, shouldn't we just start the static key on -1 (if possible), so 
that it's enabled only when there's 2+ cpusets?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
