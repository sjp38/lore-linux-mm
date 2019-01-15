Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 455C08E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:37:06 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id a11so1330336wmh.2
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:37:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g127sor20468329wmf.27.2019.01.15.09.37.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 09:37:04 -0800 (PST)
MIME-Version: 1.0
References: <20190112203816.85534-1-joel@joelfernandes.org> <20190112203816.85534-2-joel@joelfernandes.org>
In-Reply-To: <20190112203816.85534-2-joel@joelfernandes.org>
From: John Stultz <john.stultz@linaro.org>
Date: Tue, 15 Jan 2019 09:36:52 -0800
Message-ID: <CALAqxLXFvktP+k8AWPEoT=-MM_vdu=1hzgzPYEzhSp8hXd-ADg@mail.gmail.com>
Subject: Re: [PATCH v4 1/2] mm/memfd: Add an F_SEAL_FUTURE_WRITE seal to memfd
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: lkml <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, Hugh Dickins <hughd@google.com>, Jann Horn <jannh@google.com>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-mm <linux-mm@kvack.org>, =?UTF-8?B?TWFyYy1BbmRyw6kgTHVyZWF1?= <marcandre.lureau@redhat.com>, Matthew Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>, Minchan Kim <minchan@kernel.org>, Shuah Khan <shuah@kernel.org>

On Sat, Jan 12, 2019 at 12:38 PM Joel Fernandes <joel@joelfernandes.org> wrote:
>
> From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
>
> Android uses ashmem for sharing memory regions.  We are looking forward to
> migrating all usecases of ashmem to memfd so that we can possibly remove
> the ashmem driver in the future from staging while also benefiting from
> using memfd and contributing to it.  Note staging drivers are also not ABI
> and generally can be removed at anytime.
>
> One of the main usecases Android has is the ability to create a region and
> mmap it as writeable, then add protection against making any "future"
> writes while keeping the existing already mmap'ed writeable-region active.
> This allows us to implement a usecase where receivers of the shared
> memory buffer can get a read-only view, while the sender continues to
> write to the buffer.  See CursorWindow documentation in Android for more
> details:
> https://developer.android.com/reference/android/database/CursorWindow
>
> This usecase cannot be implemented with the existing F_SEAL_WRITE seal.
> To support the usecase, this patch adds a new F_SEAL_FUTURE_WRITE seal
> which prevents any future mmap and write syscalls from succeeding while
> keeping the existing mmap active.
>
> A better way to do F_SEAL_FUTURE_WRITE seal was discussed [1] last week
> where we don't need to modify core VFS structures to get the same
> behavior of the seal. This solves several side-effects pointed by Andy.
> self-tests are provided in later patch to verify the expected semantics.
>
> [1] https://lore.kernel.org/lkml/20181111173650.GA256781@google.com/
>
> [Thanks a lot to Andy for suggestions to improve code]
> Cc: Andy Lutomirski <luto@kernel.org>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> ---
>  fs/hugetlbfs/inode.c       |  2 +-
>  include/uapi/linux/fcntl.h |  1 +
>  mm/memfd.c                 |  3 ++-
>  mm/shmem.c                 | 25 ++++++++++++++++++++++---
>  4 files changed, 26 insertions(+), 5 deletions(-)

Acked-by: John Stultz <john.stultz@linaro.org>
