Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 541976B0256
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 09:15:49 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so23654796wic.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 06:15:48 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id ej4si1031152wjd.145.2015.07.23.06.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 06:15:47 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so23738635wib.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 06:15:46 -0700 (PDT)
Message-ID: <55B0E900.8090207@gmail.com>
Date: Thu, 23 Jul 2015 15:15:44 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] mmap.2: document the munmap exception for underlying
 page size
References: <alpine.DEB.2.10.1507211736300.24133@chino.kir.corp.google.com> <55B027D3.4020608@oracle.com> <alpine.DEB.2.10.1507221646100.14953@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507221646100.14953@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: mtk.manpages@gmail.com, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Eric B Munson <emunson@akamai.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

On 07/23/2015 01:49 AM, David Rientjes wrote:
> On Wed, 22 Jul 2015, Mike Kravetz wrote:
> 
>> On 07/21/2015 05:41 PM, David Rientjes wrote:
>>> munmap(2) will fail with an errno of EINVAL for hugetlb memory if the
>>> length is not a multiple of the underlying page size.
>>>
>>> Documentation/vm/hugetlbpage.txt was updated to specify this behavior
>>> since Linux 4.1 in commit 80d6b94bd69a ("mm, doc: cleanup and clarify
>>> munmap behavior for hugetlb memory").
>>>
>>> Signed-off-by: David Rientjes <rientjes@google.com>
>>> ---
>>>   man2/mmap.2 | 4 ++++
>>>   1 file changed, 4 insertions(+)
>>>
>>> diff --git a/man2/mmap.2 b/man2/mmap.2
>>> --- a/man2/mmap.2
>>> +++ b/man2/mmap.2
>>> @@ -383,6 +383,10 @@ All pages containing a part
>>>   of the indicated range are unmapped, and subsequent references
>>>   to these pages will generate
>>>   .BR SIGSEGV .
>>> +An exception is when the underlying memory is not of the native page
>>> +size, such as hugetlb page sizes, whereas
>>> +.I length
>>> +must be a multiple of the underlying page size.
>>>   It is not an error if the
>>>   indicated range does not contain any mapped pages.
>>>   .SS Timestamps changes for file-backed mappings
>>>
>>> --
>>
>> Should we also add a similar comment for the mmap offset?  Currently
>> the man page says:
>>
>> "offset must be a multiple of the page size as returned by
>>  sysconf(_SC_PAGE_SIZE)."
>>
>> For hugetlbfs, I beieve the offset must be a multiple of the
>> hugetlb page size.  A similar comment/exception about using
>> the "underlying page size" would apply here as well.
>>
> 
> Yes, that makes sense, thanks.  We should also explicitly say that mmap(2) 
> automatically aligns length to be hugepage aligned if backed by hugetlbfs.

And, surely, it also does something similar for mmap()'s 'addr'
argument? 

I suggest we add a subsection to describe the HugeTLB differences. How 
about something like:

   Huge page (Huge TLB) mappings
       For  mappings  that  employ  huge pages, the requirements for the
       arguments  of  mmap()  and  munmap()  differ  somewhat  from  the
       requirements for mappings that use the native system page size.

       For mmap(), offset must be a multiple of the underlying huge page
       size.  The system automatically aligns length to be a multiple of
       the underlying huge page size.

       For  munmap(),  addr  and  length  must both be a multiple of the
       underlying huge page size.
?

Thanks,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
