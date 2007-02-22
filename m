In-reply-to: <45DDD55F.4060106@redhat.com> (message from Peter Staubach on
	Thu, 22 Feb 2007 12:39:43 -0500)
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <20070221202615.a0a167f4.akpm@linux-foundation.org> <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu> <45DDD55F.4060106@redhat.com>
Message-Id: <E1HKIN1-0006RX-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 22 Feb 2007 19:08:43 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: staubach@redhat.com
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> >> Why is the flag checked in __fput()?
> >>     
> >
> > It's because of this bit in the standard:
> >
> >     If there is no such call and if the underlying file is modified
> >     as a result of a write reference, then these fields shall be
> >     marked for update at some time after the write reference.
> >
> > It could be done in munmap/mremap, but it seemed more difficult to
> > track down all the places where the vma is removed.  But yes, that may
> > be a nicer solution.
> 
> It seems to me that, with this support, a file, which is mmap'd,
> modified, but never msync'd or munmap'd, will never get its mtime
> updated.  Or did I miss that?
> 
> I also don't see how an mmap'd block device will get its mtime
> updated either.

__fput() will be called when there are no more references to 'file',
then it will update the time if the flag is set.  This applies to
regular files as well as devices.

But I've moved the check from __fput to remove_vma() in the next
revision of the patch, which would give slightly nicer semantics, and
be equally conforming.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
