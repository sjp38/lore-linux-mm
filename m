In-reply-to: <45DDF9C1.4090003@redhat.com> (message from Peter Staubach on
	Thu, 22 Feb 2007 15:14:57 -0500)
Subject: Re: [PATCH] update ctime and mtime for mmaped write
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu> <20070221202615.a0a167f4.akpm@linux-foundation.org> <E1HK8hU-0005Mq-00@dorka.pomaz.szeredi.hu> <45DDD55F.4060106@redhat.com> <E1HKIN1-0006RX-00@dorka.pomaz.szeredi.hu> <45DDF9C1.4090003@redhat.com>
Message-Id: <E1HKKrL-0006k6-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 22 Feb 2007 21:48:11 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: staubach@redhat.com
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > __fput() will be called when there are no more references to 'file',
> > then it will update the time if the flag is set.  This applies to
> > regular files as well as devices.
> >
> >   
> 
> I suspect that you will find that, for a block device, the wrong inode
> gets updated.  That's where the bd_inode_update_time() portion of my
> proposed patch came from.

How horrible :( I haven't noticed that part of the patch.  But I don't
think that's needed.  Updating the times through the file pointer
should be OK.  You have this problem because you use the inode which
comes from the blockdev pseudo-filesystem.

> 
> > But I've moved the check from __fput to remove_vma() in the next
> > revision of the patch, which would give slightly nicer semantics, and
> > be equally conforming.
> 
> This still does not address the situation where a file is 'permanently'
> mmap'd, does it?

So?  If application doesn't do msync, then the file times won't be
updated.  That's allowed by the standard, and so portable applications
will have to call msync.

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
