Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 05C156B0036
	for <linux-mm@kvack.org>; Sat, 15 Mar 2014 05:05:24 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id 6so248049bkj.41
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 02:05:24 -0700 (PDT)
Received: from mail-bk0-x234.google.com (mail-bk0-x234.google.com [2a00:1450:4008:c01::234])
        by mx.google.com with ESMTPS id ny9si3597703bkb.273.2014.03.15.02.05.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Mar 2014 02:05:22 -0700 (PDT)
Received: by mail-bk0-f52.google.com with SMTP id my13so259790bkb.11
        for <linux-mm@kvack.org>; Sat, 15 Mar 2014 02:05:21 -0700 (PDT)
Message-ID: <532417CA.1040300@gmail.com>
Date: Sat, 15 Mar 2014 10:05:14 +0100
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] readahead.2: don't claim the call blocks until all data
 has been read
References: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
In-Reply-To: <1394812471-9693-1-git-send-email-psusi@ubuntu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>, "Gregory P. Smith" <gps@google.com>, Zhu Yanhai <zhu.yanhai@gmail.com>

[CC += Past reporters: Corrado Zoccolo, Greg Smith, Zhu Yanhai]

On 03/14/2014 04:54 PM, Phillip Susi wrote:
> The readahead(2) man page was claiming that the call blocks until all
> data has been read into the cache.  This is incorrect.

Phillip, thanks for a good patch that sums things up. I didn't follow
up an earlier patch from Greg Smith, but that patch failed to explain the
behavior we discussed in https://bugzilla.kernel.org/show_bug.cgi?id=54271
where call did sometimes block for a considerable time.

I've applied the patch. Thanks for your efforts and persistence.

I've tweaked your text a bit to make some details clearer (I hope):

       readahead()  initiates  readahead  on a file so that subsequent
       reads from that file will, be satisfied from the cache, and not
       block  on  disk I/O (assuming the readahead was initiated early
       enough and that other activity on the system  did  not  in  the
       meantime flush pages from the cache).

       ...

       readahead()  attempts  to  schedule the reads in the background
       and return immediately.  However, it may block while  it  reads
       the  filesystem metadata needed to locate the requested blocks.
       This occurs frequently with ext[234] on large files using india??
       rect  blocks instead of extents, giving the appearence that the
       call blocks until the requested data has been read.

Okay?

Cheers,

Michael
 
> Signed-off-by: Phillip Susi <psusi@ubuntu.com>
> ---
>  man2/readahead.2 | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/man2/readahead.2 b/man2/readahead.2
> index 605fa5e..1b0376e 100644
> --- a/man2/readahead.2
> +++ b/man2/readahead.2
> @@ -27,7 +27,7 @@
>  .\"
>  .TH READAHEAD 2 2013-04-01 "Linux" "Linux Programmer's Manual"
>  .SH NAME
> -readahead \- perform file readahead into page cache
> +readahead \- initiate file readahead into page cache
>  .SH SYNOPSIS
>  .nf
>  .BR "#define _GNU_SOURCE" "             /* See feature_test_macros(7) */"
> @@ -37,8 +37,8 @@ readahead \- perform file readahead into page cache
>  .fi
>  .SH DESCRIPTION
>  .BR readahead ()
> -populates the page cache with data from a file so that subsequent
> -reads from that file will not block on disk I/O.
> +initates readahead on a file so that subsequent reads from that file will
> +hopefully be satisfied from the cache, and not block on disk I/O.
>  The
>  .I fd
>  argument is a file descriptor identifying the file which is
> @@ -57,8 +57,6 @@ equal to
>  .IR "(offset+count)" .
>  .BR readahead ()
>  does not read beyond the end of the file.
> -.BR readahead ()
> -blocks until the specified data has been read.
>  The current file offset of the open file referred to by
>  .I fd
>  is left unchanged.
> @@ -94,6 +92,13 @@ On some 32-bit architectures,
>  the calling signature for this system call differs,
>  for the reasons described in
>  .BR syscall (2).
> +
> +The call attempts to schedule the reads in the background and return
> +immediately, however it may block while reading filesystem metadata
> +in order to locate where the blocks requested are.  This occurs frequently
> +with ext[234] on large files using indirect blocks instead of extents,
> +giving the appearence that the call blocks until the requested data has
> +been read.
>  .SH SEE ALSO
>  .BR lseek (2),
>  .BR madvise (2),
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
