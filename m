Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id C23E16B00A9
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:38:36 -0400 (EDT)
Received: by mail-ie0-f176.google.com with SMTP id rd18so200972iec.21
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 06:38:36 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id k7si2467174icu.9.2014.04.02.06.38.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 06:38:36 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so5078515igq.4
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 06:38:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
Date: Wed, 2 Apr 2014 17:38:35 +0400
Message-ID: <CALYGNiPnAVf+wSsdn4aO=89H_HqyjL_-vNHpZdop=Wchf7gTtw@mail.gmail.com>
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?Q?Kristian_H=C3=B8gsberg?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Wed, Mar 19, 2014 at 11:06 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
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

Instead of adding new syscall we can extend existing openat() a little
bit more:

openat(AT_FDSHM, "name", O_TMPFILE | O_RDWR, 0666)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
