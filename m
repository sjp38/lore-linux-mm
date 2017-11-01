Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4C246B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 15:37:52 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r64so2566153qkc.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 12:37:52 -0700 (PDT)
Received: from out4-smtp.messagingengine.com (out4-smtp.messagingengine.com. [66.111.4.28])
        by mx.google.com with ESMTPS id y190si1282095qkc.411.2017.11.01.12.37.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Nov 2017 12:37:51 -0700 (PDT)
Message-Id: <1509565071.2650718.1158454064.7E910622@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
Subject: Re: [RFC] EPOLL_KILLME: New flag to epoll_wait() that subscribes process
 to death row (new syscall)
Date: Wed, 01 Nov 2017 15:37:51 -0400
In-Reply-To: <CA+49okox_Hvg-dGyjZc3u0qLz1S=LJjS4-WT6SxQ9qfPyp6BjQ@mail.gmail.com>
References: <20171101053244.5218-1-slandden@gmail.com>
 <1509549397.2561228.1158168688.4CFA4326@webmail.messagingengine.com>
 <CA+49okox_Hvg-dGyjZc3u0qLz1S=LJjS4-WT6SxQ9qfPyp6BjQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Landden <slandden@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 1, 2017, at 03:02 PM, Shawn Landden wrote:
>=20
> This solves the fact that epoll_pwait() already is a 6 argument (maximum =
allowed) syscall. But what if the process has multiple epoll() instances in=
 multiple threads?=20

Well, that's a subset of the general question of - what is the interaction
of this system call and threading?=C2=A0 It looks like you've prototyped th=
is
out in userspace with systemd, but from a quick glance at the current git,
systemd's threading is limited doing sync()/fsync() and gethostbyname() asy=
nc.

But languages with a GC tend to at least use a background thread for that,
and of course lots of modern userspace makes heavy use of multithreading
(or variants like goroutines).

A common pattern though is to have a "main thread" that acts as a control
point and runs the mainloop (particularly for anything with a GUI).   That's
going to be the thing calling prctl(SET_IDLE) - but I think its idle state =
should implicitly
affect the whole process, since for a lot of apps those other threads are g=
oing to
just be "background".

It'd probably then be an error to use prctl(SET_IDLE) in more than one thre=
ad
ever?  (Although that might break in golang due to the way goroutines can
be migrated across threads)

That'd probably be a good "generality test" - what would it take to have
this system call be used for a simple golang webserver app that's e.g.
socket activated by systemd, or a Kubernetes service?  Or another
really interesting case would be qemu; make it easy to flag VMs as always
having this state (most of my testing VMs are like this; it's OK if they get
destroyed, I just reinitialize them from the gold state).

Going back to threading - a tricky thing we should handle in general
is when userspace libraries create threads that are unknown to the app;
the "async gethostbyname()" is a good example.  To be conservative we'd
likely need to "fail non-idle", but figure out some way tell the kernel
for e.g. GC threads that they're still idle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
