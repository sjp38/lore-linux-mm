Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 281A06B0093
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:45:32 -0400 (EDT)
Received: by lbbwc1 with SMTP id wc1so29825107lbb.2
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 04:45:31 -0700 (PDT)
Received: from mx02.imt-systems.com (mx02.imt-systems.com. [212.224.83.171])
        by mx.google.com with ESMTPS id fk12si7329329wjc.153.2015.06.17.04.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 04:45:30 -0700 (PDT)
Received: from ucsinet10.imt-systems.com (ucsinet10.imt-systems.com [212.224.83.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx02.imt-systems.com (Postfix) with ESMTPS id 3mBPj42Z4hzMwm4L
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 13:45:28 +0200 (CEST)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	(authenticated bits=0)
	by ucsinet10.imt-systems.com (8.14.7/8.14.7) with ESMTP id t5HBjSdZ020371
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 13:45:28 +0200
Received: by wifx6 with SMTP id x6so50180682wif.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 04:45:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <557E6C0C.3050802@monom.org>
References: <alpine.LSU.2.11.1506140944380.11018@eggly.anvils>
	<557E6C0C.3050802@monom.org>
Date: Wed, 17 Jun 2015 13:45:27 +0200
Message-ID: <CAKSJeFKR+jWYiMiexvqGyBQe-=hGmq0DO0TZK-EQszTwcbmG4A@mail.gmail.com>
Subject: Re: mm: shmem_zero_setup skip security check and lockdep conflict
 with XFS
From: Morten Stevens <mstevens@fedoraproject.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wagner <wagi@monom.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Prarit Bhargava <prarit@redhat.com>, Morten Stevens <mstevens@fedoraproject.org>, Dave Chinner <david@fromorbit.com>, Eric Paris <eparis@redhat.com>, Eric Sandeen <esandeen@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2015-06-15 8:09 GMT+02:00 Daniel Wagner <wagi@monom.org>:
> On 06/14/2015 06:48 PM, Hugh Dickins wrote:
>> It appears that, at some point last year, XFS made directory handling
>> changes which bring it into lockdep conflict with shmem_zero_setup():
>> it is surprising that mmap() can clone an inode while holding mmap_sem,
>> but that has been so for many years.
>>
>> Since those few lockdep traces that I've seen all implicated selinux,
>> I'm hoping that we can use the __shmem_file_setup(,,,S_PRIVATE) which
>> v3.13's commit c7277090927a ("security: shmem: implement kernel private
>> shmem inodes") introduced to avoid LSM checks on kernel-internal inodes:
>> the mmap("/dev/zero") cloned inode is indeed a kernel-internal detail.
>>
>> This also covers the !CONFIG_SHMEM use of ramfs to support /dev/zero
>> (and MAP_SHARED|MAP_ANONYMOUS).  I thought there were also drivers
>> which cloned inode in mmap(), but if so, I cannot locate them now.
>>
>> Reported-and-tested-by: Prarit Bhargava <prarit@redhat.com>
>> Reported-by: Daniel Wagner <wagi@monom.org>
>
> Reported-and-tested-by: Daniel Wagner <wagi@monom.org>
>
> Sorry for the long delay. It took me a while to figure out my original
> setup. I could verify that this patch made the lockdep message go away
> on 4.0-rc6 and also on 4.1-rc8.

Yes, it's also fixed for me after applying this patch to 4.1-rc8.

Best regards,

Morten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
