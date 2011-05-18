Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 02F1F6B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:48:24 -0400 (EDT)
Date: Wed, 18 May 2011 21:48:11 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-ID: <20110518194811.GD6225@elte.hu>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
 <20110518062554.GB2945@elte.hu>
 <1305745409.2915.178.camel@work-vm>
 <20110518123335.62785884.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110518123335.62785884.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


(Linus Cc:-ed)

* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 18 May 2011 12:03:29 -0700
> John Stultz <john.stultz@linaro.org> wrote:
> 
> > But, the net of this is that it seems everyone else is way more passionate 
> > about this issue then I am, so I'm starting to wonder if it would be better 
> > for someone who has more of a dog in the fight to be pushing these?
> 
> I like the %p thingy - it's neat and is an overall improvement.
> [...]
>
> Providing an unlocked accessor for super-special applications which know what 
> they're doing seems an adequate compromise.

Dunno, %ptc ties into lowlevel sprintf() and takes a spinlock! We are 
unrobustizing an important lowlevel function that until today could always be 
used lockless for debugging, in any context, under any circumstance.

We do that just to solve something that occurs rather rarely and has no 
functional effect just some temporarily confusing looking string descriptor 
output.

The *last* place i'd put this into is vsprintf(), really. Make the procfs 
output methods atomic against ->comm update, sure. But put a lock like that 
into kernel debug output? No way!

(Btw, i find %ptc OK if it comes with no lock. %pt would be nicer as a name?)

I'm uneasy about it if i think how many hairy places handle task->comm[].

Anyway, vsprintf() is Linus code, so i can take the easy road, chicken out and 
punt this to Linus - instead of risking a needle from Andrew! :)

If Linus likes this approach we should do it with a lock.

> [...]  If it dies I shall stick another pin in my Ingo doll.

Oh, out of morbid curiosity, mind providing a log of bigger past incidents 
where you had to stick pins into a doll of me? (In private mail, if the list is 
too long ;-)

(Does every lockdep report that catches a real bug unpull a needle? ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
