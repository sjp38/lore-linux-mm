Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 48F456B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 05:45:49 -0400 (EDT)
Received: by wgra20 with SMTP id a20so92862748wgr.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 02:45:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f9si2374167wjx.87.2015.03.27.02.45.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Mar 2015 02:45:47 -0700 (PDT)
Message-ID: <551526C8.1000105@suse.cz>
Date: Fri, 27 Mar 2015 10:45:44 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB aligned
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3> <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3> <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com> <alpine.DEB.2.10.1503260431290.2755@mbplnx> <alpine.DEB.2.10.1503261201440.8238@chino.kir.corp.google.com> <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
In-Reply-To: <alpine.DEB.2.10.1503261221470.5119@davide-lnx3>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davide Libenzi <davidel@xmailserver.org>, David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>

On 03/26/2015 08:39 PM, Davide Libenzi wrote:
> On Thu, 26 Mar 2015, David Rientjes wrote:
> 
>> Yes, this munmap() behavior of lengths <= hugepage_size - PAGE_SIZE for a 
>> hugetlb vma is long standing and there may be applications that break as a 
>> result of changing the behavior: a database that reserves all allocated 
>> hugetlb memory with mmap() so that it always has exclusive access to those 
>> hugepages, whether they are faulted or not, and maintains its own hugepage 
>> pool (which is common), may test the return value of munmap() and depend 
>> on it returning -EINVAL to determine if it is freeing memory that was 
>> either dynamically allocated or mapped from the hugetlb reserved pool.
> 
> You went a long way to create such a case.
> But, in your case, that application will erroneously considering hugepage 
> mmaped memory, as dynamically allocated, since it will always get EINVAL, 
> unless it passes an aligned size. Aligned size, which a fix like the one 
> posted in the patch will still leave as success.
> OTOH, an application, which might be more common than the one you posted,
> which calls munmap() to release a pointer which it validly got from a 
> previous mmap(), will leak huge pages as all the issued munmaps will fail.
> 
> 
>> If we were to go back in time and decide this when the munmap() behavior 
>> for hugetlb vmas was originally introduced, that would be valid.  The 
>> problem is that it could lead to userspace breakage and that's a 
>> non-starter.
>> 
>> What we can do is improve the documentation and man-page to clearly 
>> specify the long-standing behavior so that nobody encounters unexpected 
>> results in the future.
> 
> This way you will leave the mmap API with broken semantics.
> In any case, I am done arguing.
> I will leave to Andrew to sort it out, and to Michael Kerrisk to update 
> the mmap man pages with the new funny behaviour.

+ CC's

You know that people don't always magically CC themselves, or read all of
lkml/linux-mm? :)

> 
> 
> - Davide
> 
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
