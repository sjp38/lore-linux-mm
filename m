From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch v3] splice: fix race with page invalidation
Date: Thu, 31 Jul 2008 22:59:43 +1000
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807312259.43402.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 30 July 2008 19:43, Miklos Szeredi wrote:
> Jens,
>
> Please apply or ack this for 2.6.27.
>
> [v3: respun against 2.6.27-rc1]
>
> Thanks,
> Miklos
>
> ----
> From: Miklos Szeredi <mszeredi@suse.cz>
>
> Brian Wang reported that a FUSE filesystem exported through NFS could
> return I/O errors on read.  This was traced to splice_direct_to_actor()
> returning a short or zero count when racing with page invalidation.
>
> However this is not FUSE or NFSD specific, other filesystems (notably NFS)
> also call invalidate_inode_pages2() to purge stale data from the cache.
>
> If this happens while such pages are sitting in a pipe buffer, then
> splice(2) from the pipe can return zero, and read(2) from the pipe can
> return ENODATA.
>
> The zero return is especially bad, since it implies end-of-file or
> disconnected pipe/socket, and is documented as such for splice.  But
> returning an error for read() is also nasty, when in fact there was no
> error (data becoming stale is not an error).

Hmm, the PageError case is a similar one which cannot be avoided, so
it kind of indicates to me that the splice async API is slightly
lacking (and provides me with some confirmation about my dislike of
removing ClearPageUptodate from invalidate...)

Returning -EIO at the pipe read I don't think quite make sense because
it is conceptually an IO error for the splicer, not the reader (who
is reading from a pipe, not from the file causing the error).

It seems like the right way to fix this would be to allow the splicing
process to be notified of a short read, in which case it could try to
refill the pipe with the unread bytes...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
