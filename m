Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3C3C6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:47:38 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so23569032wia.0
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 02:47:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu19si2408115wjc.14.2015.03.27.02.47.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 02:47:37 -0700 (PDT)
Message-ID: <55152737.6060404@suse.cz>
Date: Fri, 27 Mar 2015 10:47:35 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB aligned
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com> <alpine.DEB.2.10.1503260431290.2755@mbplnx> <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com> <alpine.DEB.2.10.1503261221470.5119@davide-lnx3> <alpine.DEB.2.10.1503261250430.9410@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503261250430.9410@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Davide Libenzi <davidel@xmailserver.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>

Might be too late in this thread, but in case you are going to continue and/or
repost:

[CC += linux-api@vger.kernel.org]
(also linux-man and Michael to match my other reply)

    Since this is a kernel-user-space API change, please CC linux-api@. The
kernel source file Documentation/SubmitChecklist notes that all Linux kernel
patches that change userspace interfaces should be CCed to
linux-api@vger.kernel.org, so that the various parties who are interested in API
changes are informed. For further information, see
https://www.kernel.org/doc/man-pages/linux-api-ml.html


On 03/26/2015 09:03 PM, David Rientjes wrote:
> On Thu, 26 Mar 2015, Davide Libenzi wrote:
> 
>> > Yes, this munmap() behavior of lengths <= hugepage_size - PAGE_SIZE for a 
>> > hugetlb vma is long standing and there may be applications that break as a 
>> > result of changing the behavior: a database that reserves all allocated 
>> > hugetlb memory with mmap() so that it always has exclusive access to those 
>> > hugepages, whether they are faulted or not, and maintains its own hugepage 
>> > pool (which is common), may test the return value of munmap() and depend 
>> > on it returning -EINVAL to determine if it is freeing memory that was 
>> > either dynamically allocated or mapped from the hugetlb reserved pool.
>> 
>> You went a long way to create such a case.
>> But, in your case, that application will erroneously considering hugepage 
>> mmaped memory, as dynamically allocated, since it will always get EINVAL, 
>> unless it passes an aligned size. Aligned size, which a fix like the one 
>> posted in the patch will still leave as success.
> 
> There was a patch proposed last week to add reserved pools to the 
> hugetlbfs mount option specifically for the case where a large database 
> wants sole reserved access to the hugepage pool.  This is why hugetlbfs 
> pages become reserved on mmap().  In that case, the database never wants 
> to do munmap() and instead maintains its own hugepage pool.
> 
> That makes the usual database case, mmap() all necessary hugetlb pages to 
> reserve them, even easier since they have historically had to maintain 
> this pool amongst various processes.
> 
> Is there a process out there that tests for munmap(ptr) == EINVAL and, if 
> true, returns ptr to its hugepage pool?  I can't say for certain that none 
> exist, that's why the potential for breakage exists.
> 
>> OTOH, an application, which might be more common than the one you posted,
>> which calls munmap() to release a pointer which it validly got from a 
>> previous mmap(), will leak huge pages as all the issued munmaps will fail.
>> 
> 
> That application would have to be ignoring an EINVAL return value.
> 
>> > If we were to go back in time and decide this when the munmap() behavior 
>> > for hugetlb vmas was originally introduced, that would be valid.  The 
>> > problem is that it could lead to userspace breakage and that's a 
>> > non-starter.
>> > 
>> > What we can do is improve the documentation and man-page to clearly 
>> > specify the long-standing behavior so that nobody encounters unexpected 
>> > results in the future.
>> 
>> This way you will leave the mmap API with broken semantics.
>> In any case, I am done arguing.
>> I will leave to Andrew to sort it out, and to Michael Kerrisk to update 
>> the mmap man pages with the new funny behaviour.
>> 
> 
> The behavior is certainly not new, it has always been the case for 
> munmap() on hugetlb vmas.
> 
> In a strict POSIX interpretation, it refers only to pages in the sense of
> what is returned by sysconf(_SC_PAGESIZE).  Such vmas are not backed by 
> any pages of size sysconf(_SC_PAGESIZE), so this behavior is undefined.  
> It would be best to modify the man page to explicitly state this for 
> MAP_HUGETLB.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
