Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8406B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 17:57:16 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id h67-v6so30393wmh.0
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 14:57:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19-v6sor9333996wrc.13.2018.10.16.14.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 14:57:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20181009222042.9781-1-joel@joelfernandes.org>
References: <20181009222042.9781-1-joel@joelfernandes.org>
From: John Stultz <john.stultz@linaro.org>
Date: Tue, 16 Oct 2018 14:57:12 -0700
Message-ID: <CALAqxLXD-vghiMP51tVtL1Aw8OqT-QhCeNMdFSKiHpyq10-WCw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: Add an F_SEAL_FS_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Android Kernel Team <kernel-team@android.com>, John Reck <jreck@google.com>, Todd Kjos <tkjos@google.com>, Greg KH <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@google.com>, Shuah Khan <shuah@kernel.org>

On Tue, Oct 9, 2018 at 3:20 PM, Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
> Android uses ashmem for sharing memory regions. We are looking forward
> to migrating all usecases of ashmem to memfd so that we can possibly
> remove the ashmem driver in the future from staging while also
> benefiting from using memfd and contributing to it. Note staging drivers
> are also not ABI and generally can be removed at anytime.
>
> One of the main usecases Android has is the ability to create a region
> and mmap it as writeable, then drop its protection for "future" writes
> while keeping the existing already mmap'ed writeable-region active.
> This allows us to implement a usecase where receivers of the shared
> memory buffer can get a read-only view, while the sender continues to
> write to the buffer. See CursorWindow in Android for more details:
> https://developer.android.com/reference/android/database/CursorWindow
>
> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active. The following program shows the seal
> working in action:
>
> int main() {
>     int ret, fd;
>     void *addr, *addr2, *addr3, *addr1;
>     ret = memfd_create_region("test_region", REGION_SIZE);
>     printf("ret=%d\n", ret);
>     fd = ret;
>
>     // Create map
>     addr = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
>     if (addr == MAP_FAILED)
>             printf("map 0 failed\n");
>     else
>             printf("map 0 passed\n");
>
>     if ((ret = write(fd, "test", 4)) != 4)
>             printf("write failed even though no fs-write seal "
>                    "(ret=%d errno =%d)\n", ret, errno);
>     else
>             printf("write passed\n");
>
>     addr1 = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
>     if (addr1 == MAP_FAILED)
>             perror("map 1 prot-write failed even though no seal\n");
>     else
>             printf("map 1 prot-write passed as expected\n");
>
>     ret = fcntl(fd, F_ADD_SEALS, F_SEAL_FS_WRITE);
>     if (ret == -1)
>             printf("fcntl failed, errno: %d\n", errno);
>     else
>             printf("fs-write seal now active\n");
>
>     if ((ret = write(fd, "test", 4)) != 4)
>             printf("write failed as expected due to fs-write seal\n");
>     else
>             printf("write passed (unexpected)\n");
>
>     addr2 = mmap(0, REGION_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
>     if (addr2 == MAP_FAILED)
>             perror("map 2 prot-write failed as expected due to seal\n");
>     else
>             printf("map 2 passed\n");
>
>     addr3 = mmap(0, REGION_SIZE, PROT_READ, MAP_SHARED, fd, 0);
>     if (addr3 == MAP_FAILED)
>             perror("map 3 failed\n");
>     else
>             printf("map 3 prot-read passed as expected\n");
> }
>
> The output of running this program is as follows:
> ret=3
> map 0 passed
> write passed
> map 1 prot-write passed as expected
> fs-write seal now active
> write failed as expected due to fs-write seal
> map 2 prot-write failed as expected due to seal
> : Permission denied
> map 3 prot-read passed as expected
>
> Note: This seal will also prevent growing and shrinking of the memfd.
> This is not something we do in Android so it does not affect us, however
> I have mentioned this behavior of the seal in the manpage.
>
> Cc: jreck@google.com
> Cc: john.stultz@linaro.org
> Cc: tkjos@google.com
> Cc: gregkh@linuxfoundation.org
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>

Reviewed-by: John Stultz <john.stultz@linaro.org>

thanks
-john
