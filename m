Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 51C546B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 14:28:06 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id y10so771241pdj.32
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 11:28:05 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id iy3si587634pbb.214.2014.02.19.11.28.04
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 11:28:05 -0800 (PST)
Date: Wed, 19 Feb 2014 11:28:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 0/3] fix numa vs kvm scalability issue
Message-Id: <20140219112803.75c6daf470dad88eb10f5dab@linux-foundation.org>
In-Reply-To: <20140219085917.GJ27965@twins.programming.kicks-ass.net>
References: <1392761566-24834-1-git-send-email-riel@redhat.com>
	<20140219085917.GJ27965@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: riel@redhat.com, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, chegu_vinod@hp.com, aarcange@redhat.com

On Wed, 19 Feb 2014 09:59:17 +0100 Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Feb 18, 2014 at 05:12:43PM -0500, riel@redhat.com wrote:
> > The NUMA scanning code can end up iterating over many gigabytes
> > of unpopulated memory, especially in the case of a freshly started
> > KVM guest with lots of memory.
> > 
> > This results in the mmu notifier code being called even when
> > there are no mapped pages in a virtual address range. The amount
> > of time wasted can be enough to trigger soft lockup warnings
> > with very large (>2TB) KVM guests.
> > 
> > This patch moves the mmu notifier call to the pmd level, which
> > represents 1GB areas of memory on x86-64. Furthermore, the mmu
> > notifier code is only called from the address in the PMD where
> > present mappings are first encountered.
> > 
> > The hugetlbfs code is left alone for now; hugetlb mappings are
> > not relocatable, and as such are left alone by the NUMA code,
> > and should never trigger this problem to begin with.
> > 
> > The series also adds a cond_resched to task_numa_work, to
> > fix another potential latency issue.
> 
> Andrew, I'll pick up the first kernel/sched/ patch; do you want the
> other two mm/ patches?

That works, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
