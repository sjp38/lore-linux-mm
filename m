Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 656A36B0038
	for <linux-mm@kvack.org>; Fri,  3 Apr 2015 21:34:21 -0400 (EDT)
Received: by igcau2 with SMTP id au2so72802798igc.1
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 18:34:21 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id n7si8855004icr.25.2015.04.03.18.34.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Apr 2015 18:34:20 -0700 (PDT)
Received: by igcau2 with SMTP id au2so110028563igc.0
        for <linux-mm@kvack.org>; Fri, 03 Apr 2015 18:34:20 -0700 (PDT)
Date: Fri, 3 Apr 2015 18:34:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -v2] mm, memcg: sync allocation and memcg charge gfp
 flags for THP
In-Reply-To: <20150318161407.GP17241@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1504031832490.18005@chino.kir.corp.google.com>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz> <55098D0A.8090605@suse.cz> <20150318150257.GL17241@dhcp22.suse.cz> <55099C72.1080102@suse.cz> <20150318155905.GO17241@dhcp22.suse.cz> <5509A31C.3070108@suse.cz>
 <20150318161407.GP17241@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 18 Mar 2015, Michal Hocko wrote:

> memcg currently uses hardcoded GFP_TRANSHUGE gfp flags for all THP
> charges. THP allocations, however, might be using different flags
> depending on /sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag
> and the current allocation context.
> 
> The primary difference is that defrag configured to "madvise" value will
> clear __GFP_WAIT flag from the core gfp mask to make the allocation
> lighter for all mappings which are not backed by VM_HUGEPAGE vmas.
> If memcg charge path ignores this fact we will get light allocation but
> the a potential memcg reclaim would kill the whole point of the
> configuration.
> 
> Fix the mismatch by providing the same gfp mask used for the
> allocation to the charge functions. This is quite easy for all
> paths except for hugepaged kernel thread with !CONFIG_NUMA which is
> doing a pre-allocation long before the allocated page is used in
> collapse_huge_page via khugepaged_alloc_page. To prevent from cluttering
> the whole code path from khugepaged_do_scan we simply return the current
> flags as per khugepaged_defrag() value which might have changed since
> the preallocation. If somebody changed the value of the knob we would
> charge differently but this shouldn't happen often and it is definitely
> not critical because it would only lead to a reduced success rate of
> one-off THP promotion.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Acked-by: David Rientjes <rientjes@google.com>

I'm slightly surprised that this issue never got reported before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
