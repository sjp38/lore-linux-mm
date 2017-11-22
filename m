Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFBD6B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 19:40:24 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id w10so12193475qtb.4
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 16:40:24 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a187si3232742qke.468.2017.11.21.16.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 16:40:23 -0800 (PST)
Subject: Re: [RFC PATCH 0/3] restructure memfd code
References: <20171109014109.21077-1-mike.kravetz@oracle.com>
 <1511281935.14446.3.camel@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8d090981-629c-95fb-fe45-fe26b3c2165f@oracle.com>
Date: Tue, 21 Nov 2017 16:40:15 -0800
MIME-Version: 1.0
In-Reply-To: <1511281935.14446.3.camel@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, David Herrmann <dh.herrmann@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On 11/21/2017 08:32 AM, Khalid Aziz wrote:
> On Wed, 2017-11-08 at 17:41 -0800, Mike Kravetz wrote:
>> With the addition of memfd hugetlbfs support, we now have the
>> situation
>> where memfd depends on TMPFS -or- HUGETLBFS.  Previously, memfd was
>> only
>> supported on tmpfs, so it made sense that the code resides in
>> shmem.c.
>>
>> This patch series moves the memfd code to separate files (memfd.c and
>> memfd.h).  It creates a new config option MEMFD_CREATE that is
>> defined
>> if either TMPFS or HUGETLBFS is defined.
>>
>> In the current code, memfd is only functional if TMPFS is
>> defined.  If
>> HUGETLFS is defined and TMPFS is not defined, then memfd
>> functionality
>> will not be available for hugetlbfs.  This does not cause BUGs, just
>> a
>> potential lack of desired functionality.
>>
>> Another way to approach this issue would be to simply make HUGETLBFS
>> depend on TMPFS.
>>
>> This patch series is built on top of the Marc-AndrA(C) Lureau v3 series
>> "memfd: add sealing to hugetlb-backed memory":
>> http://lkml.kernel.org/r/20171107122800.25517-1-marcandre.lureau@redh
>> at.com
>>
>> Mike Kravetz (3):
>>   mm: hugetlbfs: move HUGETLBFS_I outside #ifdef CONFIG_HUGETLBFS
>>   mm: memfd: split out memfd for use by multiple filesystems
>>   mm: memfd: remove memfd code from shmem files and use new memfd
>> files
>>
> 
> Hi Mike,
> 
> This looks like a useful change. After applying patch 2, you end up
> with duplicate definitions of number of symbols though. Although those
> duplicates will not cause compilation problems since memfd.c is not
> compiled until after patch 3 has been applied, would it make more sense
> to combine moving of all code in one patch?

Thanks Khalid,

I was aware of this situation when creating the patch.  It was broken out
as above simply to make it easier to review/understand.  Not sure if that
is actually the case.  The other option was as you suggested to simply
combine the add/remove as a single patch.

I am somewhat waiting to see how Marc-AndrA(C) Lureau's file sealing series
progresses as this series touches the same code.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
