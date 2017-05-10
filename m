Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8037D2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:01:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id k74so13140542qke.4
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:01:54 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p32si2473748qtp.31.2017.05.10.08.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 08:01:53 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <fae4a92c-e78c-32cb-606a-8e5087acb13f@oracle.com>
 <20170510072419.GC31466@dhcp22.suse.cz>
 <3f5f1416-aa91-a2ff-cc89-b97fcaa3e4db@oracle.com>
 <20170510145726.GM31466@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <ab667486-54a0-a36e-6797-b5f7b83c10f7@oracle.com>
Date: Wed, 10 May 2017 11:01:40 -0400
MIME-Version: 1.0
In-Reply-To: <20170510145726.GM31466@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net



On 05/10/2017 10:57 AM, Michal Hocko wrote:
> On Wed 10-05-17 09:42:22, Pasha Tatashin wrote:
>>>
>>> Well, I didn't object to this particular part. I was mostly concerned
>>> about
>>> http://lkml.kernel.org/r/1494003796-748672-4-git-send-email-pasha.tatashin@oracle.com
>>> and the "zero" argument for other functions. I guess we can do without
>>> that. I _think_ that we should simply _always_ initialize the page at the
>>> __init_single_page time rather than during the allocation. That would
>>> require dropping __GFP_ZERO for non-memblock allocations. Or do you
>>> think we could regress for single threaded initialization?
>>>
>>
>> Hi Michal,
>>
>> Thats exactly right, I am worried that we will regress when there is no
>> parallelized initialization of "struct pages" if we force unconditionally do
>> memset() in __init_single_page(). The overhead of calling memset() on a
>> smaller chunks (64-bytes) may cause the regression, this is why I opted only
>> for parallelized case to zero this metadata. This way, we are guaranteed to
>> see great improvements from this change without having regressions on
>> platforms and builds that do not support parallelized initialization of
>> "struct pages".
> 
> Have you measured that? I do not think it would be super hard to
> measure. I would be quite surprised if this added much if anything at
> all as the whole struct page should be in the cache line already. We do
> set reference count and other struct members. Almost nobody should be
> looking at our page at this time and stealing the cache line. On the
> other hand a large memcpy will basically wipe everything away from the
> cpu cache. Or am I missing something?
> 

Perhaps you are right, and I will measure on x86. But, I suspect hit can 
become unacceptable on some platfoms: there is an overhead of calling a 
function, even if it is leaf-optimized, and there is an overhead in 
memset() to check for alignments of size and address, types of setting 
(zeroing vs. non-zeroing), etc., that adds up quickly.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
