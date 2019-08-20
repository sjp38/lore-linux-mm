Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 024CEC3A59E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9C7B20644
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:46:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C7B20644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E0FF6B0007; Tue, 20 Aug 2019 04:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4922E6B0008; Tue, 20 Aug 2019 04:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A6246B000A; Tue, 20 Aug 2019 04:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0141.hostedemail.com [216.40.44.141])
	by kanga.kvack.org (Postfix) with ESMTP id 14CEC6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:46:22 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id AB2398248AB6
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:46:21 +0000 (UTC)
X-FDA: 75842174562.23.wave79_71a3619212e08
X-HE-Tag: wave79_71a3619212e08
X-Filterd-Recvd-Size: 17486
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:46:20 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D59E3AC26;
	Tue, 20 Aug 2019 08:46:18 +0000 (UTC)
Subject: Re: [RFC] mm: Proactive compaction
To: Nitin Gupta <nigupta@nvidia.com>, akpm@linux-foundation.org,
 mgorman@techsingularity.net, mhocko@suse.com, dan.j.williams@intel.com
Cc: Yu Zhao <yuzhao@google.com>, Matthew Wilcox <willy@infradead.org>,
 Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Roman Gushchin <guro@fb.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Arun KS <arunks@codeaurora.org>, Janne Huttunen <janne.huttunen@nokia.com>,
 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Khalid Aziz <khalid.aziz@oracle.com>
References: <20190816214413.15006-1-nigupta@nvidia.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <87634ddc-8bfd-8311-46c4-35f7dc32d42f@suse.cz>
Date: Tue, 20 Aug 2019 10:46:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190816214413.15006-1-nigupta@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+CC Khalid Aziz who proposed a different approach:
https://lore.kernel.org/linux-mm/20190813014012.30232-1-khalid.aziz@oracle.com/T/#u

On 8/16/19 11:43 PM, Nitin Gupta wrote:
> For some applications we need to allocate almost all memory as
> hugepages. However, on a running system, higher order allocations can
> fail if the memory is fragmented. Linux kernel currently does
> on-demand compaction as we request more hugepages but this style of
> compaction incurs very high latency. Experiments with one-time full
> memory compaction (followed by hugepage allocations) shows that kernel
> is able to restore a highly fragmented memory state to a fairly
> compacted memory state within <1 sec for a 32G system. Such data
> suggests that a more proactive compaction can help us allocate a large
> fraction of memory as hugepages keeping allocation latencies low.
> 
> For a more proactive compaction, the approach taken here is to define
> per page-order external fragmentation thresholds and let kcompactd
> threads act on these thresholds.
> 
> The low and high thresholds are defined per page-order and exposed
> through sysfs:
> 
>   /sys/kernel/mm/compaction/order-[1..MAX_ORDER]/extfrag_{low,high}
> 
> Per-node kcompactd thread is woken up every few seconds to check if
> any zone on its node has extfrag above the extfrag_high threshold for
> any order, in which case the thread starts compaction in the backgrond
> till all zones are below extfrag_low level for all orders. By default
> both these thresolds are set to 100 for all orders which essentially
> disables kcompactd.

Could you define what exactly extfrag is, in the changelog?

> To avoid wasting CPU cycles when compaction cannot help, such as when
> memory is full, we check both, extfrag > extfrag_high and
> compaction_suitable(zone). This allows kcomapctd thread to stays inactive
> even if extfrag thresholds are not met.

How does it translate to e.g. the number of free pages of order?

> This patch is largely based on ideas from Michal Hocko posted here:
> https://lore.kernel.org/linux-mm/20161230131412.GI13301@dhcp22.suse.cz/
> 
> Testing done (on x86):
>  - Set /sys/kernel/mm/compaction/order-9/extfrag_{low,high} = {25, 30}
>  respectively.
>  - Use a test program to fragment memory: the program allocates all memory
>  and then for each 2M aligned section, frees 3/4 of base pages using
>  munmap.
>  - kcompactd0 detects fragmentation for order-9 > extfrag_high and starts
>  compaction till extfrag < extfrag_low for order-9.
> 
> The patch has plenty of rough edges but posting it early to see if I'm
> going in the right direction and to get some early feedback.

That's a lot of control knobs - how is an admin supposed to tune them to their
needs?

(keeping the rest for reference)

> Signed-off-by: Nitin Gupta <nigupta@nvidia.com>
> ---
>  include/linux/compaction.h |  12 ++
>  mm/compaction.c            | 250 ++++++++++++++++++++++++++++++-------
>  mm/vmstat.c                |  12 ++
>  3 files changed, 228 insertions(+), 46 deletions(-)
> 
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index 9569e7c786d3..26bfedbbc64b 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -60,6 +60,17 @@ enum compact_result {
>  
>  struct alloc_context; /* in mm/internal.h */
>  
> +// "order-%d"
> +#define COMPACTION_ORDER_STATE_NAME_LEN 16
> +// Per-order compaction state
> +struct compaction_order_state {
> +	unsigned int order;
> +	unsigned int extfrag_low;
> +	unsigned int extfrag_high;
> +	unsigned int extfrag_curr;
> +	char name[COMPACTION_ORDER_STATE_NAME_LEN];
> +};
> +
>  /*
>   * Number of free order-0 pages that should be available above given watermark
>   * to make sure compaction has reasonable chance of not running out of free
> @@ -90,6 +101,7 @@ extern int sysctl_compaction_handler(struct ctl_table *table, int write,
>  extern int sysctl_extfrag_threshold;
>  extern int sysctl_compact_unevictable_allowed;
>  
> +extern int extfrag_for_order(struct zone *zone, unsigned int order);
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
>  		unsigned int order, unsigned int alloc_flags,
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 952dc2fb24e5..21866b1ad249 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -25,6 +25,10 @@
>  #include <linux/psi.h>
>  #include "internal.h"
>  
> +#ifdef CONFIG_COMPACTION
> +struct compaction_order_state compaction_order_states[MAX_ORDER+1];
> +#endif
> +
>  #ifdef CONFIG_COMPACTION
>  static inline void count_compact_event(enum vm_event_item item)
>  {
> @@ -1846,6 +1850,49 @@ static inline bool is_via_compact_memory(int order)
>  	return order == -1;
>  }
>  
> +static int extfrag_wmark_high(struct zone *zone)
> +{
> +	int order;
> +
> +	for (order = 1; order <= MAX_ORDER; order++) {
> +		int extfrag = extfrag_for_order(zone, order);
> +		int threshold = compaction_order_states[order].extfrag_high;
> +
> +		if (extfrag > threshold)
> +			return order;
> +	}
> +	return 0;
> +}
> +
> +static bool node_should_compact(pg_data_t *pgdat)
> +{
> +	struct zone *zone;
> +
> +	for_each_populated_zone(zone) {
> +		int order = extfrag_wmark_high(zone);
> +
> +		if (order && compaction_suitable(zone, order,
> +				0, zone_idx(zone)) == COMPACT_CONTINUE) {
> +			return true;
> +		}
> +	}
> +	return false;
> +}
> +
> +static int extfrag_wmark_low(struct zone *zone)
> +{
> +	int order;
> +
> +	for (order = 1; order <= MAX_ORDER; order++) {
> +		int extfrag = extfrag_for_order(zone, order);
> +		int threshold = compaction_order_states[order].extfrag_low;
> +
> +		if (extfrag > threshold)
> +			return order;
> +	}
> +	return 0;
> +}
> +
>  static enum compact_result __compact_finished(struct compact_control *cc)
>  {
>  	unsigned int order;
> @@ -1872,7 +1919,7 @@ static enum compact_result __compact_finished(struct compact_control *cc)
>  			return COMPACT_PARTIAL_SKIPPED;
>  	}
>  
> -	if (is_via_compact_memory(cc->order))
> +	if (extfrag_wmark_low(cc->zone))
>  		return COMPACT_CONTINUE;
>  
>  	/*
> @@ -1962,18 +2009,6 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
>  {
>  	unsigned long watermark;
>  
> -	if (is_via_compact_memory(order))
> -		return COMPACT_CONTINUE;
> -
> -	watermark = wmark_pages(zone, alloc_flags & ALLOC_WMARK_MASK);
> -	/*
> -	 * If watermarks for high-order allocation are already met, there
> -	 * should be no need for compaction at all.
> -	 */
> -	if (zone_watermark_ok(zone, order, watermark, classzone_idx,
> -								alloc_flags))
> -		return COMPACT_SUCCESS;
> -
>  	/*
>  	 * Watermarks for order-0 must be met for compaction to be able to
>  	 * isolate free pages for migration targets. This means that the
> @@ -2003,31 +2038,9 @@ enum compact_result compaction_suitable(struct zone *zone, int order,
>  					int classzone_idx)
>  {
>  	enum compact_result ret;
> -	int fragindex;
>  
>  	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx,
>  				    zone_page_state(zone, NR_FREE_PAGES));
> -	/*
> -	 * fragmentation index determines if allocation failures are due to
> -	 * low memory or external fragmentation
> -	 *
> -	 * index of -1000 would imply allocations might succeed depending on
> -	 * watermarks, but we already failed the high-order watermark check
> -	 * index towards 0 implies failure is due to lack of memory
> -	 * index towards 1000 implies failure is due to fragmentation
> -	 *
> -	 * Only compact if a failure would be due to fragmentation. Also
> -	 * ignore fragindex for non-costly orders where the alternative to
> -	 * a successful reclaim/compaction is OOM. Fragindex and the
> -	 * vm.extfrag_threshold sysctl is meant as a heuristic to prevent
> -	 * excessive compaction for costly orders, but it should not be at the
> -	 * expense of system stability.
> -	 */
> -	if (ret == COMPACT_CONTINUE && (order > PAGE_ALLOC_COSTLY_ORDER)) {
> -		fragindex = fragmentation_index(zone, order);
> -		if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
> -			ret = COMPACT_NOT_SUITABLE_ZONE;
> -	}
>  
>  	trace_mm_compaction_suitable(zone, order, ret);
>  	if (ret == COMPACT_NOT_SUITABLE_ZONE)
> @@ -2416,7 +2429,6 @@ static void compact_node(int nid)
>  		.gfp_mask = GFP_KERNEL,
>  	};
>  
> -
>  	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
>  
>  		zone = &pgdat->node_zones[zoneid];
> @@ -2493,9 +2505,149 @@ void compaction_unregister_node(struct node *node)
>  }
>  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
>  
> +#ifdef CONFIG_SYSFS
> +
> +#define COMPACTION_ATTR_RO(_name) \
> +	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
> +
> +#define COMPACTION_ATTR(_name) \
> +	static struct kobj_attribute _name##_attr = \
> +		__ATTR(_name, 0644, _name##_show, _name##_store)
> +
> +static struct kobject *compaction_kobj;
> +static struct kobject *compaction_order_kobjs[MAX_ORDER];
> +
> +static struct compaction_order_state *kobj_to_compaction_order_state(
> +						struct kobject *kobj)
> +{
> +	int i;
> +
> +	for (i = 1; i <= MAX_ORDER; i++) {
> +		if (compaction_order_kobjs[i] == kobj)
> +			return &compaction_order_states[i];
> +	}
> +
> +	return NULL;
> +}
> +
> +static ssize_t extfrag_store_common(bool is_low, struct kobject *kobj,
> +		struct kobj_attribute *attr, const char *buf, size_t count)
> +{
> +	int err;
> +	unsigned long input;
> +	struct compaction_order_state *c = kobj_to_compaction_order_state(kobj);
> +
> +	err = kstrtoul(buf, 10, &input);
> +	if (err)
> +		return err;
> +	if (input > 100)
> +		return -EINVAL;
> +
> +	if (is_low)
> +		c->extfrag_low = input;
> +	else
> +		c->extfrag_high = input;
> +
> +	return count;
> +}
> +
> +static ssize_t extfrag_low_show(struct kobject *kobj,
> +		struct kobj_attribute *attr, char *buf)
> +{
> +	struct compaction_order_state *c = kobj_to_compaction_order_state(kobj);
> +
> +	return sprintf(buf, "%u\n", c->extfrag_low);
> +}
> +
> +static ssize_t extfrag_low_store(struct kobject *kobj,
> +		struct kobj_attribute *attr, const char *buf, size_t count)
> +{
> +	return extfrag_store_common(true, kobj, attr, buf, count);
> +}
> +COMPACTION_ATTR(extfrag_low);
> +
> +static ssize_t extfrag_high_show(struct kobject *kobj,
> +					struct kobj_attribute *attr, char *buf)
> +{
> +	struct compaction_order_state *c = kobj_to_compaction_order_state(kobj);
> +
> +	return sprintf(buf, "%u\n", c->extfrag_high);
> +}
> +
> +static ssize_t extfrag_high_store(struct kobject *kobj,
> +		struct kobj_attribute *attr, const char *buf, size_t count)
> +{
> +	return extfrag_store_common(false, kobj, attr, buf, count);
> +}
> +COMPACTION_ATTR(extfrag_high);
> +
> +static struct attribute *compaction_order_attrs[] = {
> +	&extfrag_low_attr.attr,
> +	&extfrag_high_attr.attr,
> +	NULL,
> +};
> +
> +static const struct attribute_group compaction_order_attr_group = {
> +	.attrs = compaction_order_attrs,
> +};
> +
> +static int compaction_sysfs_add_order(struct compaction_order_state *c,
> +	struct kobject *parent, struct kobject **compaction_order_kobjs,
> +	const struct attribute_group *compaction_order_attr_group)
> +{
> +	int retval;
> +
> +	compaction_order_kobjs[c->order] =
> +			kobject_create_and_add(c->name, parent);
> +	if (!compaction_order_kobjs[c->order])
> +		return -ENOMEM;
> +
> +	retval = sysfs_create_group(compaction_order_kobjs[c->order],
> +				compaction_order_attr_group);
> +	if (retval)
> +		kobject_put(compaction_order_kobjs[c->order]);
> +
> +	return retval;
> +}
> +
> +static void __init compaction_sysfs_init(void)
> +{
> +	struct compaction_order_state *c;
> +	int i, err;
> +
> +	compaction_kobj = kobject_create_and_add("compaction", mm_kobj);
> +	if (!compaction_kobj)
> +		return;
> +
> +	for (i = 1; i <= MAX_ORDER; i++) {
> +		c = &compaction_order_states[i];
> +		err = compaction_sysfs_add_order(c, compaction_kobj,
> +					compaction_order_kobjs,
> +					&compaction_order_attr_group);
> +		if (err)
> +			pr_err("compaction: Unable to add state %s", c->name);
> +	}
> +}
> +
> +static void __init compaction_init_order_states(void)
> +{
> +	int i;
> +
> +	for (i = 0; i <= MAX_ORDER; i++) {
> +		struct compaction_order_state *c = &compaction_order_states[i];
> +
> +		c->order = i;
> +		c->extfrag_low = 100;
> +		c->extfrag_high = 100;
> +		snprintf(c->name, COMPACTION_ORDER_STATE_NAME_LEN,
> +						"order-%d", i);
> +	}
> +}
> +#endif
> +
>  static inline bool kcompactd_work_requested(pg_data_t *pgdat)
>  {
> -	return pgdat->kcompactd_max_order > 0 || kthread_should_stop();
> +	return kthread_should_stop() || node_should_compact(pgdat);
>  }
>  
>  static bool kcompactd_node_suitable(pg_data_t *pgdat)
> @@ -2527,15 +2679,16 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  	int zoneid;
>  	struct zone *zone;
>  	struct compact_control cc = {
> -		.order = pgdat->kcompactd_max_order,
> -		.search_order = pgdat->kcompactd_max_order,
> +		.order = -1,
>  		.total_migrate_scanned = 0,
>  		.total_free_scanned = 0,
> -		.classzone_idx = pgdat->kcompactd_classzone_idx,
> -		.mode = MIGRATE_SYNC_LIGHT,
> -		.ignore_skip_hint = false,
> +		.mode = MIGRATE_SYNC,
> +		.ignore_skip_hint = true,
> +		.whole_zone = false,
>  		.gfp_mask = GFP_KERNEL,
> +		.classzone_idx = MAX_NR_ZONES - 1,
>  	};
> +
>  	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
>  							cc.classzone_idx);
>  	count_compact_event(KCOMPACTD_WAKE);
> @@ -2565,7 +2718,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
>  		if (kthread_should_stop())
>  			return;
>  		status = compact_zone(&cc, NULL);
> -
>  		if (status == COMPACT_SUCCESS) {
>  			compaction_defer_reset(zone, cc.order, false);
>  		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
> @@ -2650,11 +2802,14 @@ static int kcompactd(void *p)
>  	pgdat->kcompactd_classzone_idx = pgdat->nr_zones - 1;
>  
>  	while (!kthread_should_stop()) {
> -		unsigned long pflags;
> +		unsigned long ret, pflags;
>  
>  		trace_mm_compaction_kcompactd_sleep(pgdat->node_id);
> -		wait_event_freezable(pgdat->kcompactd_wait,
> -				kcompactd_work_requested(pgdat));
> +		ret = wait_event_freezable_timeout(pgdat->kcompactd_wait,
> +				kcompactd_work_requested(pgdat),
> +				msecs_to_jiffies(5000));
> +		if (!ret)
> +			continue;
>  
>  		psi_memstall_enter(&pflags);
>  		kcompactd_do_work(pgdat);
> @@ -2735,6 +2890,9 @@ static int __init kcompactd_init(void)
>  		return ret;
>  	}
>  
> +	compaction_init_order_states();
> +	compaction_sysfs_init();
> +
>  	for_each_node_state(nid, N_MEMORY)
>  		kcompactd_run(nid);
>  	return 0;
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index fd7e16ca6996..e9090a5595d1 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1074,6 +1074,18 @@ static int __fragmentation_index(unsigned int order, struct contig_page_info *in
>  	return 1000 - div_u64( (1000+(div_u64(info->free_pages * 1000ULL, requested))), info->free_blocks_total);
>  }
>  
> +int extfrag_for_order(struct zone *zone, unsigned int order)
> +{
> +	struct contig_page_info info;
> +
> +	fill_contig_page_info(zone, order, &info);
> +	if (info.free_pages == 0)
> +		return 0;
> +
> +	return (info.free_pages - (info.free_blocks_suitable << order)) * 100
> +							/ info.free_pages;
> +}
> +
>  /* Same as __fragmentation index but allocs contig_page_info on stack */
>  int fragmentation_index(struct zone *zone, unsigned int order)
>  {
> 


