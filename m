Date: Fri, 17 Aug 2001 12:45:21 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 0-order allocation problem
Message-ID: <20010817124521.C16672@redhat.com>
References: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com> <20010816082419Z16176-1232+379@humbolt.nl.linux.org> <20010816112631.N398@redhat.com> <20010816121237Z16445-1231+1188@humbolt.nl.linux.org> <m1itfoow4p.fsf@frodo.biederman.org> <20010816173733.Y398@redhat.com> <m1ae0zpe2y.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1ae0zpe2y.fsf@frodo.biederman.org>; from ebiederm@xmission.com on Thu, Aug 16, 2001 at 09:20:21PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Daniel Phillips <phillips@bonn-fries.net>, Linus Torvalds <torvalds@transmeta.com>, Hugh Dickins <hugh@veritas.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 16, 2001 at 09:20:21PM -0600, Eric W. Biederman wrote:
 
> O.k. So that angle is out, but the other suggested approach where
> we scan the list of vmas will still work.  Question do you know if
> this logic would need to apply to things like ext3 and the journalling
> filesystems.  

No.  The logic needed for those is _very_ different.  Advanced fs
features such as journaling or deferred block allocation can result in
situations where any dirty memory page can be flushed to disk, but the
kernel requires more memory to do so.  For journaling, we can't flush
to disk without a commit, and a commit will require that all syscalls
currently in progress are allowed to run to completion to get a
consistent on-disk image.  For deferred block allocation, we may need
to read fs metadata structures into memory to allocate the in-core
pages to on-disk blocks before we can do the writes.  

So the journaling case requires that we keep enough freeable memory to
satisfy the writeout memory allocation requirements for such dirty
pages, but as long as enough freeable memory is available, journaling
doesn't imply any permanent pin on the pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
