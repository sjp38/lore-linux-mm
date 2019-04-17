Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1B50C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:45:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DD662073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DD662073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C1EB6B0003; Wed, 17 Apr 2019 04:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 24CD36B0006; Wed, 17 Apr 2019 04:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 114DC6B0007; Wed, 17 Apr 2019 04:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ACD346B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:45:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k56so6559899edb.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dCrhRTdF0TpnqBqvPQKWMnJHmwIFF89c1I/Yqm2jEm0=;
        b=iKrWxSmN8U1CWlPEvMDdHlorlZPDMnqzU+fF0gSiDH/laKl5xyyTzJikDmA5koB4xb
         2ikiP36HwqMQ4ndzjUTCOTOqcJO4dkCjG36fmkwPR+ps0vItyyDOfcTOi/Kde9Lz40we
         fjfncdTbuypjfjOllmp3VcmwBOvtsxpYDMjg9K3RQX8qm0+K7JD3fb1gwfnLtlD7v843
         BFx0YheY/aZN1gD8bxWB3orWYe0ZvaqwShnbEoPMM9Lc9F2FYvlykw4nRuw1VjDVuCWv
         MqHki3B//ZLjhH1qhLr/Kgi9LUlyWVLeIXhTQ6KFY1+ojC6JcDEYfb8DeVk58uylmpil
         2CLw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXyf+OTnuSc5ARLntkRRKeSAfEz+iEMWdwNzJIiJgaY6+S1cb3D
	tTKQZh9C47B5ouode9J5EgkUBwckY5xEQvo1NUJtIgJeTwS3yn+esO5dTErx1Kkm/jmPimkwqLP
	YIJCXjz5SM3ELQEAkTZRx1fXBYZHfR6QUGEYftL0CGiJJQpWQfXUIer2sy+1z5Rs=
X-Received: by 2002:aa7:d908:: with SMTP id a8mr10430743edr.68.1555490705216;
        Wed, 17 Apr 2019 01:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/EJbnAIqviPnzRySpRuEjsc5CA5yOM0pMI2pfLHfUjod2XivPnwPApejy7hrSZtDJ65FU
X-Received: by 2002:aa7:d908:: with SMTP id a8mr10430692edr.68.1555490704235;
        Wed, 17 Apr 2019 01:45:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555490704; cv=none;
        d=google.com; s=arc-20160816;
        b=DjLsjD3vV6v8qoO95kgZV433HNdRERv5W05XFhPwwxklT8K+M68srJ685+h/qsAgFs
         C4d0/q01Us0SZzG6gDzu/KRNke0ZscYuAnDeLwGF86KGYOhCPIAFzMFMKRtT4KXfsUKO
         2RVk+2rBzoWCcl5YU8d1jV0aahnDftZp73ncQI2vPBolMy+G6Du7wf0sMKaxvedXTJRv
         9zbpOIybRuA+zDqZ2VayBABxV8JH0YuObolpxKbs+R4n2JQKNcOsF6wBhpDbKaA8kfIa
         JHaZ8eQ+HwWh0jh4XzhGSAMzJ94a4ijK7Q3Gnz6DIwmY7z1YVL1z04iPumc8dLmFQwn0
         WMjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dCrhRTdF0TpnqBqvPQKWMnJHmwIFF89c1I/Yqm2jEm0=;
        b=XCb22L2/l2g9AhJC/at/OQ5D6yaFpGvJ5ON2TL6D+LyimmE1iC0kW74FIO/QdACMSV
         rcfBpWN+7ArToesmytKiGRTo+0mvZF6cVnZ9trFWAqQrq2eNCW0y2Ds0IHbdU15ecd5R
         413FulloaaFcJuQZ1W/nvOThKDwzQLngzkgV5MMhxWV0z+6t8WtcH0eiCtmnMnSp4Dut
         sqvfwQN+uE9Jw15W3aUZSKmTa5xyl1eiAh472crGaB6ovPNrj9LLeb7jrgdrD50mwY0c
         XnzgYoKS1H7xmUq8fyT2MionC6HFSbE/bJH+JaGffhwL5Z/i1uXgpnOoL0XSSHil7rON
         gfgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si995545ejr.336.2019.04.17.01.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:45:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 87F9CB11E;
	Wed, 17 Apr 2019 08:45:03 +0000 (UTC)
Date: Wed, 17 Apr 2019 10:45:01 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm/workingset : judge file page activity via
 timestamp
Message-ID: <20190417084501.GE655@dhcp22.suse.cz>
References: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1555487246-15764-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I do not see http://lkml.kernel.org/r/1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com
discussion reaching a conlusion to change the current workingset
implementation. Therefore is there any reason to post a new version of
the patch? If yes it would be really great to see a short summary about
how this version is different from the previous one and how all the
review feedback has been addressed.

On Wed 17-04-19 15:47:26, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> This patch introduce timestamp into workingset's entry and judge if the page
> is active or inactive via active_file/refault_ratio instead of refault distance.
> 
> The original thought is coming from the logs we got from trace_printk in this
> patch, we can find about 1/5 of the file pages' refault are under the
> scenario[1],which will be counted as inactive as they have a long refault distance
> in between access. However, we can also know from the time information that the
> page refault quickly as comparing to the average refault time which is calculated
> by the number of active file and refault ratio. We want to save these kinds of
> pages from evicted earlier as it used to be. The refault ratio is the value
> which can reflect lru's average file access frequency and also can be deemed as a
> prediction of future.
> 
> The patch is tested on an android system and reduce 30% of page faults, while
> 60% of the pages remain the original status as (refault_distance < active_file)
> indicates. Pages status got from ftrace during the test can refer to [2].
> 
> [1]
> system_server workingset_refault: WKST_ACT[0]:rft_dis 265976, act_file 34268 rft_ratio 3047 rft_time 0 avg_rft_time 11 refault 295592 eviction 29616 secs 97 pre_secs 97
> HwBinder:922  workingset_refault: WKST_ACT[0]:rft_dis 264478, act_file 35037 rft_ratio 3070 rft_time 2 avg_rft_time 11 refault 310078 eviction 45600 secs 101 pre_secs 99
> 
> [2]
> WKST_ACT[0]:   original--INACTIVE  commit--ACTIVE
> WKST_ACT[1]:   original--ACTIVE    commit--ACTIVE
> WKST_INACT[0]: original--INACTIVE  commit--INACTIVE
> WKST_INACT[1]: original--ACTIVE    commit--INACTIVE
> 
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  include/linux/mmzone.h |   1 +
>  mm/workingset.c        | 120 +++++++++++++++++++++++++++++++++++++++++++++----
>  2 files changed, 112 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2..6f30673 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -240,6 +240,7 @@ struct lruvec {
>  	atomic_long_t			inactive_age;
>  	/* Refaults at the time of last reclaim cycle */
>  	unsigned long			refaults;
> +	atomic_long_t			refaults_ratio;
>  #ifdef CONFIG_MEMCG
>  	struct pglist_data *pgdat;
>  #endif
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 40ee02c..66c177b 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -160,6 +160,21 @@
>  			 MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
>  
> +#ifdef CONFIG_64BIT
> +#define EVICTION_SECS_POS_SHIFT 20
> +#define EVICTION_SECS_SHRINK_SHIFT 4
> +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> +#else
> +#ifndef CONFIG_MEMCG
> +#define EVICTION_SECS_POS_SHIFT 12
> +#define EVICTION_SECS_SHRINK_SHIFT 4
> +#define EVICTION_SECS_POS_MASK  ((1UL << EVICTION_SECS_POS_SHIFT) - 1)
> +#else
> +#define EVICTION_SECS_POS_SHIFT 0
> +#define EVICTION_SECS_SHRINK_SHIFT 0
> +#define NO_SECS_IN_WORKINGSET
> +#endif
> +#endif
>  /*
>   * Eviction timestamps need to be able to cover the full range of
>   * actionable refaults. However, bits are tight in the radix tree
> @@ -169,10 +184,54 @@
>   * evictions into coarser buckets by shaving off lower timestamp bits.
>   */
>  static unsigned int bucket_order __read_mostly;
> -
> +#ifdef NO_SECS_IN_WORKINGSET
> +static void pack_secs(unsigned long *peviction) { }
> +static unsigned int unpack_secs(unsigned long entry) {return 0; }
> +#else
> +/*
> + * Shrink the timestamp according to its value and store it together
> + * with the shrink size in the entry.
> + */
> +static void pack_secs(unsigned long *peviction)
> +{
> +	unsigned int secs;
> +	unsigned long eviction;
> +	int order;
> +	int secs_shrink_size;
> +	struct timespec ts;
> +
> +	get_monotonic_boottime(&ts);
> +	secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
> +	order = get_count_order(secs);
> +	secs_shrink_size = (order <= EVICTION_SECS_POS_SHIFT)
> +			? 0 : (order - EVICTION_SECS_POS_SHIFT);
> +
> +	eviction = *peviction;
> +	eviction = (eviction << EVICTION_SECS_POS_SHIFT)
> +			| ((secs >> secs_shrink_size) & EVICTION_SECS_POS_MASK);
> +	eviction = (eviction << EVICTION_SECS_SHRINK_SHIFT) | (secs_shrink_size & 0xf);
> +	*peviction = eviction;
> +}
> +/*
> + * Unpack the second from the entry and restore the value according to the
> + * shrink size.
> + */
> +static unsigned int unpack_secs(unsigned long entry)
> +{
> +	unsigned int secs;
> +	int secs_shrink_size;
> +
> +	secs_shrink_size = entry & ((1 << EVICTION_SECS_SHRINK_SHIFT) - 1);
> +	entry >>= EVICTION_SECS_SHRINK_SHIFT;
> +	secs = entry & EVICTION_SECS_POS_MASK;
> +	secs = secs << secs_shrink_size;
> +	return secs;
> +}
> +#endif
>  static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  {
>  	eviction >>= bucket_order;
> +	pack_secs(&eviction);
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>  	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
> @@ -181,20 +240,24 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  }
>  
>  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> -			  unsigned long *evictionp)
> +			  unsigned long *evictionp, unsigned int *prev_secs)
>  {
>  	unsigned long entry = (unsigned long)shadow;
>  	int memcgid, nid;
> +	unsigned int secs;
>  
>  	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
>  	nid = entry & ((1UL << NODES_SHIFT) - 1);
>  	entry >>= NODES_SHIFT;
>  	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
>  	entry >>= MEM_CGROUP_ID_SHIFT;
> +	secs = unpack_secs(entry);
> +	entry >>= (EVICTION_SECS_POS_SHIFT + EVICTION_SECS_SHRINK_SHIFT);
>  
>  	*memcgidp = memcgid;
>  	*pgdat = NODE_DATA(nid);
>  	*evictionp = entry << bucket_order;
> +	*prev_secs = secs;
>  }
>  
>  /**
> @@ -242,9 +305,22 @@ bool workingset_refault(void *shadow)
>  	unsigned long refault;
>  	struct pglist_data *pgdat;
>  	int memcgid;
> +#ifndef NO_SECS_IN_WORKINGSET
> +	unsigned long avg_refault_time;
> +	unsigned long refault_time;
> +	int tradition;
> +	unsigned int prev_secs;
> +	unsigned int secs;
> +	unsigned long refaults_ratio;
> +#endif
> +	struct timespec ts;
> +	/*
> +	convert jiffies to second
> +	*/
> +	get_monotonic_boottime(&ts);
> +	secs = (unsigned int)ts.tv_sec ? (unsigned int)ts.tv_sec : 1;
>  
> -	unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> -
> +	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_secs);
>  	rcu_read_lock();
>  	/*
>  	 * Look up the memcg associated with the stored ID. It might
> @@ -288,14 +364,37 @@ bool workingset_refault(void *shadow)
>  	 * list is not a problem.
>  	 */
>  	refault_distance = (refault - eviction) & EVICTION_MASK;
> -
>  	inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> -
> -	if (refault_distance <= active_file) {
> +#ifndef NO_SECS_IN_WORKINGSET
> +	refaults_ratio = (atomic_long_read(&lruvec->inactive_age) + 1) / secs;
> +	atomic_long_set(&lruvec->refaults_ratio, refaults_ratio);
> +	refault_time = secs - prev_secs;
> +	avg_refault_time = active_file / refaults_ratio;
> +	tradition = !!(refault_distance < active_file);
> +	if (refault_time <= avg_refault_time) {
> +#else
> +	if (refault_distance < active_file) {
> +#endif
>  		inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
> +#ifndef NO_SECS_IN_WORKINGSET
> +		trace_printk("WKST_ACT[%d]:rft_dis %ld, act_file %ld \
> +				rft_ratio %ld rft_time %ld avg_rft_time %ld \
> +				refault %ld eviction %ld secs %d pre_secs %d\n",
> +				tradition, refault_distance, active_file,
> +				refaults_ratio, refault_time, avg_refault_time,
> +				refault, eviction, secs, prev_secs);
> +#endif
>  		rcu_read_unlock();
>  		return true;
>  	}
> +#ifndef NO_SECS_IN_WORKINGSET
> +	trace_printk("WKST_INACT[%d]:rft_dis %ld, act_file %ld \
> +			rft_ratio %ld rft_time %ld avg_rft_time %ld \
> +			refault %ld eviction %ld secs %d pre_secs %d\n",
> +			tradition, refault_distance, active_file,
> +			refaults_ratio, refault_time, avg_refault_time,
> +			refault, eviction, secs, prev_secs);
> +#endif
>  	rcu_read_unlock();
>  	return false;
>  }
> @@ -513,7 +612,9 @@ static int __init workingset_init(void)
>  	unsigned int max_order;
>  	int ret;
>  
> -	BUILD_BUG_ON(BITS_PER_LONG < EVICTION_SHIFT);
> +	BUILD_BUG_ON(BITS_PER_LONG < (EVICTION_SHIFT
> +				+ EVICTION_SECS_POS_SHIFT
> +				+ EVICTION_SECS_SHRINK_SHIFT));
>  	/*
>  	 * Calculate the eviction bucket size to cover the longest
>  	 * actionable refault distance, which is currently half of
> @@ -521,7 +622,8 @@ static int __init workingset_init(void)
>  	 * some more pages at runtime, so keep working with up to
>  	 * double the initial memory by using totalram_pages as-is.
>  	 */
> -	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> +	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT
> +			- EVICTION_SECS_POS_SHIFT - EVICTION_SECS_SHRINK_SHIFT;
>  	max_order = fls_long(totalram_pages - 1);
>  	if (max_order > timestamp_bits)
>  		bucket_order = max_order - timestamp_bits;
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

