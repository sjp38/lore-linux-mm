Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F32E6B0033
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:56:24 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f16so10237339ioe.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 10:56:24 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r139si6099229ior.36.2017.11.03.10.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 10:56:21 -0700 (PDT)
Subject: Re: [PATCH 4/6] hugetlbfs: implement memfd sealing
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-5-marcandre.lureau@redhat.com>
 <CANq1E4SC8Hi4h9hxUM70+qOL4K95cXuMF9DKGw4dGhfmktrqsA@mail.gmail.com>
 <ca908533-2905-e28a-db3a-c3cf9c98bbed@oracle.com>
 <CANq1E4Tb5zuMxwuHFjLBJ==H219ucmO2=V7iM+K7AAuY-iinoQ@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <15b59408-7c4d-bbdb-7573-5789faa05e6c@oracle.com>
Date: Fri, 3 Nov 2017 10:56:11 -0700
MIME-Version: 1.0
In-Reply-To: <CANq1E4Tb5zuMxwuHFjLBJ==H219ucmO2=V7iM+K7AAuY-iinoQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, aarcange@redhat.com, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com

On 11/03/2017 10:41 AM, David Herrmann wrote:
> Hi
> 
> On Fri, Nov 3, 2017 at 6:12 PM, Mike Kravetz <mike.kravetz@oracle.com> wrote:
>> On 11/03/2017 10:03 AM, David Herrmann wrote:
>>> Hi
>>>
>>> On Tue, Oct 31, 2017 at 7:40 PM, Marc-AndrA(C) Lureau
>>> <marcandre.lureau@redhat.com> wrote:
>>>> Implements memfd sealing, similar to shmem:
>>>> - WRITE: deny fallocate(PUNCH_HOLE). mmap() write is denied in
>>>>   memfd_add_seals(). write() doesn't exist for hugetlbfs.
>>>> - SHRINK: added similar check as shmem_setattr()
>>>> - GROW: added similar check as shmem_setattr() & shmem_fallocate()
>>>>
>>>> Except write() operation that doesn't exist with hugetlbfs, that
>>>> should make sealing as close as it can be to shmem support.
>>>
>>> SEAL, SHRINK, and GROW look fine to me.
>>>
>>> Regarding WRITE
>>
>> The commit message may not be clear.  However, hugetlbfs does not support
>> the write system call (or aio).  The only way to modify contents of a
>> hugetlbfs file is via mmap or hole punch/truncate.  So, we do not really
>> need to worry about those special (a)io cases for hugetlbfs.
> 
> This is not about the write(2) syscall. Please consider this scenario
> about shmem:
> 
> You create a memfd via memfd_create() and map it writable. You now
> call another kernel syscall that takes as input _any mapped page
> range_. You pass your mapped memfd-addresses to it. Those syscalls
> tend to use get_user_pages() to pin arbitrary user-mapped pages, as
> such this also affects shmem. In this case, those pages might stay
> mapped even if you munmap() your memfd!
> 
> One example of this is using AIO-read() on any other file that
> supports it, passing your mapped memfd as buffer to _read into_. The
> operations supported on the memfd are irrelevant here.
> The selftests contain a FUSE-based test for this, since FUSE allows
> user-space to GUP pages for an arbitrary amount of time.
> 
> The original fix for this is:
> 
>     commit 05f65b5c70909ef686f865f0a85406d74d75f70f
>     Author: David Herrmann <dh.herrmann@gmail.com>
>     Date:   Fri Aug 8 14:25:36 2014 -0700
> 
>         shm: wait for pins to be released when sealing
> 
> Please have a look at this. Your patches use shmem_add_seals() almost
> unchanged, and as such you call into shmem_wait_for_pins() on
> hugetlbfs. I would really like to see an explicit ACK that this works
> on hugetlbfs.

Thanks for the explanation.  I missed that in your first reply.  I'll
look into this for hugetlbfs.

-- 
Mike Kravetz

> 
> Thanks
> David
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
