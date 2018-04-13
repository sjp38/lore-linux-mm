Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D83946B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:40:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i3so980272wmf.7
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 03:40:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b29si5866329edc.123.2018.04.13.03.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 03:40:39 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3DAdb7d061760
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:40:38 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hask3ut5g-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:40:38 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 13 Apr 2018 11:40:36 +0100
Subject: Re: [PATCH] mm: vmalloc: Remove double execution of vunmap_page_range
References: <1523611019-17679-1-git-send-email-cpandya@codeaurora.org>
 <a623e12b-bb5e-58fa-c026-de9ea53c5bd9@linux.vnet.ibm.com>
 <8da9f826-2a3d-e618-e512-4fc8d45c16f2@codeaurora.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 13 Apr 2018 16:10:29 +0530
MIME-Version: 1.0
In-Reply-To: <8da9f826-2a3d-e618-e512-4fc8d45c16f2@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <bbef0a92-f81b-5ba8-c5c1-d8c08444955b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/13/2018 03:47 PM, Chintan Pandya wrote:
> 
> 
> On 4/13/2018 3:29 PM, Anshuman Khandual wrote:
>> On 04/13/2018 02:46 PM, Chintan Pandya wrote:
>>> Unmap legs do call vunmap_page_range() irrespective of
>>> debug_pagealloc_enabled() is enabled or not. So, remove
>>> redundant check and optional vunmap_page_range() routines.
>>
>> vunmap_page_range() tears down the page table entries and does
>> not really flush related TLB entries normally unless page alloc
>> debug is enabled where it wants to make sure no stale mapping is
>> still around for debug purpose. Deferring TLB flush improves
>> performance. This patch will force TLB flush during each page
>> table tear down and hence not desirable.
>>
> Deferred TLB invalidation will surely improve performance. But force
> flush can help in detecting invalid access right then and there. I

Deferred TLB invalidation was a choice made some time ago with the
commit db64fe02258f1507e ("mm: rewrite vmap layer") as these vmalloc
mappings wont be used other than inside the kernel and TLB gets
flushed when they are reused. This way it can still avail the benefit
of deferred TLB flushing without exposing itself to invalid accesses.

> chose later. May be I should have clean up the vmap tear down code
> as well where it actually does the TLB invalidation.
> 
> Or make TLB invalidation in free_unmap_vmap_area() be dependent upon
> debug_pagealloc_enabled().

Immediate TLB invalidation needs to be dependent on debug_pagealloc_
enabled() and should be done only for debug purpose. Contrary to that
is not desirable.
