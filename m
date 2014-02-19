Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 26D2B6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 22:08:58 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id k14so3881420wgh.23
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 19:08:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id hl20si14056248wib.63.2014.02.18.19.08.55
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 19:08:56 -0800 (PST)
Message-ID: <5304202B.20203@redhat.com>
Date: Tue, 18 Feb 2014 22:08:27 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 3/3] move mmu notifier call from change_protection
 to change_pmd_range
References: <1392761566-24834-1-git-send-email-riel@redhat.com> <1392761566-24834-4-git-send-email-riel@redhat.com> <alpine.DEB.2.02.1402181823420.20791@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1402181823420.20791@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

On 02/18/2014 09:24 PM, David Rientjes wrote:
> On Tue, 18 Feb 2014, riel@redhat.com wrote:
> 
>> From: Rik van Riel <riel@redhat.com>
>>
>> The NUMA scanning code can end up iterating over many gigabytes
>> of unpopulated memory, especially in the case of a freshly started
>> KVM guest with lots of memory.
>>
>> This results in the mmu notifier code being called even when
>> there are no mapped pages in a virtual address range. The amount
>> of time wasted can be enough to trigger soft lockup warnings
>> with very large KVM guests.
>>
>> This patch moves the mmu notifier call to the pmd level, which
>> represents 1GB areas of memory on x86-64. Furthermore, the mmu
>> notifier code is only called from the address in the PMD where
>> present mappings are first encountered.
>>
>> The hugetlbfs code is left alone for now; hugetlb mappings are
>> not relocatable, and as such are left alone by the NUMA code,
>> and should never trigger this problem to begin with.
>>
>> Signed-off-by: Rik van Riel <riel@redhat.com>
>> Cc: Peter Zijlstra <peterz@infradead.org>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Reported-by: Xing Gang <gang.xing@hp.com>
>> Tested-by: Chegu Vinod <chegu_vinod@hp.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Might have been cleaner to move the 
> mmu_notifier_invalidate_range_{start,end}() to hugetlb_change_protection() 
> as well, though.

I can certainly do that if you want.  Just let me know
and I'll send a v2 of patch 3 :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
