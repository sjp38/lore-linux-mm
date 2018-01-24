Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CDC1800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:23:38 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y63so3657741pff.5
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:23:38 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id x81si3264835pfe.361.2018.01.24.10.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 10:23:36 -0800 (PST)
Subject: Re: [LSF/MM TOPIC] few MM topics
References: <20180124092649.GC21134@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <bee1d564-b4b8-ed0c-edfa-f6df6a24fe21@oracle.com>
Date: Wed, 24 Jan 2018 10:23:20 -0800
MIME-Version: 1.0
In-Reply-To: <20180124092649.GC21134@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

On 01/24/2018 01:26 AM, Michal Hocko wrote:
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

This is also of interest to me.  I actually started some efforts in this
area.  The idea (as you mention above) would be to provide a more usable
API for allocation of contiguous pages/ranges.  And, gigantic huge pages
would be the first consumer.

alloc_contig_range currently has some issues with being used in a 'more
generic' way.  A comment describing the routine says "it's the caller's
responsibility to guarantee that we are the only thread that changes
migrate type of pageblocks the pages fall in.".  This is true, and I think
it also applies to users of the underlying routines such as
start_isolate_page_range.  The CMA code has a mechanism that prevents two
threads from operating on the same range concurrently.  The other users
(gigantic page allocation and memory offline) happen infrequently enough
that we are unlikely to have a conflict.  But, opening this up to more
generic use will require at least a more generic synchronization mechanism.

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

Me too.  I have looked at some code in this area for huge pages.  At least
for huge pages there is more work to do as indicated by this comment:
/*
 * Huge pages. Needs work.
 * Issues:
 * - Error on hugepage is contained in hugepage unit (not in raw page unit.)
 *   To narrow down kill region to one page, we need to break up pmd.
 */

-- 
Mike Kravetz

> - I would also love to talk to some FS people and convince them to move
>   away from GFP_NOFS in favor of the new scope API. I know this just
>   means to send patches but the existing code is quite complex and it
>   really requires somebody familiar with the specific FS to do that
>   work.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
