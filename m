Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B28EB6B0249
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 11:51:24 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id uq10so2464867igb.5
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:51:24 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id ac8si2689739icc.108.2014.03.20.08.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 08:48:31 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id tp5so1010017ieb.26
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 08:48:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140320153250.GC20618@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
	<20140320153250.GC20618@thunk.org>
Date: Thu, 20 Mar 2014 16:48:30 +0100
Message-ID: <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu, David Herrmann <dh.herrmann@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

Hi

On Thu, Mar 20, 2014 at 4:32 PM,  <tytso@mit.edu> wrote:
> Why not make sealing an attribute of the "struct file", and enforce it
> at the VFS layer?  That way all file system objects would have access
> to sealing interface, and for memfd_shmem, you can't get another
> struct file pointing at the object, the security properties would be
> identical.

Sealing as introduced here is an inode-attribute, not "struct file".
This is intentional. For instance, a gfx-client can get a read-only FD
via /proc/self/fd/ and pass it to the compositor so it can never
overwrite the contents (unless the compositor has write-access to the
inode itself, in which case it can just re-open it read-write).

Furthermore, I don't see any use-case besides memfd for sealing, so I
purposely avoided changing core VFS interfaces. Protecting
page-allocation/access for SEAL_WRITE like I do in shmem.c is not that
easy to do generically. So if we moved this interface to "struct
inode", all that would change is moving "u32 seals;" from one struct
to the other. Ok, some protections might get easily implemented
generically, but I without proper insight in the underlying
implemenation, I couldn't verify all paths and possible races. Isn't
keeping the API generic enough so far? Changing the underlying
implementation can be done once we know what we want.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
