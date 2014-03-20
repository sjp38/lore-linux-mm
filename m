Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2579A6B024D
	for <linux-mm@kvack.org>; Thu, 20 Mar 2014 12:38:19 -0400 (EDT)
Received: by mail-yk0-f173.google.com with SMTP id 10so2915178ykt.4
        for <linux-mm@kvack.org>; Thu, 20 Mar 2014 09:38:18 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id h55si2730812yhi.102.2014.03.20.09.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Mar 2014 09:38:17 -0700 (PDT)
Date: Thu, 20 Mar 2014 12:38:06 -0400
From: tytso@mit.edu
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
Message-ID: <20140320163806.GA10440@thunk.org>
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com>
 <20140320153250.GC20618@thunk.org>
 <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On Thu, Mar 20, 2014 at 04:48:30PM +0100, David Herrmann wrote:
> On Thu, Mar 20, 2014 at 4:32 PM,  <tytso@mit.edu> wrote:
> > Why not make sealing an attribute of the "struct file", and enforce it
> > at the VFS layer?  That way all file system objects would have access
> > to sealing interface, and for memfd_shmem, you can't get another
> > struct file pointing at the object, the security properties would be
> > identical.
> 
> Sealing as introduced here is an inode-attribute, not "struct file".
> This is intentional. For instance, a gfx-client can get a read-only FD
> via /proc/self/fd/ and pass it to the compositor so it can never
> overwrite the contents (unless the compositor has write-access to the
> inode itself, in which case it can just re-open it read-write).

Hmm, good point.  I had forgotten about the /proc/self/fd hole.
Hmm... what if we have a SEAL_PROC which forces the permissions of
/proc/self/fd to be 000?

So if it is a property of the attribute, SEAL_WRITE and SEAL_GROW is
basically equivalent to using chattr to set the immutable and
append-only attribute, except for the "you can't undo the seal unless
you have exclusive access to the inode" magic.

That does make it pretty memfd_create specific and not a very general
API, which is a little unfortunate; hence why I'm trying to explore
ways of making a bit more generic and hopefully useful for more use
cases.

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
