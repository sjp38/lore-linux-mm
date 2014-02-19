Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 535366B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 21:24:39 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so16912693pde.6
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:24:38 -0800 (PST)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id yt9si20204300pab.33.2014.02.18.18.24.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 18:24:38 -0800 (PST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so17401139pab.6
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:24:38 -0800 (PST)
Date: Tue, 18 Feb 2014 18:24:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm 3/3] move mmu notifier call from change_protection
 to change_pmd_range
In-Reply-To: <1392761566-24834-4-git-send-email-riel@redhat.com>
Message-ID: <alpine.DEB.2.02.1402181823420.20791@chino.kir.corp.google.com>
References: <1392761566-24834-1-git-send-email-riel@redhat.com> <1392761566-24834-4-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

On Tue, 18 Feb 2014, riel@redhat.com wrote:

> From: Rik van Riel <riel@redhat.com>
> 
> The NUMA scanning code can end up iterating over many gigabytes
> of unpopulated memory, especially in the case of a freshly started
> KVM guest with lots of memory.
> 
> This results in the mmu notifier code being called even when
> there are no mapped pages in a virtual address range. The amount
> of time wasted can be enough to trigger soft lockup warnings
> with very large KVM guests.
> 
> This patch moves the mmu notifier call to the pmd level, which
> represents 1GB areas of memory on x86-64. Furthermore, the mmu
> notifier code is only called from the address in the PMD where
> present mappings are first encountered.
> 
> The hugetlbfs code is left alone for now; hugetlb mappings are
> not relocatable, and as such are left alone by the NUMA code,
> and should never trigger this problem to begin with.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Xing Gang <gang.xing@hp.com>
> Tested-by: Chegu Vinod <chegu_vinod@hp.com>

Acked-by: David Rientjes <rientjes@google.com>

Might have been cleaner to move the 
mmu_notifier_invalidate_range_{start,end}() to hugetlb_change_protection() 
as well, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
