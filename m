Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id A7C016B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 03:59:20 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id uq10so9051803igb.2
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 00:59:20 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id h2si25602950igg.66.2014.02.19.00.59.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 00:59:19 -0800 (PST)
Date: Wed, 19 Feb 2014 09:59:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH -mm 0/3] fix numa vs kvm scalability issue
Message-ID: <20140219085917.GJ27965@twins.programming.kicks-ass.net>
References: <1392761566-24834-1-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392761566-24834-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

On Tue, Feb 18, 2014 at 05:12:43PM -0500, riel@redhat.com wrote:
> The NUMA scanning code can end up iterating over many gigabytes
> of unpopulated memory, especially in the case of a freshly started
> KVM guest with lots of memory.
> 
> This results in the mmu notifier code being called even when
> there are no mapped pages in a virtual address range. The amount
> of time wasted can be enough to trigger soft lockup warnings
> with very large (>2TB) KVM guests.
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
> The series also adds a cond_resched to task_numa_work, to
> fix another potential latency issue.

Andrew, I'll pick up the first kernel/sched/ patch; do you want the
other two mm/ patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
