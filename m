In-reply-to: <20080624114654.GA27123@2ka.mipt.ru> (message from Evgeniy
	Polyakov on Tue, 24 Jun 2008 15:46:54 +0400)
Subject: Re: [rfc patch 3/4] splice: remove confirm from pipe_buf_operations
References: <20080621154607.154640724@szeredi.hu> <20080621154726.494538562@szeredi.hu> <20080624080440.GJ20851@kernel.dk> <E1KB4Id-0000un-PV@pomaz-ex.szeredi.hu> <20080624111913.GP20851@kernel.dk> <E1KB6p9-0001Gq-Fd@pomaz-ex.szeredi.hu> <20080624114654.GA27123@2ka.mipt.ru>
Message-Id: <E1KB7E3-0001Lf-K4@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 24 Jun 2008 14:02:19 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > > basically like PageWriteback(), but for read-in.
> > 
> > OK it could be done, possibly at great pain.  But why is it important?
> 
> Maybe not that great if mark all readahead pages as, well, readahead,
> and do the same for readpage (essnetially it is the same).

It isn't that easy.  Readahead (->readpages()) is best effort, and is
allowed to not bring the page uptodate, since it will be retried with
->readpage().  I don't know whether any filesystems actually do that,
but it's allowed nonetheless.

> > What's the use case where it matters that splice-in should not block
> > on the read?
> 
> To be able to transfer what was already read?

That needs the consumer to be non-blocking...

Umm, one more reason why the ->confirm() stuff is currently busted:
pipe_read() will block on such a buffer even if pipe file is marked
O_NONBLOCK.  Fixing that would take a hell of a lot of added
complexity in pipe_poll(), etc...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
