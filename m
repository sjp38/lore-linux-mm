Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 145CE6B024E
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 15:22:11 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1367896pab.41
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:22:10 -0700 (PDT)
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
        by mx.google.com with ESMTPS id tk9si2104934pac.129.2014.03.20.12.22.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 12:22:09 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so1394518pbb.11
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:22:09 -0700 (PDT)
Message-ID: <532B3FDD.1090108@linaro.org>
Date: Thu, 20 Mar 2014 12:22:05 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com> <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
In-Reply-To: <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?ISO-8859-1?Q?Kristian_H=F8gsberg?= <krh@bitplanet.net>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Colin Cross <ccross@android.com>

On 03/19/2014 12:06 PM, David Herrmann wrote:
> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
> that you can pass to mmap(). It explicitly allows sealing and
> avoids any connection to user-visible mount-points. Thus, it's not
> subject to quotas on mounted file-systems, but can be used like
> malloc()'ed memory, but with a file-descriptor to it.
>
> memfd_create() does not create a front-FD, but instead returns the raw
> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
> will return proper information and mark the file as regular file. Sealing
> is explicitly supported on memfds.
>
> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
> subject to quotas and alike.

This syscall would also be useful to Android, since it would satisfy the
requirement for providing atomically unlinked tmpfs fds that ashmem
provides (although upstreamed solutions to ashmem's other
functionalities are still needed).

My only comment is that I think memfd_* is sort of a new namespace.
Since this is providing shmem files, it seems it might be better named
something like shmfd_create() or my earlier suggestion of shmget_fd(). 
Otherwise, when talking about functionality like sealing, which is only
available on shmfs, we'll have to say "shmfs/tmpfs/memfd" or risk
confusing folks who might not initially grasp that its all the same
underneath.

thanks
-john







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
