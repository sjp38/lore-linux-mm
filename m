Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id A8C5C6B00B2
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 10:52:15 -0400 (EDT)
Received: by mail-ig0-f181.google.com with SMTP id h18so416179igc.8
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 07:52:15 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id nx5si2683423icb.80.2014.04.02.07.52.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 07:52:14 -0700 (PDT)
Received: by mail-ie0-f171.google.com with SMTP id ar20so324101iec.30
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 07:52:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANq1E4QV-=kWhzxqq4F-mZ2puh--SPydR+HmbLvoCixiJ_c6=g@mail.gmail.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
	<CALYGNiPnAVf+wSsdn4aO=89H_HqyjL_-vNHpZdop=Wchf7gTtw@mail.gmail.com>
	<CANq1E4QV-=kWhzxqq4F-mZ2puh--SPydR+HmbLvoCixiJ_c6=g@mail.gmail.com>
Date: Wed, 2 Apr 2014 18:52:14 +0400
Message-ID: <CALYGNiPY-1pYqaMX9PrhKvMMW=fgP7CoqWfaH6mdtxfFnf4fqQ@mail.gmail.com>
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>

On Wed, Apr 2, 2014 at 6:18 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
> Hi
>
> On Wed, Apr 2, 2014 at 3:38 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> On Wed, Mar 19, 2014 at 11:06 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>>> that you can pass to mmap(). It explicitly allows sealing and
>>> avoids any connection to user-visible mount-points. Thus, it's not
>>> subject to quotas on mounted file-systems, but can be used like
>>> malloc()'ed memory, but with a file-descriptor to it.
>>>
>>> memfd_create() does not create a front-FD, but instead returns the raw
>>> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
>>> will return proper information and mark the file as regular file. Sealing
>>> is explicitly supported on memfds.
>>>
>>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>>> subject to quotas and alike.
>>
>> Instead of adding new syscall we can extend existing openat() a little
>> bit more:
>>
>> openat(AT_FDSHM, "name", O_TMPFILE | O_RDWR, 0666)
>
> O_TMPFILE requires an existing directory as "name". So you have to use:
>   open("/run/", O_TMPFILE | O_RDWR, 0666)
> instead of
>   open("/run/new_file", O_TMPFILE | O_RDWR, 0666)
>
> We _really_ want to set a name for the inode, though. Otherwise,
> debug-info via /proc/pid/fd/ is useless.
>
> Furthermore, Linus requested to allow sealing only on files that
> _explicitly_ allow sealing. So v2 of this series will have
> MFD_ALLOW_SEALING as memfd_create() flag. I don't think we can do this
> with linkat() (or is that meant to be implicit for the new AT_FDSHM?).
> Last but not least, you now need a separate syscall to set the
> file-size.
>
> I could live with most of these issues, except for the name-thing. Ideas?

Hmm, why AT_FDSHM + O_TMPFILE pair cannot has different naming behavior?
Actually O_TMPFILE flag is optional here. AT_FDSHM is enough, but
O_TMPFILE allows to
move branching out of common fast-paths and hide it inside do_tmpfile.

BTW you can set some extended attribute via fsetxattr and distinguish
files in proc by its value.

OR you could add fcntl() for changing 'name' of tmpfiles. In
combination with AT_FDSHM this
would give complete solution without changing O_TMPFILE naming scheme.
But one syscall turns into three. )

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
