Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37B246B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 14:21:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id k76so15228080iod.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 11:21:16 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id r136si363064itb.37.2018.01.31.11.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 11:21:14 -0800 (PST)
Date: Wed, 31 Jan 2018 11:21:04 -0800
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] few MM topics
Message-ID: <20180131192104.GD4841@magnolia>
References: <20180124092649.GC21134@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124092649.GC21134@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On Wed, Jan 24, 2018 at 10:26:49AM +0100, Michal Hocko wrote:
> Hi,
> I would like to propose the following few topics for further discussion
> at LSF/MM this year. MM track would be the most appropriate one but
> there is some overlap with FS and NVDIM
> - memcg OOM behavior has changed around 3.12 as a result of OOM
>   deadlocks when the memcg OOM killer was triggered from the charge
>   path. We simply fail the charge and unroll to a safe place to
>   trigger the OOM killer. This is only done from the #PF path and any
>   g-u-p or kmem accounted allocation can just fail in that case leading
>   to unexpected ENOMEM to userspace. I believe we can return to the
>   original OOM handling now that we have the oom reaper and guranteed
>   forward progress of the OOM path.
>   Discussion http://lkml.kernel.org/r/20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz
> - It seems there is some demand for large (> MAX_ORDER) allocations.
>   We have that alloc_contig_range which was originally used for CMA and
>   later (ab)used for Giga hugetlb pages. The API is less than optimal
>   and we should probably think about how to make it more generic.
> - we have grown a new get_user_pages_longterm. It is an ugly API and
>   I think we really need to have a decent page pinning one with the
>   accounting and limiting.
> - memory hotplug has seen quite some surgery last year and it seems that
>   DAX/nvdim and HMM have some interest in using it as well. I am mostly
>   interested in struct page self hosting which is already done for NVDIM
>   AFAIU. It would be great if we can unify that for the regular mem
>   hotplug as well.
> - I would be very interested to talk about memory softofflining
>   (HWPoison) with somebody familiar with this area because I find the
>   development in that area as more or less random without any design in
>   mind. The resulting code is chaotic and stuffed to "random" places.
> - I would also love to talk to some FS people and convince them to move
>   away from GFP_NOFS in favor of the new scope API. I know this just
>   means to send patches but the existing code is quite complex and it
>   really requires somebody familiar with the specific FS to do that
>   work.

Hm, are you talking about setting PF_MEMALLOC_NOFS instead of passing
*_NOFS to allocation functions and whatnot?  Right now XFS will set it
on any thread which has a transaction open, but that doesn't help for
fs operations that don't have transactions (e.g. reading metadata,
opening files).  I suppose we could just set the flag any time someone
stumbles into the fs code from userspace, though you're right that seems
daunting.

--D

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
