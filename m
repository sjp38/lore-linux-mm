Date: Thu, 31 Jul 2008 10:00:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <200807312259.43402.nickpiggin@yahoo.com.au>
Message-ID: <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org>
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <200807312259.43402.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 31 Jul 2008, Nick Piggin wrote:
> 
> It seems like the right way to fix this would be to allow the splicing
> process to be notified of a short read, in which case it could try to
> refill the pipe with the unread bytes...

Hmm. That should certainly work with the splice model. The users of the 
data wouldn't eat (or ignore) the invalid data, they'd just say "invalid 
data", and stop. And it would be up to the other side to handle it (it 
can see the state of the pipe, we can make it both wake up POLL_ERR _and_ 
return an error if somebody tries to write to a "blocked" pipe).

So yes, that's very possible, but it obviously requires splice() users to 
be able to handle more cases. I'm not sure it's realistic to expect users 
to be that advanced.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
