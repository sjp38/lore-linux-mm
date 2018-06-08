Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60A506B0008
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 16:55:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f3-v6so7887080wre.11
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 13:55:38 -0700 (PDT)
Received: from mx0a-00190b01.pphosted.com (mx0a-00190b01.pphosted.com. [2620:100:9001:583::1])
        by mx.google.com with ESMTPS id x61-v6si1704363edc.329.2018.06.08.13.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 13:55:37 -0700 (PDT)
Subject: Re: [PATCH] mm/madvise: allow MADV_DONTNEED to free memory that is
 MLOCK_ONFAULT
References: <1528484212-7199-1-git-send-email-jbaron@akamai.com>
 <20180608125717.c34d3e7125c62fc91ac427c8@linux-foundation.org>
From: Jason Baron <jbaron@akamai.com>
Message-ID: <ce5c6352-3f35-f02b-5e1b-b22649b15e12@akamai.com>
Date: Fri, 8 Jun 2018 16:55:29 -0400
MIME-Version: 1.0
In-Reply-To: <20180608125717.c34d3e7125c62fc91ac427c8@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 06/08/2018 03:57 PM, Andrew Morton wrote:
> On Fri,  8 Jun 2018 14:56:52 -0400 Jason Baron <jbaron@akamai.com> wrote:
> 
>> In order to free memory that is marked MLOCK_ONFAULT, the memory region
>> needs to be first unlocked, before calling MADV_DONTNEED. And if the region
>> is to be reused as MLOCK_ONFAULT, we require another call to mlock2() with
>> the MLOCK_ONFAULT flag.
>>
>> Let's simplify freeing memory that is set MLOCK_ONFAULT, by allowing
>> MADV_DONTNEED to work directly for memory that is set MLOCK_ONFAULT. The
>> locked memory limits, tracked by mm->locked_vm do not need to be adjusted
>> in this case, since they were charged to the entire region when
>> MLOCK_ONFAULT was initially set.
> 
> Seems useful.
> 
> Is a manpage update planned?
> 

Yes, I will add a manpage update. I sort of wanted to see first if
people thought this patch was a reasonable thing to do.

> Various updates to tools/testing/selftests/vm/* seem appropriate.
> 

Indeed, I started updating tootls/testing/selftests/vm/mlock2-tests.c
with this new interface, but then I realized that that test is failing
before I made any changes. So I will go back and sort that out, and add
additional testing for this new interface.

>> Further, I don't think allowing MADV_FREE for MLOCK_ONFAULT regions makes
>> sense, since the point of MLOCK_ONFAULT is for userspace to know when pages
>> are locked in memory and thus to know when page faults will occur.
> 
> This sounds non-backward-compatible?
> 

I was making the point of why I think allowing 'MADV_DONTNEED' for
MLOCK_ONFAULT regions makes sense, while allowing 'MADV_FREE' for
MLOCK_ONFAULT regions really does not.

Thanks,

-Jason
