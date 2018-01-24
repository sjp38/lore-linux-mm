Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 90E3E800DD
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 04:26:54 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 33so2031082wrs.3
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 01:26:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si575321wmd.189.2018.01.24.01.26.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 01:26:53 -0800 (PST)
Date: Wed, 24 Jan 2018 10:26:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [LSF/MM TOPIC] few MM topics
Message-ID: <20180124092649.GC21134@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

Hi,
I would like to propose the following few topics for further discussion
at LSF/MM this year. MM track would be the most appropriate one but
there is some overlap with FS and NVDIM
- memcg OOM behavior has changed around 3.12 as a result of OOM
  deadlocks when the memcg OOM killer was triggered from the charge
  path. We simply fail the charge and unroll to a safe place to
  trigger the OOM killer. This is only done from the #PF path and any
  g-u-p or kmem accounted allocation can just fail in that case leading
  to unexpected ENOMEM to userspace. I believe we can return to the
  original OOM handling now that we have the oom reaper and guranteed
  forward progress of the OOM path.
  Discussion http://lkml.kernel.org/r/20171010142434.bpiqmsbb7gttrlcb@dhcp22.suse.cz
- It seems there is some demand for large (> MAX_ORDER) allocations.
  We have that alloc_contig_range which was originally used for CMA and
  later (ab)used for Giga hugetlb pages. The API is less than optimal
  and we should probably think about how to make it more generic.
- we have grown a new get_user_pages_longterm. It is an ugly API and
  I think we really need to have a decent page pinning one with the
  accounting and limiting.
- memory hotplug has seen quite some surgery last year and it seems that
  DAX/nvdim and HMM have some interest in using it as well. I am mostly
  interested in struct page self hosting which is already done for NVDIM
  AFAIU. It would be great if we can unify that for the regular mem
  hotplug as well.
- I would be very interested to talk about memory softofflining
  (HWPoison) with somebody familiar with this area because I find the
  development in that area as more or less random without any design in
  mind. The resulting code is chaotic and stuffed to "random" places.
- I would also love to talk to some FS people and convince them to move
  away from GFP_NOFS in favor of the new scope API. I know this just
  means to send patches but the existing code is quite complex and it
  really requires somebody familiar with the specific FS to do that
  work.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
