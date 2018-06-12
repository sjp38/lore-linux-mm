Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 187CE6B0007
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 10:11:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n21-v6so7679439wmc.4
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 07:11:40 -0700 (PDT)
Received: from mx0a-00190b01.pphosted.com (mx0a-00190b01.pphosted.com. [2620:100:9001:583::1])
        by mx.google.com with ESMTPS id w43-v6si412968edw.120.2018.06.12.07.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 07:11:38 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180611072005.GC13364@dhcp22.suse.cz>
 <4c4de46d-c55a-99a8-469f-e1e634fb8525@akamai.com>
 <20180611150330.GQ13364@dhcp22.suse.cz>
 <775adf2d-140c-1460-857f-2de7b24bafe7@akamai.com>
 <20180612074646.GS13364@dhcp22.suse.cz>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <5a9398f4-453c-5cb5-6bbc-f20c3affc96a@akamai.com>
Date: Tue, 12 Jun 2018 10:11:33 -0400
MIME-Version: 1.0
In-Reply-To: <20180612074646.GS13364@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org, emunson@mgebm.net



On 06/12/2018 03:46 AM, Michal Hocko wrote:
> On Mon 11-06-18 12:23:58, Jason Baron wrote:
>> On 06/11/2018 11:03 AM, Michal Hocko wrote:
>>> So can we start discussing whether we want to allow MADV_DONTNEED on
>>> mlocked areas and what downsides it might have? Sure it would turn the
>>> strong mlock guarantee to have the whole vma resident but is this
>>> acceptable for something that is an explicit request from the owner of
>>> the memory?
>>>
>>
>> If its being explicity requested by the owner it makes sense to me. I
>> guess there could be a concern about this breaking some userspace that
>> relied on MADV_DONTNEED not freeing locked memory?
> 
> Yes, this is always the fear when changing user visible behavior.  I can
> imagine that a userspace allocator calling MADV_DONTNEED on free could
> break. The same would apply to MLOCK_ONFAULT/MCL_ONFAULT though. We
> have the new flag much shorter so the probability is smaller but the
> problem is very same. So I _think_ we should treat both the same because
> semantically they are indistinguishable from the MADV_DONTNEED POV. Both
> remove faulted and mlocked pages. Mlock, once applied, should guarantee
> no later major fault and MADV_DONTNEED breaks that obviously.
> 
> So the more I think about it the more I am worried about this but I am
> more and more convinced that making ONFAULT special is just a wrong way
> around this.
> 

Ok, I share the concern that there is a chance that userspace is relying
on MADV_DONTNEED not free'ing locked memory. In that case, what if we
introduce a MADV_DONTNEED_FORCE, which does everything that
MADV_DONTNEED currently does but in addition will also free mlock areas.
That way there is no concern about breaking something.

Thanks,

-Jason
