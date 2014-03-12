Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id A78D96B0031
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 09:11:55 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id t61so11441663wes.30
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 06:11:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si3899468wiz.21.2014.03.12.06.11.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 06:11:53 -0700 (PDT)
Date: Wed, 12 Mar 2014 14:11:52 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/8] mm: memcg: push !mm handling out to page cache
 charge function
Message-ID: <20140312131152.GC11831@dhcp22.suse.cz>
References: <1394587714-6966-1-git-send-email-hannes@cmpxchg.org>
 <1394587714-6966-5-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394587714-6966-5-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 11-03-14 21:28:30, Johannes Weiner wrote:
[...]
> @@ -4070,6 +4061,12 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		return 0;
>  
>  	if (!PageSwapCache(page)) {
> +		/*
> +		 * Page cache insertions can happen without an actual
> +		 * task context, e.g. during disk probing on boot.

We read a page cache during disk probing? I have tried to find such a
code path but failed. Could you point me to such a path, please?
I thought that such probing is done from udev context but I am not
familiar with this area TBH.

Thanks!

> +		 */
> +		if (!mm)
> +			memcg = root_mem_cgroup;
>  		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
>  		if (ret != -ENOMEM)
>  			__mem_cgroup_commit_charge(memcg, page, 1, type, false);
> -- 
> 1.9.0
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
