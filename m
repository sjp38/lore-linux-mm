Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3AB76B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:17:09 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s6so1397644pgq.23
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 03:17:09 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 1-v6si5244159plj.247.2018.04.13.03.17.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 03:17:08 -0700 (PDT)
Subject: Re: [PATCH] mm: vmalloc: Remove double execution of vunmap_page_range
References: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
 <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
From: Chintan Pandya <cpandya@codeaurora.org>
Message-ID: <8da9f826-2a3d-e618-e512-4fc8d45c16f2@codeaurora.org>
Date: Fri, 13 Apr 2018 15:47:02 +0530
MIME-Version: 1.0
In-Reply-To: <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/13/2018 3:29 PM, Anshuman Khandual wrote:
> On 04/13/2018 02:46 PM, Chintan Pandya wrote:
>> Unmap legs do call vunmap_page_range() irrespective of
>> debug_pagealloc_enabled() is enabled or not. So, remove
>> redundant check and optional vunmap_page_range() routines.
> 
> vunmap_page_range() tears down the page table entries and does
> not really flush related TLB entries normally unless page alloc
> debug is enabled where it wants to make sure no stale mapping is
> still around for debug purpose. Deferring TLB flush improves
> performance. This patch will force TLB flush during each page
> table tear down and hence not desirable.
> 
Deferred TLB invalidation will surely improve performance. But force
flush can help in detecting invalid access right then and there. I
chose later. May be I should have clean up the vmap tear down code
as well where it actually does the TLB invalidation.

Or make TLB invalidation in free_unmap_vmap_area() be dependent upon
debug_pagealloc_enabled().

Chintan
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, a Linux Foundation
Collaborative Project
