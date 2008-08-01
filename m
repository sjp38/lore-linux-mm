From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch v3] splice: fix race with page invalidation
Date: Fri, 1 Aug 2008 11:22:51 +1000
References: <E1KO8DV-0004E4-6H@pomaz-ex.szeredi.hu> <alpine.LFD.1.10.0807310957200.3277@nehalem.linux-foundation.org> <E1KOceD-0000nD-JA@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KOceD-0000nD-JA@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808011122.51792.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: torvalds@linux-foundation.org, jens.axboe@oracle.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 01 August 2008 04:13, Miklos Szeredi wrote:
> On Thu, 31 Jul 2008, Linus Torvalds wrote:
> > On Thu, 31 Jul 2008, Nick Piggin wrote:
> > > It seems like the right way to fix this would be to allow the splicing
> > > process to be notified of a short read, in which case it could try to
> > > refill the pipe with the unread bytes...
> >
> > Hmm. That should certainly work with the splice model. The users of the
> > data wouldn't eat (or ignore) the invalid data, they'd just say "invalid
> > data", and stop. And it would be up to the other side to handle it (it
> > can see the state of the pipe, we can make it both wake up POLL_ERR _and_
> > return an error if somebody tries to write to a "blocked" pipe).
> >
> > So yes, that's very possible, but it obviously requires splice() users to
> > be able to handle more cases. I'm not sure it's realistic to expect users
> > to be that advanced.
>
> Worse, it's not guaranteed to make any progress.  E.g. on NFS server
> with data being continually updated, cache on the client will
> basically always be invalid, so the above scheme might just repeat the
> splices forever without success.

Well, a) it probably makes sense in that case to provide another mode
of operation which fills the data synchronously from the sender and
copys it to the pipe (although the sender might just use read/write)
And b) we could *also* look at clearing PG_uptodate as an optimisation
iff that is found to help.

But I think it is kind of needed. The data comes from the sender, and
so only the sender may really know what to do in case of failure. I
think it is quite reasonable for an asynchronous interface to have some
kind of completion/error check and I think users should be that
advanced... if they aren't that advanced, they could use the synchonous,
copying flag to splice outlined in a), and then they wouldn't have to
care.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
