Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EA9D86B0253
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 18:11:58 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so1885257wic.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 15:11:58 -0700 (PDT)
Received: from mail.zonque.de (svenfoo.org. [82.94.215.22])
        by mx.google.com with ESMTPS id r5si12660788wix.25.2015.08.09.15.11.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 15:11:57 -0700 (PDT)
Subject: Re: kdbus: to merge or not to merge?
References: <CANq1E4SnYq_pZMWYcafB9GmB_O77tbVLPT0=0d6LGQVpvThTrw@mail.gmail.com>
 <CALCETrWE-oYRq+AzRxxcz03AK0pAzgKJtmxAuNwQu+p5S0msBw@mail.gmail.com>
 <CANq1E4Rek3HXCDU_13OGfRShS7Z0g+fxcTp5C1V3oKC4HgkD_A@mail.gmail.com>
 <CALCETrUaSgdaq4_mr3GG-ekLwGXkQR5MoRLSj9Wu2dTXDYUp1g@mail.gmail.com>
 <CANq1E4SkUWWXuksJnWzXd5KStZx-T6q6+WWTHdrQz_WiMry4Cw@mail.gmail.com>
 <CALCETrXcqOFedk8r-jHK-deRwfum29JHspALE6JUi2gzbo-dhg@mail.gmail.com>
 <55C3A403.8020202@zonque.org>
 <CALCETrVr04ZdXHLZXLp_Y+m68Db5Mmh_Wnu6prNCfCqgWm0QzA@mail.gmail.com>
 <55C4C35A.4070306@zonque.org>
 <CA+55aFxDLt-5+=xXeYG4nJKMb8L_iD9FmwTZ2VuughBku-mW3g@mail.gmail.com>
 <20150809190027.GA24185@kroah.com>
From: Daniel Mack <daniel@zonque.org>
Message-ID: <55C7D02A.9060905@zonque.org>
Date: Mon, 10 Aug 2015 00:11:54 +0200
MIME-Version: 1.0
In-Reply-To: <20150809190027.GA24185@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tom Gundersen <teg@jklm.no>, "Kalle A. Sandstrom" <ksandstr@iki.fi>, Borislav Petkov <bp@alien8.de>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, Havoc Pennington <havoc.pennington@gmail.com>, Djalal Harouni <tixxdz@opendz.org>, Andy Lutomirski <luto@amacapital.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, cee1 <fykcee1@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, linux-mm@kvack.org

On 08/09/2015 09:00 PM, Greg Kroah-Hartman wrote:
> In chatting with Daniel on IRC, he is writing up a summary of how the
> kdbus memory pools work in more detail, and he said he would sent that
> out in a day or so, so that everyone can review.

Yes, let me quickly describe again how the kdbus pool logic works.

Every bus connection (peer) owns a buffer which is used in order to
receive payloads. Such payloads are either messages sent from other
connections, notifications or returned answer structures in return of
query commands (name lists, etc).

In order to avoid the kernel having to maintaining an internal buffer
the connections then read from with an extra command, we decided to let
the connections own their buffer directly, so they can mmap() the memory
into their task. Allocating a local buffer to collect asynchronous
messages is what they would need to do anyway, so we implemented a
short-cut that allows the kernel to directly access the memory and write
to it. The size of this buffer pool is configured by each connection
individually, during the HELLO call, so the kernel interface is as
flexible as any other memory allocation scheme the kernel provides and
is subject to the same limits.

Internally, the connection pool is simply a shmem backed file. From the
context of the HELLO ioctl, we are calling into shmem_file_setup(), so
the file is eventually owned by the task which created the bus task
connecting to the bus. One reason why we do the shmem file allocation in
the kernel and on behalf of a the userspace task is that we clear the
VM_MAYWRITE bit to prevent the task from writing to the pool through its
mapped buffer. We also do not set VM_NORESERVE, so the entire buffer is
pre-accounted for the task that created the connection.

The pool implementation uses an r/b tree to organize the buffer into
slices. Those slices can be kept by userspace as long as the parsing
implementation needs to have access to them. When finished, the slices
are freed. A simple ring buffer cannot cope with the gaps that emerge by
that.

When a connection buffer is written to, it is done from the context of
another task which calls into the kdbus code through one of the ioctls.
The memcg implementation should hence charge the task that acts as
writer, which is maybe not ideal but can be changed easily with some
addition to the internal APIs. We omitted it for the current version,
which is non-intrusive with regards to other kernel subsystems.

The kdbus implementation is actually comparable to two tasks X and Y
which both have their own buffer file open and mmap()ed, and they both
pass their FD to the other side. If X now writes to Y's file, and that
is causing a page fault, X is accounted for it, correct?

The kernel does *not* do any memory allocation to buffer payload, and
all other allocations (for instance, to keep around the internal state
of a connection, names etc) are subject to conservatively chosen
limitations. There is no unbounded memory allocation in kdbus that I am
aware of. If there was, it would clearly be a bug.

Addressing the point Andy made earlier: yes, due to memory
overcommitment, OOM situations may happen with certain patterns, but the
kernel should have the same measures to deal with them that it already
has with other types of shared userspace memory. Right?

Hope that all makes sense, we're open to discussions around the desired
accounting details. I've copied linux-mm to let more people have a look
into this again.


Thanks,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
