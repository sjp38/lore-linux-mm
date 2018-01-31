Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 073CF6B0005
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 09:40:54 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k38so8108141wre.23
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 06:40:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h90si14897102wrh.537.2018.01.31.06.40.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 06:40:52 -0800 (PST)
Date: Wed, 31 Jan 2018 06:33:09 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [LSF/MM TOPIC] Addressing mmap_sem contention
Message-ID: <20180131143309.vdlk6yo4eg5gzdhr@linux-n805>
References: <4c20d397-1268-ca0f-4986-af59bb31022c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <4c20d397-1268-ca0f-4986-af59bb31022c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>

On Mon, 29 Jan 2018, Laurent Dufour wrote:

>Hi,
>
>I would like to talk about the way to remove the mmap_sem contention we
>could see on large threaded systems.

'cause what's lsfmm without mmap_sem, right? ;)

>
>I already resurrected the Speculative Page Fault patchset from Peter
>Zijlstra [1]. This series allows concurrency between page fault handler and
>the other thread's activity. Running a massively threaded benchmark like
>ebizzy [2] on top of this kernel shows that there is an opportunity to
>scale far better on large systems (x2). But the SPF series is addressing
>only one part of the issue, and there is a need to address the other part
>of picture.
>
>There have been some discussions last year about the range locking but this
>has been put in hold, especially because this implies huge change in the
>kernel as the mmap_sem is used to protect so many resources (should we need
>to protect the process command line with the mmap_sem ?), and sometimes the
>assumption is made that the mmap_sem is protecting code against concurrency
>while it is not dealing clearly with the mmap_sem.
>
>This will be a massive change and rebasing such a series will be hard, so
>it may be far better to first agreed on best options to improve mmap_sem's
>performance and scalability. There are several additional options on the
>table, including range locking,    multiple fine-grained locks, etc...
>In addition, I would like to discuss the options and the best way to make
>the move smooth in breaking or replacing the mmap_sem.

I'd also like to discuss this stuff. In particular I've been focusing on
range locking the mm. With the range_lock primitive ready by now (including
rbtree optimizations), my priority as been converting mmap_sem and getting
adequate performance data for the worst case scenario (full range).

Also, fyi recently by means of auditing handle_mm_fault() and gup family,
two new naughty users were found that were doing gup() without mmap_sem:

https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/commit/?h=wip/dl-for-next&id=487f6683f1b738e40aca2386b9f73da4ebb8223d
https://lkml.org/lkml/2018/1/22/640

With a from-scratch conversion, it's been mostly pretty straightforward
although I've done some hacks along the way. In particular avoiding having
to teach file_operations about mmrange, which would be a gazillion times
more changes than what we already have. So removing the is_locked() check
for calls like zap_pmd_range(), thp (pmd_trans_huge_lock()),
vm_insert_page() (which I audited and all ->fault() users seem to correctly
set VM_MIXEDMAP, so we might be able to get rid of it, dunno).

All this said, yes, I hope to have the patches and numbers asap (way
before lsfmm).

>Peoples (sorry if I missed someone) :
>    Andrea Arcangeli
>    Davidlohr Bueso
>    Michal Hocko
>    Anshuman Khandual
>    Andi Kleen
>    Andrew Morton
>    Matthew Wilcox
>    Peter Zijlstra

I'd also add Kirill A. Shutemov.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
