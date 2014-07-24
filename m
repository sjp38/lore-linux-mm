Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id BBBE06B0099
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:44:20 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so2955399iec.11
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:44:20 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id ls9si18001702icb.21.2014.07.24.15.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 15:44:20 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so62084igd.5
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:44:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140724144747.3041b208832bbdf9fbce5d96@linux-foundation.org>
References: <1405877680-999-1-git-send-email-dh.herrmann@gmail.com>
	<20140724144747.3041b208832bbdf9fbce5d96@linux-foundation.org>
Date: Fri, 25 Jul 2014 00:44:19 +0200
Message-ID: <CANq1E4RqYTvZSV4-YbLqBAL_PxjTprgFtRtfYRUZWtEvGYDAfA@mail.gmail.com>
Subject: Re: [PATCH v4 0/6] File Sealing & memfd_create()
From: David Herrmann <dh.herrmann@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Andy Lutomirski <luto@amacapital.net>, Alexander Viro <viro@zeniv.linux.org.uk>

Hi

On Thu, Jul 24, 2014 at 11:47 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sun, 20 Jul 2014 19:34:34 +0200 David Herrmann <dh.herrmann@gmail.com> wrote:
>
>> This is v4 of the File-Sealing and memfd_create() patches. You can find v1 with
>> a longer introduction at gmane [1], there's also v2 [2] and v3 [3] available.
>> See also the article about sealing on LWN [4], and a high-level introduction on
>> the new API in my blog [5]. Last but not least, man-page proposals are
>> available in my private repository [6].
>>
>> ...
>>
>>
>> [1]    memfd v1: http://thread.gmane.org/gmane.comp.video.dri.devel/102241
>> [2]    memfd v2: http://thread.gmane.org/gmane.linux.kernel.mm/115713
>> [3]    memfd v3: http://thread.gmane.org/gmane.linux.kernel.mm/118721
>> [4] LWN article: https://lwn.net/Articles/593918/
>> [5]   API Intro: http://dvdhrm.wordpress.com/2014/06/10/memfd_create2/
>> [6]   Man-pages: http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd
>> [7]    Dev-repo: http://cgit.freedesktop.org/~dvdhrm/linux/log/?h=memfd
>
> This is unconventional and a little irritating.  I'm OK with running
> around chasing down web pages but we generally don't do that in
> changelogs.  I'm not sure why really, maybe partly because things
> bitrot, partly because that's where people expect to find things,
> partly because people like work down caves and on airplanes ;)
>
> Another downside is that if a reviewer wants to comment on some piece
> of text, it isn't available for the usual reply-to-all quoting.
>
>
> So...  Could you please put together a plain old text/plain changelog
> which actually describes this patchset and send it along?  Everything
> which people need/want to know, all in one place?  That text should be
> maintained alongside the patches themselves, should there be future
> versions.
>
> Now excuse me, I have a bunch of web pages to go and read ;)
>
> <reads "[1]    memfd v1">
>
> OK, I immediately have questions and I see significant review feedback,
> so either that document is out of date or that review feedback was
> ignored.
>
> Help.  Where do I (and all future readers of these patches) go to get
> an up to date and complete description of this patchset??

Sorry for the confusion. The real introduction is available in Patch
2/6 [1]. The commit message explains the rationale behind and
motivation for this new API. The man-page available in my private
repository [2] contains a much shorter high-level description without
any lengthy description of the motivation.

The other patches are:
#1: This refactors i_mmap_writable to an signed integer. It currently
counts the writable mappings of an address_space. By making it signed,
we can decrement it below 0 (just like i_writecount on inodes) and
thus block any new attempts to map it writable). This is needed for
SEAL_WRITE.
#2: Introduces sealing and describes the intent in lengthy detail in
its commit message.
#3: Introduces memfd_create().
#4+#5: Self-tests for all newly introduced APIs.
#6: Fix SEAL_WRITE vs. elevated page-ref-counts by GUP and friends.

Below you can find a summary mostly taken from Patch #2, but includes
some more hints regarding the discussion from v1 to v4.

Thanks
David

[1] https://lkml.org/lkml/2014/7/20/155
[2]   Man-pages: http://cgit.freedesktop.org/~dvdhrm/man-pages/log/?h=memfd


File-Sealing & memfd_create(2)

If two processes share a common memory region, they usually want some
guarantees to allow safe access. This often includes:
  - one side cannot overwrite data while the other reads it
  - one side cannot shrink the buffer while the other accesses it
  - one side cannot grow the buffer beyond previously set boundaries

If there is a trust-relationship between both parties, there is no
need for policy enforcement. However, if there's no trust relationship
(eg., for general-purpose IPC) sharing memory-regions is highly
fragile and often not possible without local copies. Look at the
following two use-cases:
  1) A graphics client wants to share its rendering-buffer
     with a graphics-server. The memory-region is allocated
     by the client for read/write access and a second FD is
     passed to the server. While scanning out from the
     memory region, the server has no guarantee that the
     client doesn't shrink the buffer at any time, requiring
     rather cumbersome SIGBUS handling.
  2) A process wants to perform an RPC on another process.
     To avoid huge bandwidth consumption, zero-copy is
     preferred. After a message is assembled in-memory
     and a FD is passed to the remote side, both sides want
     to be sure that neither modifies this shared copy,
     anymore. The source may have put sensible data into
     the message without a separate copy and the target
     may want to parse the message inline, to avoid a local
     copy.

While SIGBUS handling, POSIX mandatory locking and MAP_DENYWRITE
provide ways to achieve most of this, the first one is
unproportionally ugly to use in libraries and the latter two are
broken/racy or even disabled due to denial of service attacks.

This series introduces the concept of SEALING. If you seal a file, a
specific set of operations is blocked on that file forever. Unlike
locks, seals can only be set, never removed. Hence, once you verified
a specific set of seals is set, you're guaranteed that no-one can
perform the blocked operations on this file, anymore.

An initial set of SEALS is introduced by this patch:
  - SHRINK: If SEAL_SHRINK is set, the file in question cannot
            be reduced in size. This affects ftruncate() and
            open(O_TRUNC).
  - GROW: If SEAL_GROW is set, the file in question cannot be
          increased in size. This affects ftruncate(), fallocate()
          and write().
  - WRITE: If SEAL_WRITE is set, no write operations (besides
           resizing) are possible. This affects
           fallocate(PUNCH_HOLE), mmap() and write().
  - SEAL: If SEAL_SEAL is set, no further seals can be added
          to a file. This basically prevents the F_ADD_SEAL
          operation on a file and can be set to prevent others
          from adding further seals that you don't want.

The described use-cases can easily use these seals to provide safe use
without any trust-relationship:
  1) The graphics server can verify that a passed file-descriptor
     has SEAL_SHRINK set. This allows safe scanout, while the
     client is allowed to increase buffer size for window-resizing
     on-the-fly. Concurrent writes are explicitly allowed.
  2) For general-purpose IPC, both processes can verify that
     SEAL_SHRINK, SEAL_GROW and SEAL_WRITE are set. This
     guarantees that neither process can modify the data while
     the other side parses it. Furthermore, it guarantees that
     even with writable FDs passed to the peer, it cannot
     increase the size to hit memory-limits of the source
     process (in case the file-storage is accounted to the source).

The new API is an extension to fcntl(), adding two new commands:
  F_GET_SEALS: Return a bitset describing the seals on the
               file. This can be called on any FD if the underlying
               file supports sealing.
  F_ADD_SEALS: Change the seals of a given file. This requires
               WRITE access to the file and F_SEAL_SEAL may not
               already be set. Furthermore, the underlying file must
               support sealing and there may not be any existing
               shared mapping of that file. Otherwise, EBADF/EPERM
               is returned. The given seals are _added_ to the existing
               set of seals on the file. You cannot remove seals again.

The fcntl() handler is currently specific to shmem and disabled on all
files. A file needs to explicitly support sealing for this interface
to work. A separate syscall is added in a follow-up, which creates
files that support sealing. There is no intention to support this on
other file-systems. Semantics are unclear for non-volatile files and
we lack any use-case right now. Therefore, the implementation is
specific to shmem.

A new syscall, memfd_create(2), is added. It is similar to O_TMPFILE,
but does not require a local shmem mount-point. On each invokation,
the syscall allocates a new shmem inode and returns a file-descriptor
to user-space. Sealing is explicitly allowed on this file and the
backing memory is allocated as anonymous memory. Therefore, it is not
subject to file-system limits. It is still subject to memcg limits,
though.

As requested by reviewers, sealing is disabled on all files but
memfd_create() with MFD_ALLOW_SEALING flag set. Modifying seals
requires FMODE_WRITE, which so far prevents any attacks if we enabled
it on other shmem files as well. However, as there hasn't been any
use-case for that, it is currently limited to memfd_create(2). But the
API is kept generic so it can be extended to other files as well.

One important aspect of SEAL_WRITE is, once set, all writes to a file
must be blocked with immediate effect. We disallow setting SEAL_WRITE
if there're writable mappings, so we're fine against direct memory
access (and we lock i_mutex against write()), however, we're not
protected against GUP users. If a process maps a file and starts an
AIO Direct-IO transaction which receives data from a random device and
writes it into the memory mapped file as receive buffer, the kernel
uses GUP to pin that buffer and asynchronously writes into the given
pages. If the process unmaps the buffer before AIO succeeds, the pages
are still pinned and written to by AIO, however, the process is now
allowed to set SEAL_WRITE.
To protect against such GUP uses, we discussed several approaches and
3 different ideas were implements:

1) Refuse SEAL_WRITE if any of the backing pages has an elevated ref-count.
2) Wait for page-refs to be dropped before setting SEAL_WRITE. If the
wait times out, refuse SEAL_WRITE.
3) Replace any pages with elevated ref-counts when setting SEAL_WRITE.
Copy data over so data consistency is given.

The last patch in this series implements idea 2). Idea 3) is superior,
but far more complex and Hugh wanted to avoid maintaining a separate
migration code-path in shmem.c. As no-one so far provided any evidence
that 2) isn't sufficient, we settled for it. The selftests directory
contains test-cases for both 2) and 3) using FUSE. I haven't succeeded
in triggering the real races, so I used FUSE to create arbitrary GUP
delays.

Thanks
David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
