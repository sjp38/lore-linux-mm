Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 353426B0038
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 15:08:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id h16so533557wrf.0
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 12:08:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor6505wmb.87.2017.09.19.12.08.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 12:08:00 -0700 (PDT)
Subject: Re: [patch v2] madvise.2: Add MADV_WIPEONFORK documentation
References: <20170914130040.6faabb18@cuia.usersys.redhat.com>
 <CAAF6GDdnY2AmzKx+t4ffCFxJ+RZS++4tmWvoazdVNVSYjra_WA@mail.gmail.com>
 <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <a1715d1d-7a03-d2db-7a8a-8a2edceae5d1@gmail.com>
Date: Tue, 19 Sep 2017 21:07:56 +0200
MIME-Version: 1.0
In-Reply-To: <20170914150546.74ad3a9a@cuia.usersys.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, =?UTF-8?Q?Colm_MacC=c3=a1rthaigh?= <colm@allcosts.net>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, nilal@redhat.com, Florian Weimer <fweimer@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

Hello Rik, (and Colm)

On 09/14/2017 09:05 PM, Rik van Riel wrote:
> v2: implement the improvements suggested by Colm, and add
>     Colm's text to the fork.2 man page
>     (Colm, I have added a signed-off-by in your name - is that ok?)
> 
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

Thanks. I applied this, and tweaked the madvise.2 text a little, to
read as follows (please let me know if I messed anything up):

       MADV_WIPEONFORK (since Linux 4.14)
              Present the child process with zero-filled memory  in  this
              range  after  a fork(2).  This is useful in forking servers
              in order to ensure that  sensitive  per-process  data  (for
              example,  PRNG  seeds, cryptographic secrets, and so on) is
              not handed to child processes.

              The MADV_WIPEONFORK operation can be applied only  to  pria??
              vate anonymous pages (see mmap(2)).

Thanks,

Michael


> Signed-off-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Colm MacCA!rthaigh <colm@allcosts.net>
> 
> diff --git a/man2/fork.2 b/man2/fork.2
> index b5af58ca08c0..b11e750e3876 100644
> --- a/man2/fork.2
> +++ b/man2/fork.2
> @@ -140,6 +140,12 @@ Memory mappings that have been marked with the
>  flag are not inherited across a
>  .BR fork ().
>  .IP *
> +Memory in mappings that have been marked with the
> +.BR madvise (2)
> +.B MADV_WIPEONFORK
> +flag is zeroed in the child after a
> +.BR fork ().
> +.IP *
>  The termination signal of the child is always
>  .B SIGCHLD
>  (see
> diff --git a/man2/madvise.2 b/man2/madvise.2
> index dfb31b63dba3..bb0ac469c509 100644
> --- a/man2/madvise.2
> +++ b/man2/madvise.2
> @@ -31,6 +31,9 @@
>  .\" 2010-06-19, Andi Kleen, Add documentation of MADV_SOFT_OFFLINE.
>  .\" 2011-09-18, Doug Goldstein <cardoe@cardoe.com>
>  .\"     Document MADV_HUGEPAGE and MADV_NOHUGEPAGE
> +.\" 2017-09-14, Rik van Riel <riel@redhat.com>
> +.\"     Document MADV_WIPEONFORK and MADV_KEEPONFORK
> +.\" commit d2cd9ede6e193dd7d88b6d27399e96229a551b19
>  .\"
>  .TH MADVISE 2 2017-07-13 "Linux" "Linux Programmer's Manual"
>  .SH NAME
> @@ -405,6 +408,22 @@ can be applied only to private anonymous pages (see
>  .BR mmap (2)).
>  On a swapless system, freeing pages in a given range happens instantly,
>  regardless of memory pressure.
> +.TP
> +.BR MADV_WIPEONFORK " (since Linux 4.14)"
> +Present the child process with zero-filled memory in this range after a
> +.BR fork (2).
> +This is useful for per-process data in forking servers that should be
> +re-initialized in the child process after a fork, for example PRNG seeds,
> +cryptographic secrets, etc.
> +.IP
> +The
> +.B MADV_WIPEONFORK
> +operation can only be applied to private anonymous pages (see
> +.BR mmap (2)).
> +.TP
> +.BR MADV_KEEPONFORK " (since Linux 4.14)"
> +Undo the effect of an earlier
> +.BR MADV_WIPEONFORK .
>  .SH RETURN VALUE
>  On success,
>  .BR madvise ()
> @@ -457,6 +476,18 @@ or
>  but the kernel was not configured with
>  .BR CONFIG_KSM .
>  .TP
> +.B EINVAL
> +.I advice
> +is
> +.BR MADV_FREE
> +or
> +.BR MADV_WIPEONFORK
> +but the specified address range includes file, Huge TLB,
> +.BR MAP_SHARED ,
> +or
> +.BR VM_PFNMAP
> +ranges.
> +.TP
>  .B EIO
>  (for
>  .BR MADV_WILLNEED )
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
