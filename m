Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 372B76B0268
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 13:13:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id h70so9911565ioi.5
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 10:13:13 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u83si2766807itf.43.2017.11.03.10.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 10:13:12 -0700 (PDT)
Subject: Re: [PATCH 4/6] hugetlbfs: implement memfd sealing
References: <20171031184052.25253-1-marcandre.lureau@redhat.com>
 <20171031184052.25253-5-marcandre.lureau@redhat.com>
 <CANq1E4SC8Hi4h9hxUM70+qOL4K95cXuMF9DKGw4dGhfmktrqsA@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ca908533-2905-e28a-db3a-c3cf9c98bbed@oracle.com>
Date: Fri, 3 Nov 2017 10:12:59 -0700
MIME-Version: 1.0
In-Reply-To: <CANq1E4SC8Hi4h9hxUM70+qOL4K95cXuMF9DKGw4dGhfmktrqsA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, aarcange@redhat.com, Hugh Dickins <hughd@google.com>, nyc@holomorphy.com

On 11/03/2017 10:03 AM, David Herrmann wrote:
> Hi
> 
> On Tue, Oct 31, 2017 at 7:40 PM, Marc-AndrA(C) Lureau
> <marcandre.lureau@redhat.com> wrote:
>> Implements memfd sealing, similar to shmem:
>> - WRITE: deny fallocate(PUNCH_HOLE). mmap() write is denied in
>>   memfd_add_seals(). write() doesn't exist for hugetlbfs.
>> - SHRINK: added similar check as shmem_setattr()
>> - GROW: added similar check as shmem_setattr() & shmem_fallocate()
>>
>> Except write() operation that doesn't exist with hugetlbfs, that
>> should make sealing as close as it can be to shmem support.
> 
> SEAL, SHRINK, and GROW look fine to me.
> 
> Regarding WRITE

The commit message may not be clear.  However, hugetlbfs does not support
the write system call (or aio).  The only way to modify contents of a
hugetlbfs file is via mmap or hole punch/truncate.  So, we do not really
need to worry about those special (a)io cases for hugetlbfs.

-- 
Mike Kravetz

>                 you need to make sure there are no page references
> left around. For instance, on shmem any process might trigger the
> kernel to GUP mapped shmem pages for asynchronous IO, then unmap the
> file and request F_SEAL_WRITE. In this case the seal must be rejected
> *iff* the pages are still pinned. shmem does this by requiring the
> page-refcounts to be 0. Preferably there would be some better
> infrastructure that tells us whether someone operates on those pages,
> but this does not exist right now. See shmem_wait_for_pins() for
> details.
> 
> I have little knowledge on how hugetlbs integrate with the page-cache
> and radix-tree, hence I'd prefer if someone can explicitly ACK that
> shmem_wait_for_pins() is suitable for hugetlbfs.
> 
> Otherwise, this series looks good to me (minus the #ifdef mess..).
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
