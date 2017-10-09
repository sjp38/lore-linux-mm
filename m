Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66D3C6B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 03:19:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so42596982pfj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 00:19:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor1037873plb.40.2017.10.09.00.19.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 00:19:04 -0700 (PDT)
Date: Mon, 9 Oct 2017 22:27:27 +0800
From: Yubin Ruan <ablacktshirt@gmail.com>
Subject: [PATCH] shmat(2) returns page size aligned memory address
Message-ID: <20171009092251.GC5758@HP>
References: <CAJYFCiPhNVCMRVD-QpwsZk0wAKRXzFWcwVZDqLXxsxYfhFcVpg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJYFCiPhNVCMRVD-QpwsZk0wAKRXzFWcwVZDqLXxsxYfhFcVpg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-man <linux-man@vger.kernel.org>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, linux-mm@kvack.org

On Sun, Oct 08, 2017 at 11:37:05PM +0800, Yubin Ruan wrote:
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

add the page-alignment attribute of the return address of shmat(2)
---

diff --git a/man2/shmop.2 b/man2/shmop.2
index 849529f..b8d7595 100644
--- a/man2/shmop.2
+++ b/man2/shmop.2
@@ -63,7 +63,7 @@ with one of the following criteria:
 If
 .I shmaddr
 is NULL,
-the system chooses a suitable (unused) address at which to attach
+the system chooses a suitable (unused) page-aligned address to attach
 the segment.
 .IP *
 If

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
