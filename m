Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4D56B0038
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 13:09:07 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d70so5064462qkc.3
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 10:09:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m124sor1388060qkd.100.2017.09.14.10.09.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Sep 2017 10:09:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170914130040.6faabb18@cuia.usersys.redhat.com>
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
From: =?UTF-8?Q?Colm_MacC=C3=A1rthaigh?= <colm@allcosts.net>
Date: Thu, 14 Sep 2017 10:09:05 -0700
Message-ID: <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
Subject: Re: [patch] madvise.2: Add MADV_WIPEONFORK documentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

Great change, just some suggestions ...

On Thu, Sep 14, 2017 at 10:00 AM, Rik van Riel <riel@redhat.com> wrote:
> Add MADV_WIPEONFORK and MADV_KEEPONFORK documentation to
> madvise.2.  The new functionality was recently merged by
> Linus, and should be in the 4.14 kernel.
>
> While documenting what EINVAL means for MADV_WIPEONFORK,
> I realized that MADV_FREE has the same thing going on,
> so I documented EINVAL for both in the ERRORS section.
>
> This patch documents the following kernel commit:
>
> commit d2cd9ede6e193dd7d88b6d27399e96229a551b19
> Author: Rik van Riel <riel@redhat.com>
> Date:   Wed Sep 6 16:25:15 2017 -0700
>
>     mm,fork: introduce MADV_WIPEONFORK
>
> Signed-off-by: Rik van Riel <riel@redhat.com>
>
> index dfb31b63dba3..4f987ddfae79 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -31,6 +31,8 @@
>  .\" 2010-06-19, Andi Kleen, Add documentation of MADV_SOFT_OFFLINE.
>  .\" 2011-09-18, Doug Goldstein <cardoe@cardoe.com>
>  .\"     Document MADV_HUGEPAGE and MADV_NOHUGEPAGE
> +.\" 2017-09-14, Rik van Riel <riel@redhat.com>
> +.\"     Document MADV_WIPEONFORK and MADV_KEEPONFORK
>  .\"

It seems to be idiomatic to reference the commit adding the options in
the hidden man-page comments.  Probably needs:

.\" commit d2cd9ede6e193dd7d88b6d27399e96229a551b19

here. (That's the commit adding MADV_WIPEONFORK/MADV_KEEPONFORK to Linus' tree.


>  .TH MADVISE 2 2017-07-13 "Linux" "Linux Programmer's Manual"
>  .SH NAME
> @@ -405,6 +407,22 @@ can be applied only to private anonymous pages (see
>  .BR mmap (2)).
>  On a swapless system, freeing pages in a given range happens instantly,
>  regardless of memory pressure.
> +.TP
> +.BR MADV_WIPEONFORK " (since Linux 4.14)"
> +Present the child process with zero-filled memory in this range after a
> +.BR fork (2).
> +This is useful for per-process data in forking servers that should be
> +re-initialized in the child process after a fork, for example PRNG seeds,
> +cryptographic data, etc.

Instead of cryptographic data, I would say more broadly "secrets" - to
help nudge best-practise. For example in an application that buffers
decrypted plaintext, it's smart to mark it as WIPEONFORK so that there
aren't unnecessary copies of the plaintext floating around.

I'd suggest patching fork.2 also, with something like:

index b5af58ca0..b11e750e3 100644
--- a/man2/fork.2
+++ b/man2/fork.2
@@ -140,6 +140,12 @@ Memory mappings that have been marked with the
 flag are not inherited across a
 .BR fork ().
 .IP *
+Memory in mappings that have been marked with the
+.BR madvise (2)
+.B MADV_WIPEONFORK
+flag is zeroed in the child after a
+.BR fork ().
+.IP *
 The termination signal of the child is always
 .B SIGCHLD
 (see



-- 
Colm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
