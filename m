Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF716B005A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 11:58:09 -0400 (EDT)
Date: Wed, 8 Jul 2009 09:07:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
In-Reply-To: <20090708062125.GJ2714@wotan.suse.de>
Message-ID: <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain>
 <20090708062125.GJ2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



On Wed, 8 Jul 2009, Nick Piggin wrote:
> 
> I'm talking about the cases where you would want to use ZERO_PAGE for
> computing with anonymous memory (not for zeroing IO). In that case,
> the TLB would probably be the primary one.

Umm. Are you even listening to yourself?

OF COURSE the TLB would be the primary issue, since the zero page has made 
cache effects go away.

BUT THAT IS A GOOD THING.

Instead of making it sound like "that's a bad thing, because now TLB 
dominates", just say what's really going on: "that's a good thing, because 
you made the cache access patterns wonderful".

See? You claim TLB is a problem, but it's really that you made all _other_ 
problems go away. 

Now, it's true that you can avoid the TLB costs by moving the costs into a 
"software TLB" (aka "indirection table"), and make the TLB footprint go 
away by turning it into something else (indirection through a pointer). 

Sometimes that speeds things up - because you may be able to actually 
avoid doing other things by noticing huge gaps etc - but sometimes it 
slows you down too - because indirection isn't free, and maybe there are 
common cases where there isn't so many sparse accesses.

> I don't fight it. I had proposals to get rid of cache pingpong too,
> but you rejected that ;)

Yeah, and they were ugly as hell. I had a suggestion to just continue to 
use PG_reserved (which was _way_ simpler than your version) before the 
counting, but you and Hugh were on a religious agenda against the whole 
PG_reserved bit.

So I don't understand why you claim that you fight it, when you CLEARLY 
do. The patches that KAMEZAWA-san posted were already simpler than your 
complicated models were - I just think they can be simpler still.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
