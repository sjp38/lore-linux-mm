Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA21380
	for <linux-mm@kvack.org>; Tue, 24 Nov 1998 12:33:59 -0500
Date: Tue, 24 Nov 1998 09:33:11 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Linux-2.1.129..
In-Reply-To: <199811241525.PAA00862@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.95.981124092641.10767A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Rik van Riel <H.H.vanRiel@phys.uu.nl>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 24 Nov 1998, Stephen C. Tweedie wrote:
> 
> Indeed.  However, I think it misses the real advantage, which is that
> the mechanism would be inherently self-tuning (much more so than the
> existing code).

Yes, that's one of the reasons I like it.

The other reason I like it is that right now it is extremely hard to share
swapped out pages unless you share them due to a fork(). The problem is
that the swap cache supports the notion of sharing, but out swap-out
routines do not - they swap things out on a per-virtual-page basis, and
that results in various nasty things - we page out the same page to
multiple places, and lose the sharing. 

> > I'd like to see this, although I think it's way too late for 2.2
> 
> The mechanism is all there, and we're just tuning policy.  Frankly,
> the changes we've seen in vm policy since 2.1.125 are pretty major
> already, and I think it's important to get it right before 2.2.0.

The VM policy changes weren't stability issues, they were only "timing". 
As such, if they broke something, it was really broken before too. 

And I agree that the mechanism is already there, however as it stands we
really populate the swap cache at page-in rather than page-out, and
changing that is fairly fundamental. It would be good, no question about
it, but it's still fairly fundamental. 

Note that if done right, this would also fix the damn stupid dirty page
write-back thing: right now if multiple processes share the same dirty
page and they all write to it, it will be written multiple times. But done
right, the dirty inode page write-out would be done the same way. 

> The patch below is a very simple implementation of this concept.

I will most probably apply the patch - it just looks fundamentally
correct. However, what I was thinking of was a bit more ambitious.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
