Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id C97866B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:03:14 -0400 (EDT)
Received: by iedm5 with SMTP id m5so55554297ied.3
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:03:14 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com. [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id r2si190171igh.60.2015.03.26.13.03.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 13:03:14 -0700 (PDT)
Received: by igcau2 with SMTP id au2so2227638igc.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:03:14 -0700 (PDT)
Date: Thu, 26 Mar 2015 13:03:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
Message-ID: <alpine.DEB.2.10.1503261250430.9410@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com> <alpine.DEB.2.10.1503260431290.2755@mbplnx>
 <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com> <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 26 Mar 2015, Davide Libenzi wrote:

> > Yes, this munmap() behavior of lengths <= hugepage_size - PAGE_SIZE for a 
> > hugetlb vma is long standing and there may be applications that break as a 
> > result of changing the behavior: a database that reserves all allocated 
> > hugetlb memory with mmap() so that it always has exclusive access to those 
> > hugepages, whether they are faulted or not, and maintains its own hugepage 
> > pool (which is common), may test the return value of munmap() and depend 
> > on it returning -EINVAL to determine if it is freeing memory that was 
> > either dynamically allocated or mapped from the hugetlb reserved pool.
> 
> You went a long way to create such a case.
> But, in your case, that application will erroneously considering hugepage 
> mmaped memory, as dynamically allocated, since it will always get EINVAL, 
> unless it passes an aligned size. Aligned size, which a fix like the one 
> posted in the patch will still leave as success.

There was a patch proposed last week to add reserved pools to the 
hugetlbfs mount option specifically for the case where a large database 
wants sole reserved access to the hugepage pool.  This is why hugetlbfs 
pages become reserved on mmap().  In that case, the database never wants 
to do munmap() and instead maintains its own hugepage pool.

That makes the usual database case, mmap() all necessary hugetlb pages to 
reserve them, even easier since they have historically had to maintain 
this pool amongst various processes.

Is there a process out there that tests for munmap(ptr) == EINVAL and, if 
true, returns ptr to its hugepage pool?  I can't say for certain that none 
exist, that's why the potential for breakage exists.

> OTOH, an application, which might be more common than the one you posted,
> which calls munmap() to release a pointer which it validly got from a 
> previous mmap(), will leak huge pages as all the issued munmaps will fail.
> 

That application would have to be ignoring an EINVAL return value.

> > If we were to go back in time and decide this when the munmap() behavior 
> > for hugetlb vmas was originally introduced, that would be valid.  The 
> > problem is that it could lead to userspace breakage and that's a 
> > non-starter.
> > 
> > What we can do is improve the documentation and man-page to clearly 
> > specify the long-standing behavior so that nobody encounters unexpected 
> > results in the future.
> 
> This way you will leave the mmap API with broken semantics.
> In any case, I am done arguing.
> I will leave to Andrew to sort it out, and to Michael Kerrisk to update 
> the mmap man pages with the new funny behaviour.
> 

The behavior is certainly not new, it has always been the case for 
munmap() on hugetlb vmas.

In a strict POSIX interpretation, it refers only to pages in the sense of
what is returned by sysconf(_SC_PAGESIZE).  Such vmas are not backed by 
any pages of size sysconf(_SC_PAGESIZE), so this behavior is undefined.  
It would be best to modify the man page to explicitly state this for 
MAP_HUGETLB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
