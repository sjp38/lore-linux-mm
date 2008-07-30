In-reply-to: <alpine.LFD.1.10.0807301310130.3334@nehalem.linux-foundation.org>
	(message from Linus Torvalds on Wed, 30 Jul 2008 13:13:48 -0700 (PDT))
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807300958390.3334@nehalem.linux-foundation.org> <E1KOFUi-0000EU-0p@pomaz-ex.szeredi.hu> <20080730175406.GN20055@kernel.dk> <E1KOGT8-0000rd-0Z@pomaz-ex.szeredi.hu> <E1KOGeO-0000yi-EM@pomaz-ex.szeredi.hu>
 <20080730194516.GO20055@kernel.dk> <E1KOHvq-0001oX-OW@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807301310130.3334@nehalem.linux-foundation.org>
Message-Id: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 30 Jul 2008 22:45:34 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: miklos@szeredi.hu, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008, Linus Torvalds wrote:
> On Wed, 30 Jul 2008, Miklos Szeredi wrote:
> > 
> > Take this patch as a bugfix.  It's not in any way showing the way
> > forward: as soon as you have the time, you can revert it and start
> > from the current state.
> > 
> > Hmm?
> 
> I dislike that mentality.
> 
> The fact is, it's not a bug-fix, it's just papering over the real problem.

It _is_ a bug fix.  See here, from man 2 splice:

RETURN VALUE
       Upon successful  completion,  splice()  returns  the  number  of  bytes
       spliced  to or from the pipe.  A return value of 0 means that there was
       no data to transfer, and it would not  make  sense  to  block,  because
       there are no writers connected to the write end of the pipe referred to
       by fd_in.

Currently splice on NFS, FUSE and a few other filesystems don't
conform to that clause: splice can return zero even if there's still
data to be read, just because the data happened to be invalidated
during the splicing.  That's a plain and clear bug, which has
absolutely nothing to do with NFS _exporting_.

> And by papering it over, it then just makes people less likely to bother 
> with the real issue.

I think you are talking about a totally separate issue: that NFSD's
use of splice can result in strange things if the file is truncated
while being read.  But this is an NFSD issue and I don't see that it
has _anything_ to do with the above bug in splice.  I think you are
just confusing the two things.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
