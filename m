Date: Tue, 24 Jun 2008 16:15:08 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
Message-ID: <20080624121508.GB15368@2ka.mipt.ru>
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu> <20080624114654.GA27123@2ka.mipt.ru> <E1KB7E3-0001Lf-K4@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1KB7E3-0001Lf-K4@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 24, 2008 at 02:02:19PM +0200, Miklos Szeredi (miklos@szeredi.hu) wrote:
> > Maybe not that great if mark all readahead pages as, well, readahead,
> > and do the same for readpage (essnetially it is the same).
> 
> It isn't that easy.  Readahead (->readpages()) is best effort, and is
> allowed to not bring the page uptodate, since it will be retried with
> ->readpage().  I don't know whether any filesystems actually do that,
> but it's allowed nonetheless.

Yes, there is such filesystem :)
It is quite useful for network FS, since it does not bother to wait until
pages are in the cache and can try next request. Anyone who scheduled
readahead has full control over that pages and is allowed to set/clear
whatever flags it want (pages are locked), so it would be a great win to
set page as being read and unlocked. It can be a policy to clear read
bit when page is evicted from the cache by failed readahead/readpage(s).

> > > What's the use case where it matters that splice-in should not block
> > > on the read?
> > 
> > To be able to transfer what was already read?
> 
> That needs the consumer to be non-blocking...
> 
> Umm, one more reason why the ->confirm() stuff is currently busted:
> pipe_read() will block on such a buffer even if pipe file is marked
> O_NONBLOCK.  Fixing that would take a hell of a lot of added
> complexity in pipe_poll(), etc...

Yes, nonblocking splice is tricky and it covers only half of the users.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
