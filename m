Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C289C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:15:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0967320855
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 07:15:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0967320855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A67C56B0008; Thu,  4 Apr 2019 03:15:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3DED6B000A; Thu,  4 Apr 2019 03:15:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92CA46B000D; Thu,  4 Apr 2019 03:15:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3176B0008
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 03:15:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z98so887299ede.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 00:15:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=71TPOxvlZ/WVFmxXgszLnCi/Vd26Rjr4Pz+pf4db6RM=;
        b=Uz3QkXLthsmbDJNcccY+gaCJPSNTPjN/tgZQZuUfce6BHwv0i4JLiPwNvsyAcvKb2Q
         f95K/k6EUZmOFDjQGnB0Y54mAr7+MQdkJw6g1hlyDCV+GLpbWOcixLGhbLxUIFz3Xh8v
         qYIAqhBNF72D7HgZ7KjDRxcsPlsWOt2riQwyjLYAaTCt6arRnhQutu4jIbmXugezYxyT
         4LT7RjnJAtks2Q4Bm78PXUxjzezUO6K+Va2V2GGBszyvf0ELyWZKs6dQCmwZAcwURZRV
         EtcFBT+Wx277wrwWtUg3ZXPZWeXfT4uceBlsW3pKfrZME48pGZAUHxz6R5elmyLFZ9my
         AiPw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkSH2SIdYF9t1rvK6jLJSq0qG2Bd2JJ1apJoFlidhBwxPDFYEJ
	nowEkZ3MgjwhHaUCTJcTgh/ObLbkAaghC4Eu74d1a8Y7TcUPv69kuIiDHasSptc2QCbODKZNPmq
	n46P/cZ5vDg0WK3v7lo4yxYpXg/U8xIwRajxns8PmQEwnGU93RZvaFE84ZvCi3yk=
X-Received: by 2002:a17:906:4d8b:: with SMTP id s11mr2604539eju.31.1554362116746;
        Thu, 04 Apr 2019 00:15:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFxk6p4sSguXv0KOAHjGEYWRnbeuMMpIDvZhfVS2YteAkBPhKA5liGWgBPhpJ0qW4MAc4A
X-Received: by 2002:a17:906:4d8b:: with SMTP id s11mr2604483eju.31.1554362115717;
        Thu, 04 Apr 2019 00:15:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554362115; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCASZneeRf4Y2FU+YYw6VqHGSh9iNtF4p85KMsu6Ov/H3WewRBZnjAeux9MPEI8Yro
         FiUSmxaGD+WTA8ycN+VUitMIha4RleYU/2Wt4td6OhSBPWwGUk37baYEiV0i9vpRlu10
         F5GbuQTLyOdgzn+ExRJoxPz7wJe+8n2cCcIaM0E4b9I3MBARGGSJrTVAyG8EDu1lVSVK
         6Tbui1i1WeeK4oq/SifLg7oxJU+7LK4plS+EJToIS9ekS4Y+6O28H2IKFUsxKT6KzkbW
         89B3e5VUdGRfIAw8wAJoph/pCnf2+ku08SAtVDjNFUMIUb3Gv8lI4PHO7GCnxLbHdDKn
         moDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=71TPOxvlZ/WVFmxXgszLnCi/Vd26Rjr4Pz+pf4db6RM=;
        b=se8a7D6rPAPPMpTu08LImB4TdtrSQZNFkb8+wVcsDWxOzCwlXKqzl48MfApqIvyrBH
         FjFribdtfLJyOyaoLFBAjPvb2DxzU5nXoGemy7UjsjVd42Nw+aaU4V32wbp19RfArAvO
         s5dNGf1mB3FgFdADb3OGiGuzKi010Qk7ziTidXmFRROSy+nsji7hqB4jIflylgWkmOQs
         Vixz0aNCOjY13jhDo8V5AaUm692beGi8+kU0cmVD9bWVFQreKh5XakH6OU739BXymX/+
         iPtgxJt7SmPJ4q+xjnFK/fKfL7ZfJDFMMf6rjR2RamE+sEb0sVbfSbEMqvjlvNl3hclH
         uOYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n25si7966619edr.314.2019.04.04.00.15.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 00:15:15 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 06844AD2B;
	Thu,  4 Apr 2019 07:15:14 +0000 (UTC)
Date: Thu, 4 Apr 2019 09:15:12 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	David Rientjes <rientjes@google.com>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Roman Gushchin <guro@fb.com>, Jeff Layton <jlayton@redhat.com>,
	Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the
 file page
Message-ID: <20190404071512.GE12864@dhcp22.suse.cz>
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Fixup email for Pavel and add Johannes]

On Thu 04-04-19 11:30:17, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> In previous implementation, the number of refault pages is used
> for judging the refault period of each page, which is not precised as
> eviction of other files will be affect a lot on current cache.
> We introduce the timestamp into the workingset's entry and refault ratio
> to measure the file page's activity. It helps to decrease the affection
> of other files(average refault ratio can reflect the view of whole system
> 's memory).
> The patch is tested on an Android system, which can be described as
> comparing the launch time of an application between a huge memory
> consumption. The result is launch time decrease 50% and the page fault
> during the test decrease 80%.
> 
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  include/linux/mmzone.h |  2 ++
>  mm/workingset.c        | 24 +++++++++++++++++-------
>  2 files changed, 19 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 32699b2..c38ba0a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -240,6 +240,8 @@ struct lruvec {
>  	atomic_long_t			inactive_age;
>  	/* Refaults at the time of last reclaim cycle */
>  	unsigned long			refaults;
> +	atomic_long_t			refaults_ratio;
> +	atomic_long_t			prev_fault;
>  #ifdef CONFIG_MEMCG
>  	struct pglist_data *pgdat;
>  #endif
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 40ee02c..6361853 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -159,7 +159,7 @@
>  			 NODES_SHIFT +	\
>  			 MEM_CGROUP_ID_SHIFT)
>  #define EVICTION_MASK	(~0UL >> EVICTION_SHIFT)
> -
> +#define EVICTION_JIFFIES (BITS_PER_LONG >> 3)
>  /*
>   * Eviction timestamps need to be able to cover the full range of
>   * actionable refaults. However, bits are tight in the radix tree
> @@ -175,18 +175,22 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  	eviction >>= bucket_order;
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>  	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> +	eviction = (eviction << EVICTION_JIFFIES) | (jiffies >> EVICTION_JIFFIES);
>  	eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
>  
>  	return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
>  }
>  
>  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> -			  unsigned long *evictionp)
> +			  unsigned long *evictionp, unsigned long *prev_jiffp)
>  {
>  	unsigned long entry = (unsigned long)shadow;
>  	int memcgid, nid;
> +	unsigned long prev_jiff;
>  
>  	entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> +	entry >>= EVICTION_JIFFIES;
> +	prev_jiff = (entry & ((1UL << EVICTION_JIFFIES) - 1)) << EVICTION_JIFFIES;
>  	nid = entry & ((1UL << NODES_SHIFT) - 1);
>  	entry >>= NODES_SHIFT;
>  	memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
> @@ -195,6 +199,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
>  	*memcgidp = memcgid;
>  	*pgdat = NODE_DATA(nid);
>  	*evictionp = entry << bucket_order;
> +	*prev_jiffp = prev_jiff;
>  }
>  
>  /**
> @@ -242,8 +247,12 @@ bool workingset_refault(void *shadow)
>  	unsigned long refault;
>  	struct pglist_data *pgdat;
>  	int memcgid;
> +	unsigned long refault_ratio;
> +	unsigned long prev_jiff;
> +	unsigned long avg_refault_time;
> +	unsigned long refault_time;
>  
> -	unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> +	unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_jiff);
>  
>  	rcu_read_lock();
>  	/*
> @@ -288,10 +297,11 @@ bool workingset_refault(void *shadow)
>  	 * list is not a problem.
>  	 */
>  	refault_distance = (refault - eviction) & EVICTION_MASK;
> -
>  	inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> -
> -	if (refault_distance <= active_file) {
> +	lruvec->refaults_ratio = atomic_long_read(&lruvec->inactive_age) / jiffies;
> +	refault_time = jiffies - prev_jiff;
> +	avg_refault_time = refault_distance / lruvec->refaults_ratio;
> +	if (refault_time <= avg_refault_time) {
>  		inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
>  		rcu_read_unlock();
>  		return true;
> @@ -521,7 +531,7 @@ static int __init workingset_init(void)
>  	 * some more pages at runtime, so keep working with up to
>  	 * double the initial memory by using totalram_pages as-is.
>  	 */
> -	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> +	timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT - EVICTION_JIFFIES;
>  	max_order = fls_long(totalram_pages - 1);
>  	if (max_order > timestamp_bits)
>  		bucket_order = max_order - timestamp_bits;
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

