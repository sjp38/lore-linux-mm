Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 695916B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 15:29:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w9-v6so6766751wrl.13
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 12:29:04 -0700 (PDT)
Received: from mx0a-00190b01.pphosted.com (mx0a-00190b01.pphosted.com. [2620:100:9001:583::1])
        by mx.google.com with ESMTPS id g50-v6si264507wrd.55.2018.06.15.12.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 12:29:02 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
 <20180612074646.GS13364@dhcp22.suse.cz>
 <5a9398f4-453c-5cb5-6bbc-f20c3affc96a@akamai.com>
 <20180613091355.GI13364@dhcp22.suse.cz>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <44e46470-ba0f-8270-ae69-dfb87fbd5a0a@akamai.com>
Date: Fri, 15 Jun 2018 15:28:57 -0400
MIME-Version: 1.0
In-Reply-To: <20180613091355.GI13364@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net



On 06/13/2018 05:13 AM, Michal Hocko wrote:
> On Tue 12-06-18 10:11:33, Jason Baron wrote:
> [...]
>> Ok, I share the concern that there is a chance that userspace is relying
>> on MADV_DONTNEED not free'ing locked memory. In that case, what if we
>> introduce a MADV_DONTNEED_FORCE, which does everything that
>> MADV_DONTNEED currently does but in addition will also free mlock areas.
> 
> What about other types of vmas that are not allowed to MADV_DONTNEED?
> _FORCE suggests that the user of the API know what he is doing so why
> shouldn't we allow unmapping hugetlb pages or special PFNMAPS? Or do we
> want to add MADV_DONTNEED_FORCE_FOR_REAL when somebody comes with
> another usecase?
> 
> I agree with Vlastimil that adding new madvise mode for niche case
> sounds like a bad idea so we should better be sure that a new flag has
> a reasonable semantic. Just allow mlocked pages is more of a tweak than
> a proper semantic. So making it force for real requires to analyze what
> that would mean for other vmas which are excluded now.
> 

If its a new flag, I agree it makes sense to look at hugetlb and
pfnmaps. pfnmaps might be more work, since it may require callbacks to
do driver specific actions...

I was able to do something very close to the original requirement of
free'ing mlock'd pages, via using a tmpfs mmap that is mlock'd. And then
using fallocate(FALLOC_FL_PUNCH_HOLE) to free the locked pages. I think
the tmpfs is sufficient for my needs, I wonder if there is any other
interest in this feature?

Thanks,

-Jason
