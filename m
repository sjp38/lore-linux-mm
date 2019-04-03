Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69A53C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:52:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2009A20693
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 07:52:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2009A20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B28626B0003; Wed,  3 Apr 2019 03:52:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD85C6B000A; Wed,  3 Apr 2019 03:52:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9ED576B000C; Wed,  3 Apr 2019 03:52:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8686B0003
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 03:52:42 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id s26so6623858qkm.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 00:52:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QkoDa2dGXwK7WBiyvUEZ6Uc0h9UePx3gLP/Qj7FxubQ=;
        b=A3Yn7qV3N9GU9M6g/osJIRqOBUU1o8yAqRiwP7lK7ku3kh09myogn2dHLYmti4Sp52
         DsiaBQFYNFSSfc8tU/67wu4zQFmRWiyDizHEl7Lz2qWa1PBthglyHp9h5gyAE4xWQo+1
         oNz4tbT+MzS+CWI4rnKRy422+eztikYx/6q5W5o6DcPVc9nYM0R1jvsmXuWAiddA22nS
         dEJAaq7UFW7iDU4WPS+Lv528cwCiiEp8VUeQeWMhvmy8aH28fb+S8cSElYHs4C5ReTe2
         YHVTD6sT2GTqeDk2N2A9tJljNgstE0vyAazd1lN56kXmOtYku5WH3KrcIL6MZeJzYK8M
         1frA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWv4yUL53rAfxM+0RMFj7ywqgWcvkvtrTux5o7K8Vmh6L5U6wyZ
	xv8sjH6x23ZWCtbeNdM7bXLDdZxVYwRi1wVf/r5s2J60IxBvfw3jTQp9JxI3SAqj+kCdFylKmmp
	e3lJHHUNlANwjRZuiZ07QH2liJsWWoSYfGsRYVkWz3FV009AyVl5uAH2YXZQLCkHSTA==
X-Received: by 2002:ae9:e413:: with SMTP id q19mr61218808qkc.324.1554277962205;
        Wed, 03 Apr 2019 00:52:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcpPfxtPuWff8VkJ+nI0sPEOOL5oYcjRfj7wuyeESLRb4QVG0Pwse4U6G+zTsFbLlJjjqg
X-Received: by 2002:ae9:e413:: with SMTP id q19mr61218783qkc.324.1554277961604;
        Wed, 03 Apr 2019 00:52:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554277961; cv=none;
        d=google.com; s=arc-20160816;
        b=Rz0jb4AfAFpmsPNWIy7NogpdQwZtlEl/ge4xm7r0Mn7tbT8Vv9LgN0ezHAEIS4R1+h
         66Na2u5mWcXTctrs6b+P3F0Kf7xWPnhUZ429Fmt6yBf4SHr/Tztx+c7bdtWYSDVHY+i8
         UZ/Agf3a2y8vGh+RAv/u1Zj9VsN1z5onfQGOnqL0Y/nJCzvjcDZXPhHKGCKl/vlBGZBC
         /9b03tmBrMwn2DmkKmimkDyMThkYdpDItDxgX6ULqHh1oE9co5YcQW7ac62kgmcAXHCN
         VKK0WE/Oa9XSFZzD3tbFHol+Y2MIO6HaZdGJaTvddMcwAKS0KxixUKKf+ZTaPvIkClGp
         JOwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QkoDa2dGXwK7WBiyvUEZ6Uc0h9UePx3gLP/Qj7FxubQ=;
        b=IsZs1M/ELWqFszmWCmAc5k3RiZX8RD3PsLdi7tKm3CCIkmggU1MgVW3ZkBJcE1zUoG
         moUeqljsCfYN3T65DeDQ9hNJjOCvRpcqCJ1m2tVz2poW1rh+6XLtjLVTHq2UC+51oaRp
         0E9S6SKYiyWyuqFRjwVwrbyvwzD/h2f1j2WZxex6VjMjIDFUsO1Sp6JIiVShKFuZ+qXN
         q0OcWVuMCBM287+jXpOkWvNGq4nsj+DUvNEBlZkGHU2knScP+Wpv/Ao4eektOsTw5WLs
         r6CrWJbaEdMvL10Jn7sjioEOy6GVmBuBjaJYcMM4AM4Ze/Ysr6LczsHW6dBTZBLAEXlP
         BGQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t56si1059602qte.112.2019.04.03.00.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 00:52:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 83F573DE;
	Wed,  3 Apr 2019 07:52:40 +0000 (UTC)
Received: from localhost (ovpn-12-31.pek2.redhat.com [10.72.12.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A9F1F1001DDD;
	Wed,  3 Apr 2019 07:52:39 +0000 (UTC)
Date: Wed, 3 Apr 2019 15:52:36 +0800
From: Baoquan He <bhe@redhat.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mike.kravetz@oracle.com,
	n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hugetlb: Get rid of NODEMASK_ALLOC
Message-ID: <20190403075236.GB31828@MiWiFi-R3L-srv>
References: <20190402133415.21983-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402133415.21983-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 03 Apr 2019 07:52:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/02/19 at 03:34pm, Oscar Salvador wrote:
> NODEMASK_ALLOC is used to allocate a nodemask bitmap, ant it does it by
                                                         ~ and
> first determining whether it should be allocated in the stack or dinamically
                                                              dynamically^^
> depending on NODES_SHIFT.
> Right now, it goes the dynamic path whenever the nodemask_t is above 32
> bytes.
> 
> Although we could bump it to a reasonable value, the largest a nodemask_t
> can get is 128 bytes, so since __nr_hugepages_store_common is called from
> a rather shore stack we can just get rid of the NODEMASK_ALLOC call here.
> 
> This reduces some code churn and complexity.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/hugetlb.c | 36 +++++++++++-------------------------
>  1 file changed, 11 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index f79ae4e42159..9cb2f91af897 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2447,44 +2447,30 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>  					   unsigned long count, size_t len)
>  {
>  	int err;
> -	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
> +	nodemask_t nodes_allowed, *n_mask;
>  
> -	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
> -		err = -EINVAL;
> -		goto out;
> -	}
> +	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
> +		return -EINVAL;
>  
>  	if (nid == NUMA_NO_NODE) {
>  		/*
>  		 * global hstate attribute
>  		 */
>  		if (!(obey_mempolicy &&
> -				init_nodemask_of_mempolicy(nodes_allowed))) {
> -			NODEMASK_FREE(nodes_allowed);
> -			nodes_allowed = &node_states[N_MEMORY];
> -		}
> -	} else if (nodes_allowed) {
> +				init_nodemask_of_mempolicy(&nodes_allowed)))
> +			n_mask = &node_states[N_MEMORY];
> +		else
> +			n_mask = &nodes_allowed;
> +	} else {
>  		/*
>  		 * Node specific request.  count adjustment happens in
>  		 * set_max_huge_pages() after acquiring hugetlb_lock.
>  		 */
> -		init_nodemask_of_node(nodes_allowed, nid);
> -	} else {
> -		/*
> -		 * Node specific request, but we could not allocate the few
> -		 * words required for a node mask.  We are unlikely to hit
> -		 * this condition.  Since we can not pass down the appropriate
> -		 * node mask, just return ENOMEM.
> -		 */
> -		err = -ENOMEM;
> -		goto out;
> +		init_nodemask_of_node(&nodes_allowed, nid);
> +		n_mask = &nodes_allowed;
>  	}
>  
> -	err = set_max_huge_pages(h, count, nid, nodes_allowed);
> -
> -out:
> -	if (nodes_allowed != &node_states[N_MEMORY])
> -		NODEMASK_FREE(nodes_allowed);
> +	err = set_max_huge_pages(h, count, nid, n_mask);
>  
>  	return err ? err : len;
>  }
> -- 
> 2.13.7
> 

