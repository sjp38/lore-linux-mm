Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 14CB96B0038
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:13:05 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id e9so26704960qcy.15
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:13:04 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id h3si11300144qah.174.2014.02.18.14.12.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 14:13:03 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH -mm 0/3] fix numa vs kvm scalability issue
Date: Tue, 18 Feb 2014 17:12:43 -0500
Message-Id: <1392761566-24834-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, chegu_vinod@hp.com, aarcange@redhat.com, akpm@linux-foundation.org

The NUMA scanning code can end up iterating over many gigabytes
of unpopulated memory, especially in the case of a freshly started
KVM guest with lots of memory.

This results in the mmu notifier code being called even when
there are no mapped pages in a virtual address range. The amount
of time wasted can be enough to trigger soft lockup warnings
with very large (>2TB) KVM guests.

This patch moves the mmu notifier call to the pmd level, which
represents 1GB areas of memory on x86-64. Furthermore, the mmu
notifier code is only called from the address in the PMD where
present mappings are first encountered.

The hugetlbfs code is left alone for now; hugetlb mappings are
not relocatable, and as such are left alone by the NUMA code,
and should never trigger this problem to begin with.

The series also adds a cond_resched to task_numa_work, to
fix another potential latency issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
