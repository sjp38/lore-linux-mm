Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id EC38B6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 15:14:33 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so4347984pbb.12
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:14:33 -0700 (PDT)
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
        by mx.google.com with ESMTPS id si6si2736379pab.121.2014.04.10.12.14.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 12:14:33 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so4375007pad.35
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:14:31 -0700 (PDT)
Message-ID: <5346ED93.9040500@amacapital.net>
Date: Thu, 10 Apr 2014 12:14:27 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] File Sealing & memfd_create()
References: <1395256011-2423-1-git-send-email-dh.herrmann@gmail.com> <20140320153250.GC20618@thunk.org> <CANq1E4SUXrzAV8FS8HVYxnRVb1oOR6HSTyucJzyFs5PuS5Y88A@mail.gmail.com> <20140320163806.GA10440@thunk.org>
In-Reply-To: <20140320163806.GA10440@thunk.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tytso@mit.edu, David Herrmann <dh.herrmann@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Karol Lewandowski <k.lewandowsk@samsung.com>, Kay Sievers <kay@vrfy.org>, Daniel Mack <zonque@gmail.com>, Lennart Poettering <lennart@poettering.net>, John Stultz <john.stultz@linaro.org>, Greg Kroah-Hartman <greg@kroah.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ryan Lortie <desrt@desrt.ca>, "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>

On 03/20/2014 09:38 AM, tytso@mit.edu wrote:
> On Thu, Mar 20, 2014 at 04:48:30PM +0100, David Herrmann wrote:
>> On Thu, Mar 20, 2014 at 4:32 PM,  <tytso@mit.edu> wrote:
>>> Why not make sealing an attribute of the "struct file", and enforce it
>>> at the VFS layer?  That way all file system objects would have access
>>> to sealing interface, and for memfd_shmem, you can't get another
>>> struct file pointing at the object, the security properties would be
>>> identical.
>>
>> Sealing as introduced here is an inode-attribute, not "struct file".
>> This is intentional. For instance, a gfx-client can get a read-only FD
>> via /proc/self/fd/ and pass it to the compositor so it can never
>> overwrite the contents (unless the compositor has write-access to the
>> inode itself, in which case it can just re-open it read-write).
> 
> Hmm, good point.  I had forgotten about the /proc/self/fd hole.
> Hmm... what if we have a SEAL_PROC which forces the permissions of
> /proc/self/fd to be 000?

This is the second time in a week that someone has asked for a way to
have a struct file (or struct inode or whatever) that can't be reopened
through /proc/pid/fd.  This should be quite easy to implement as a
separate feature.

Actually, that feature would solve a major pet peeve of mine, I think: I
want something like memfd that allows me to keep the thing read-write
but that whomever I pass the fd to can't change.  With this feature, I
could do:

fd_rw = memfd_create (or O_TMPFILE or whatever)
fd_ro = open(/proc/self/fd/fd_ro, O_RDONLY);
fcntl(fd_ro, F_RESTRICT, F_RESTRICT_REOPEN);

send fd_ro via SCM_RIGHTS.

To really make this work well, I also want to SEAL_SHRINK the inode so
that the receiver can verify that I'm not going to truncate the file out
from under it.

Bingo, fast and secure one-way IPC.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
