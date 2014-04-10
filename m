Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAE76B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 15:07:16 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so4312083pbc.24
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:07:16 -0700 (PDT)
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
        by mx.google.com with ESMTPS id jg5si2714552pbb.426.2014.04.10.12.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 12:07:15 -0700 (PDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so4351584pbc.35
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:07:15 -0700 (PDT)
Message-ID: <5346EBDF.2020801@mit.edu>
Date: Thu, 10 Apr 2014 12:07:11 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>	<1395256011-2423-4-git-send-email-dh.herrmann@gmail.com> <CALYGNiPnAVf+wSsdn4aO=89H_HqyjL_-vNHpZdop=Wchf7gTtw@mail.gmail.com>
In-Reply-To: <CALYGNiPnAVf+wSsdn4aO=89H_HqyjL_-vNHpZdop=Wchf7gTtw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, David Herrmann <dh.herrmann@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?UTF-8?B?S3Jpc3RpYW4gSMO4Zw==?= =?UTF-8?B?c2Jlcmc=?= <krh@bitplanet.net>, john.stultz@linaro.org, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, dri-devel <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On 04/02/2014 06:38 AM, Konstantin Khlebnikov wrote:
> On Wed, Mar 19, 2014 at 11:06 PM, David Herrmann <dh.herrmann@gmail.com> wrote:
>> memfd_create() is similar to mmap(MAP_ANON), but returns a file-descriptor
>> that you can pass to mmap(). It explicitly allows sealing and
>> avoids any connection to user-visible mount-points. Thus, it's not
>> subject to quotas on mounted file-systems, but can be used like
>> malloc()'ed memory, but with a file-descriptor to it.
>>
>> memfd_create() does not create a front-FD, but instead returns the raw
>> shmem file, so calls like ftruncate() can be used. Also calls like fstat()
>> will return proper information and mark the file as regular file. Sealing
>> is explicitly supported on memfds.
>>
>> Compared to O_TMPFILE, it does not require a tmpfs mount-point and is not
>> subject to quotas and alike.
> 
> Instead of adding new syscall we can extend existing openat() a little
> bit more:
> 
> openat(AT_FDSHM, "name", O_TMPFILE | O_RDWR, 0666)

Please don't.  O_TMPFILE is a messy enough API, and the last thing we
need to do is to extend it.  If we want a fancy API for creating new
inodes with no corresponding dentry, let's create one.

Otherwise, let's just stick with a special-purpose API for these shm files.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
