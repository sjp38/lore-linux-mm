Date: Mon, 8 Jan 2001 19:12:15 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101082120220.6280-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101081903450.1371-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Marcelo Tosatti wrote:
> 
> Your lazy enough to ask me to regenerate a patch or you can by
> yourself? :) 

Try out 2.4.1-pre1 in testing.

It does three things: 

 - gets rid of the complex "best mm" logic and replaces it with the
   round-robin thing as discussed. I have this suspicion that we
   eventually want to make this based on fault rates etc in an effort to
   more aggressively control big RSS processes, but I also suspect that
   this is tied in to the the RSS limiting patches, so this will simmer
   for a while.

 - it cleans up the unnecessary dcache/icache shrink that is already done
   more properly elsewhere.

 - it cleans up and simplifies the MM "priority" thing. In fact, right now
   only one priority is ever used, and I suspect strongly that all the
   "made_progress" logic was really there because that's how we want to do
   it (and just having one priority made "made_progress" unnecessary).

(It also has some non-VM patches, of course, but for this discussion the
VM ones are the only interesting ones).

As far as I can tell, the non-priority version is every bit as good as the
one that counts down priorities, and if nobody can argue against it I'll
just remove the priority argument altogether at some point. Right now it
still exists, it just doesn't change.

That kmem_cache_reap() thing still looks completely bogus, but I didn't
touch it. It looks _so_ bogus that there must be some reason for doing it
that ass-backwards way. Why should anybody have does a kmem_cache_reap()
when we're _not_ short of free pages? That code just makes me very
confused, so I'm not touching it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
