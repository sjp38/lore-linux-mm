Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id C93696B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 20:22:51 -0400 (EDT)
Received: by igbqq3 with SMTP id qq3so3066979igb.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 17:22:51 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id 2si5181181igt.56.2015.06.17.17.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 17:22:51 -0700 (PDT)
Received: by iecrd14 with SMTP id rd14so44879679iec.3
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 17:22:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKSJeFKR+jWYiMiexvqGyBQe-=hGmq0DO0TZK-EQszTwcbmG4A@mail.gmail.com>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
	<557E6C0C.3050802@monom.org>
	<CAKSJeFKR+jWYiMiexvqGyBQe-=hGmq0DO0TZK-EQszTwcbmG4A@mail.gmail.com>
Date: Thu, 18 Jun 2015 01:22:50 +0100
Message-ID: <CANsGZ6aEKYgnGZyqO8VrpL8t=68Fwzt5WYbjtC7Nzq0uKPteUw@mail.gmail.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Morten Stevens <mstevens@fedoraproject.org>
Cc: Daniel Wagner <wagi@monom.org>, Linus Torvalds <torvalds@linux-foundation.org>, Prarit Bhargava <prarit@redhat.com>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

 Wed, Jun 17, 2015 at 12:45 PM, Morten Stevens
<mstevens@fedoraproject.org> wrote:
> 2015-06-15 8:09 GMT+02:00 Daniel Wagner <wagi@monom.org>:
>> On 06/14/2015 06:48 PM, Hugh Dickins wrote:
>>> It appears that, at some point last year, XFS made directory handling
>>> changes which bring it into lockdep conflict with shmem_zero_setup():
>>> it is surprising that mmap() can clone an inode while holding mmap_sem,
>>> but that has been so for many years.
>>>
>>> Since those few lockdep traces that I've seen all implicated selinux,
>>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
>>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
>>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
>>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
>>>
>>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
>>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
>>> which cloned inode in mmap(), but if so, I cannot locate them now.
>>>
>>> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
>>> Reported-by: Daniel Wagner <wagi@monom.org>
>>
>> Reported-and-tested-by: Daniel Wagner <wagi@monom.org>
>>
>> Sorry for the long delay. It took me a while to figure out my original
>> setup. I could verify that this patch made the lockdep message go away
>> on 4.0-rc6 and also on 4.1-rc8.
>
> Yes, it's also fixed for me after applying this patch to 4.1-rc8.

Thank you - Hugh

>
> Best regards,
>
> Morten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
