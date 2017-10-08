Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id ED6366B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 11:39:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so22242630wmd.5
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 08:39:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u25sor1019139edi.20.2017.10.08.08.39.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 08:39:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJYFCiPhNVCMRVD-QpwsZk0wAKRXzFWcwVZDqLXxsxYfhFcVpg@mail.gmail.com>
References: <CAJYFCiPhNVCMRVD-QpwsZk0wAKRXzFWcwVZDqLXxsxYfhFcVpg@mail.gmail.com>
From: Yubin Ruan <ablacktshirt@gmail.com>
Date: Sun, 8 Oct 2017 23:39:34 +0800
Message-ID: <CAJYFCiPYHZse_52-k68i8thYGBCRXn5F=w=-Ra4_oqRN_CruZw@mail.gmail.com>
Subject: Re: shmat(2) returns page size aligned memory address
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-man <linux-man@vger.kernel.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, linux-mm@kvack.org

Cc linux-mm

2017-10-08 23:37 GMT+08:00 Yubin Ruan <ablacktshirt@gmail.com>:
> Hi Michael,
> At the current man page for shmat(2)[1], there is no mentioning
> whether the returned memory address of shmat(2) will be page size
> aligned or not. As that is quite important to many applications(e.g.,
> those that use locks heavily and would like to avoid some locks by
> some atomic guarantees provided by the CPU), it would be great to
> specify that for Linux.
>
> I walked down the current implementation of shmat(2) in the latest
> kernel src and found that shmat(2) does return a page size aligned
> memory address:
>
> SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
>  -> do_shmat(...)
>  -> do_mmap_pgoff(...)
>  -> do_mmap(...)
>  -> get_unmapped_area(...)
>  -> get_area(...) -> offset_in_page(addr)
>
> there is a `offset_in_page(addr)' assertion at the end and if that is
> true a -EINVAL would be returned, by which we can be sure that
> shmat(2) will return a page size aligned memory address on success[2].
>
> I will create a patch later if that is acceptable.
>
> Thanks,
> Yubin
>
> [1]: http://man7.org/linux/man-pages/man2/shmat.2.html
> [2]: there is also a `offset_in_page(2)' in get_unmapped_area(...),
> but that doesn't lead to -EINVAL...I am not sure whether the logic of
> that code is right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
