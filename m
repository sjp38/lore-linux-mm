Subject: Re: [PATCH] update ctime and mtime for mmaped write
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>
References: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 21 Feb 2007 13:12:42 -0500
Message-Id: <1172081562.9108.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, staubach@redhat.com, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-02-21 at 18:51 +0100, Miklos Szeredi wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
> 
> This patch makes writing to shared memory mappings update st_ctime and
> st_mtime as defined by SUSv3:
> 
>    The st_ctime and st_mtime fields of a file that is mapped with
>    MAP_SHARED and PROT_WRITE shall be marked for update at some point
>    in the interval between a write reference to the mapped region and
>    the next call to msync() with MS_ASYNC or MS_SYNC for that portion
>    of the file by any process. If there is no such call and if the
>    underlying file is modified as a result of a write reference, then
>    these fields shall be marked for update at some time after the
>    write reference.
> 
> A new address_space flag is introduced: AS_CMTIME.  This is set each
> time a page is dirtied through a userspace memory mapping.  This
> includes write accesses via get_user_pages().
> 
> Note, the flag is set unconditionally, even if the page is already
> dirty.  This is important, because the page might have been dirtied
> earlier by a non-mmap write.
> 
> This flag is checked in msync() and __fput(), and if set, the file
> times are updated and the flag is cleared

Why not also check inside vfs_getattr?

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
