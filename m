Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBAB76B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 16:44:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p86so110657015pfl.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 13:44:43 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id l3si11992924pgn.304.2017.05.15.13.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 13:44:42 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
 <20170515193817.GC7551@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <9b3d68aa-d2b6-2b02-4e75-f8372cbeb041@oracle.com>
Date: Mon, 15 May 2017 16:44:26 -0400
MIME-Version: 1.0
In-Reply-To: <20170515193817.GC7551@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net



On 05/15/2017 03:38 PM, Michal Hocko wrote:
> On Mon 15-05-17 14:12:10, Pasha Tatashin wrote:
>> Hi Michal,
>>
>> After looking at your suggested memblock_virt_alloc_core() change again, I
>> decided to keep what I have. I do not want to inline
>> memblock_virt_alloc_internal(), because it is not a performance critical
>> path, and by inlining it we will unnecessarily increase the text size on all
>> platforms.
> 
> I do not insist but I would really _prefer_ if the bool zero argument
> didn't proliferate all over the memblock API.

Sure, I will remove zero boolean argument from 
memblock_virt_alloc_internal(), and do memset() calls inside callers.

>   
>> Also, because it will be very hard to make sure that no platform regresses
>> by making memset() default in _memblock_virt_alloc_core() (as I already
>> showed last week at least sun4v SPARC64 will require special changes in
>> order for this to work), I decided to make it available only for "deferred
>> struct page init" case. As, what is already in the patch.
> 
> I do not think this is the right approach. Your measurements just show
> that sparc could have a more optimized memset for small sizes. If you
> keep the same memset only for the parallel initialization then you
> just hide this fact. I wouldn't worry about other architectures. All
> sane architectures should simply work reasonably well when touching a
> single or only few cache lines at the same time. If some arches really
> suffer from small memsets then the initialization should be driven by a
> specific ARCH_WANT_LARGE_PAGEBLOCK_INIT rather than making this depend
> on DEFERRED_INIT. Or if you are too worried then make it opt-in and make
> it depend on ARCH_WANT_PER_PAGE_INIT and make it enabled for x86 and
> sparc after memset optimization.

OK, I will think about this.

I do not really like adding new configs because they tend to clutter the 
code. This is why, I wanted to rely on already existing config that I 
know benefits all platforms that use it. Eventually, 
"CONFIG_DEFERRED_STRUCT_PAGE_INIT" is going to become the default 
everywhere, as there should not be a drawback of using it even on small 
machines.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
