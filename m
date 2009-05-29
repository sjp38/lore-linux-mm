Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 49FC06B004D
	for <linux-mm@kvack.org>; Fri, 29 May 2009 18:17:44 -0400 (EDT)
Date: Sat, 30 May 2009 00:24:44 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/16] HWPOISON: Intro
Message-ID: <20090529222444.GG1065@one.firstfloor.org>
References: <200905291135.124267638@firstfloor.org> <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, May 29, 2009 at 10:52:02PM +0100, Alan Cox wrote:
> On Fri, 29 May 2009 23:35:25 +0200 (CEST)
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > 
> > Another version of the hwpoison patchkit. I addressed 
> > all feedback, except:
> > I didn't move the handlers into other files for now, prefer
> > to keep things together for now
> > I'm keeping an own pagepoison bit because I think that's 
> > cleaner than any other hacks.
> > 
> > Andrew, please put it into mm for .31 track.
> 
> Andrew please put it on the "Andi needs to justify his pageflags" non-path
> 
> I'm with Rik on this - we may have a few pageflags handy now but being
> slack with them for an obscure feature that can be done other ways and
> isn't performance critical is just lazy and bad planning for the long
> term.

There's still plenty of space. Especially on 64bit it's an absolute
non problem.

On 32bit the shortage of page flags was really
artificial because there were some caches put into ->flags, but 
these are largely obsolete to my understanding:
- discontigmem is gone (which cached the node)
- non vmap sparsemem is used a few times, but not on large systems
where you have a lot of zones, so you are ok with only having a few bits
for that
- if we really run out of bits on the sparsemem mapping it's easy
enough to do another small hash table for this, similar to the discontig
hash tables.

Also Christoph L. redid the dynamic allocation, so the boundaries
are now dynamically growing/shrinking. This means that if an architecture
doesn't use poison it doesn't use the bit.


> Andi - "I'm doing it my way so nyahh, put it into .31" doesn't fly. If
> you want it in .31 convince Rik and me and others that its a good use of
> a pageflag.

Sorry, you guys also didn't do a very good job explaining why 
it is that big a problem to take a page flag. Yes I know it's popular
folklore, but as far as I understand most of the reasons to be so
stingy on them have disappeared over time anyways (but the folklore
staid for some reason)

Anyways here's my pitch:

It's a straight forward concept expressable as a page flag. Lots
of places need to check for it (we expect there will be more users
in the future). Also even crash dumps should check for it, so
it's important to have a clean interface.

Also it's an optional flag, if there's still an architecture
around which needs special caches in ->flags then it's unlikely
it will turn it on.

Also what's the alternative? Are you suggesting we should do huffman
encoding on flags or something? That seemed just too ugly, especially to solve 
a non problem.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
