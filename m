Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0126B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 01:10:45 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1191635pab.21
        for <linux-mm@kvack.org>; Tue, 13 May 2014 22:10:45 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id ef1si368559pbc.257.2014.05.13.22.10.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 22:10:44 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so1191611pab.21
        for <linux-mm@kvack.org>; Tue, 13 May 2014 22:10:44 -0700 (PDT)
Date: Tue, 13 May 2014 22:09:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 0/3] File Sealing & memfd_create()
In-Reply-To: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1405132118330.4401@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Tue, 15 Apr 2014, David Herrmann wrote:
> 
> This is v2 of the File-Sealing and memfd_create() patches. You can find v1 with
> a longer introduction at gmane:
>   http://thread.gmane.org/gmane.comp.video.dri.devel/102241
> An LWN article about memfd+sealing is available, too:
>   https://lwn.net/Articles/593918/

Sorry it's taken so long: at last I managed to set aside a few hours at
the weekend, to read through your memfd+sealing work and let it sink in.

Good stuff.  I've a page of notes which I shall respond with, either
later in the week or at the weekend; but they're pretty much trivia, or
notes to myself, beside the async I/O issue raised by Tony Battersby.

I thought I'd better not wait longer to give warning that I do take
that issue seriously.

> 
> Shortlog of changes since v1:
>  - Dropped the "exclusive reference" idea
>    Now sealing is a one-shot operation. Once a given seal is set, you cannot
>    remove this seal again, ever. This allows us to drop all the ref-count
>    checking and simplifies the code a lot. We also no longer have all the races
>    we have to test for.
>  - The i_writecount fix is now upstream (slightly different, by Al Viro) so I
>    dropped it from the series.
>  - Change SHMEM_* prefix to F_* to avoid any API-association to shmem.
>  - Sealing is disabled on all files by default (even though we still haven't
>    found any DoS attack). You need to pass MFD_ALLOW_SEALING to memfd_create()
>    to get an object that supports the sealing API.
>  - Changed F_SET_SEALS to F_ADD_SEALS. This better reflects the API. You can
>    never remove seals, you can only add seals. Note that the semantics also
>    changed slightly: You can now _always_ call F_ADD_SEALS to add _more_ seals.
>    However, a new seal was added which "seals sealing" (F_SEAL_SEAL). So once
>    F_SEAL_SEAL is set, F_ADD_SEAL is no longer allowed.
>    This feature was requested by the glib developers.
>  - memfd_create() names are now limited to NAME_MAX instead of 256 hardcoded.
>  - Rewrote the test suite
> 
> The biggest change in v2 is the removal of the "exclusive reference" idea. It
> was a nice optimization, but the implementation was ugly and racy regarding
> file-table changes. Linus didn't like it either so we decided to drop it
> entirely. Sealing is a one-shot operation now. A sealed file can never be
> unsealed, even if you're the only holder.
> 
> I also addressed most of the concerns regarding API naming and semantics. I got
> feedback from glib, EFL, wayland, kdbus, ostree, audio developers and we
> discussed many possible use-cases (and also cases that don't make sense). So I
> think we're in a very good state right now.
> 
> People requested to make this interface more generic. I renamed the API to
> reflect that, but I didn't change the implementation. Thing is, seals cannot be
> removed, ever. Therefore, semantics for sealing on non-volatile storage are
> undefined. We don't write them to disc and it is unclear whether a sealed file
> can be unlinked/removed again. There're more issues with this and no-one came up
> with a use-case, hence I didn't bother implementing it.
> There's also an ongoing discussion about an AIO race, but this also affects
> other inode-protections like S_IMMUTABLE/etc. So I don't think we should tie
> the fix to this series.

I disagree on that.

Whatever the bugs or limitations with S_IMMUTABLE, ETXTBSY etc,
we have lived with those without complaint for many years.

You now propose an entirely new kind of guarantee, but that guarantee
is broken by the possibility of outstanding async I/O to a page of the
sealed object.

I don't see how we can add the new feature while knowing it broken.  We
have to devise a solution, but I haven't thought of a good solution yet.

Checking page counts in a GB file prior to sealing does not appeal at
all: we'd be lucky ever to find them all accounted for.  Adding overhead
to get_user_pages_fast() won't appeal to its adherents, and I'm not even
convinced that GUP is the only way in here.

Any ideas?

> Another discussion was about preventing /proc/self/fd/. But again, no-one could
> tell me _why_, so I didn't bother. On the contrary, I even provided several
> use-cases that make use of /proc/self/fd/ to get read-only FDs to pass around.
> 
> If anyone wants to test this, please use 3.15-rc1 as base. The i_writecount
> fixes are required for this series.
> 
> Comments welcome!
> David
> 
> David Herrmann (3):
>   shm: add sealing API
>   shm: add memfd_create() syscall
>   selftests: add memfd_create() + sealing tests
> 
>  arch/x86/syscalls/syscall_32.tbl           |   1 +
>  arch/x86/syscalls/syscall_64.tbl           |   1 +
>  fs/fcntl.c                                 |   5 +
>  include/linux/shmem_fs.h                   |  20 +
>  include/linux/syscalls.h                   |   1 +
>  include/uapi/linux/fcntl.h                 |  15 +
>  include/uapi/linux/memfd.h                 |  10 +
>  kernel/sys_ni.c                            |   1 +
>  mm/shmem.c                                 | 236 +++++++-
>  tools/testing/selftests/Makefile           |   1 +
>  tools/testing/selftests/memfd/.gitignore   |   2 +
>  tools/testing/selftests/memfd/Makefile     |  29 +
>  tools/testing/selftests/memfd/memfd_test.c | 944 +++++++++++++++++++++++++++++
>  13 files changed, 1263 insertions(+), 3 deletions(-)
>  create mode 100644 include/uapi/linux/memfd.h
>  create mode 100644 tools/testing/selftests/memfd/.gitignore
>  create mode 100644 tools/testing/selftests/memfd/Makefile
>  create mode 100644 tools/testing/selftests/memfd/memfd_test.c
> 
> -- 
> 1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
