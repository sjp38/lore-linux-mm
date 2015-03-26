Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2D55D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 15:39:06 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so72191247pdb.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 12:39:05 -0700 (PDT)
Received: from x35.xmailserver.org (x35.xmailserver.org. [64.71.152.41])
        by mx.google.com with ESMTPS id ri8si9590750pbc.225.2015.03.26.12.39.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 12:39:05 -0700 (PDT)
Received: from davide-lnx3.corp.ebay.com
	by x35.xmailserver.org with [XMail 1.27 ESMTP Server]
	id <S423AA1> for <linux-mm@kvack.org> from <davidel@xmailserver.org>;
	Thu, 26 Mar 2015 15:39:14 -0400
Date: Thu, 26 Mar 2015 12:39:00 -0700 (PDT)
From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB
 aligned
In-Reply-To: <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com> <alpine.DEB.2.10.1503260431290.2755@mbplnx>
 <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, 26 Mar 2015, David Rientjes wrote:

> Yes, this munmap() behavior of lengths <= hugepage_size - PAGE_SIZE for a 
> hugetlb vma is long standing and there may be applications that break as a 
> result of changing the behavior: a database that reserves all allocated 
> hugetlb memory with mmap() so that it always has exclusive access to those 
> hugepages, whether they are faulted or not, and maintains its own hugepage 
> pool (which is common), may test the return value of munmap() and depend 
> on it returning -EINVAL to determine if it is freeing memory that was 
> either dynamically allocated or mapped from the hugetlb reserved pool.

You went a long way to create such a case.
But, in your case, that application will erroneously considering hugepage 
mmaped memory, as dynamically allocated, since it will always get EINVAL, 
unless it passes an aligned size. Aligned size, which a fix like the one 
posted in the patch will still leave as success.
OTOH, an application, which might be more common than the one you posted,
which calls munmap() to release a pointer which it validly got from a 
previous mmap(), will leak huge pages as all the issued munmaps will fail.


> If we were to go back in time and decide this when the munmap() behavior 
> for hugetlb vmas was originally introduced, that would be valid.  The 
> problem is that it could lead to userspace breakage and that's a 
> non-starter.
> 
> What we can do is improve the documentation and man-page to clearly 
> specify the long-standing behavior so that nobody encounters unexpected 
> results in the future.

This way you will leave the mmap API with broken semantics.
In any case, I am done arguing.
I will leave to Andrew to sort it out, and to Michael Kerrisk to update 
the mmap man pages with the new funny behaviour.



- Davide


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
