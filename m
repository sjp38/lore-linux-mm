Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 55FDA6B01B3
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 07:30:31 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id t19so14593025igi.0
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 04:30:31 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id ac8si1949609icc.126.2014.03.20.04.29.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 04:29:54 -0700 (PDT)
Received: by mail-ig0-f170.google.com with SMTP id uq10so16849383igb.1
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 04:29:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <532AAE7B.2030501@parallels.com>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<1395256011-2423-4-git-send-email-dh.herrmann@gmail.com>
	<20140320084748.GK1728@moon>
	<532AAE7B.2030501@parallels.com>
Date: Thu, 20 Mar 2014 12:29:54 +0100
Message-ID: <CANq1E4SLp5Smxf3VbjT0hq0UrWWDf0RxudbQTA1G=sW1ecQk-g@mail.gmail.com>
Subject: Re: [PATCH 3/6] shm: add memfd_create() syscall
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, =?ISO-8859-1?Q?Kristian_H=F8gsberg?= <krh@bitplanet.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

Hi

On Thu, Mar 20, 2014 at 10:01 AM, Pavel Emelyanov <xemul@parallels.com> wrote:
> On 03/20/2014 12:47 PM, Cyrill Gorcunov wrote:
>> If I'm not mistaken in something obvious, this looks similar to /proc/pid/map_files
>> feature, Pavel?
>
> It is, but the map_files will work "in the opposite direction" :) In the memfd
> case one first gets an FD, then mmap()s it; in the /proc/pis/map_files case one
> should first mmap() a region, then open it via /proc/self/map_files.
>
> But I don't know whether this matters.

Yes, you can replace memfd_create() so far with:
  p = mmap(NULL, size, ..., MAP_ANON | MAP_SHARED, -1, 0);
  sprintf(path, "/proc/self/map_files/%lx-%lx", p, p + size);
  fd = open(path, O_RDWR);

However, map_files is only enabled with CONFIG_CHECKPOINT_RESTORE, the
/proc/pid/map_files/ directory is root-only (at least I get EPERM if
non-root), it doesn't provide the "name" argument which is very handy
for debugging, it doesn't explicitly support sealing (it requires
MAP_ANON to be backed by shmem) and it's a very weird API for
something this simple.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
