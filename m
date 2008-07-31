In-reply-to: <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org>
	(message from Linus Torvalds on Thu, 31 Jul 2008 10:00:17 -0700 (PDT))
Subject: Re: [patch v3] splice: fix race with page invalidation
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <200807312259.43402.nickpiggin@yahoo.com.au> <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org>
Message-Id: <E1KOceD-0000nD-JA@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 31 Jul 2008 20:13:09 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: nickpiggin@yahoo.com.au, miklos@szeredi.hu, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jul 2008, Linus Torvalds wrote:
> On Thu, 31 Jul 2008, Nick Piggin wrote:
> > 
> > It seems like the right way to fix this would be to allow the splicing
> > process to be notified of a short read, in which case it could try to
> > refill the pipe with the unread bytes...
> 
> Hmm. That should certainly work with the splice model. The users of the 
> data wouldn't eat (or ignore) the invalid data, they'd just say "invalid 
> data", and stop. And it would be up to the other side to handle it (it 
> can see the state of the pipe, we can make it both wake up POLL_ERR _and_ 
> return an error if somebody tries to write to a "blocked" pipe).
> 
> So yes, that's very possible, but it obviously requires splice() users to 
> be able to handle more cases. I'm not sure it's realistic to expect users 
> to be that advanced.

Worse, it's not guaranteed to make any progress.  E.g. on NFS server
with data being continually updated, cache on the client will
basically always be invalid, so the above scheme might just repeat the
splices forever without success.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
