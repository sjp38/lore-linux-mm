Subject: Re: [PATCH] Remove OOM killer from try_to_free_pages /
	all_unreclaimable braindamage
From: Thomas Gleixner <tglx@linutronix.de>
Reply-To: tglx@linutronix.de
In-Reply-To: <20041118070137.T28844@almesberger.net>
References: <20041105200118.GA20321@logos.cnet>
	 <200411051532.51150.jbarnes@sgi.com>
	 <20041106012018.GT8229@dualathlon.random>
	 <1099706150.2810.147.camel@thomas> <20041117195417.A3289@almesberger.net>
	 <419BDE53.1030003@tebibyte.org> <20041117210410.R28844@almesberger.net>
	 <419BECB0.70801@tebibyte.org> <20041117221419.S28844@almesberger.net>
	 <419C5B45.2080100@tebibyte.org>  <20041118070137.T28844@almesberger.net>
Content-Type: text/plain
Date: Thu, 18 Nov 2004 15:44:38 +0100
Message-Id: <1100789078.2635.73.camel@thomas>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Werner Almesberger <wa@almesberger.net>
Cc: Chris Ross <chris@tebibyte.org>, Andrea Arcangeli <andrea@novell.com>, Jesse Barnes <jbarnes@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-18 at 07:01 -0300, Werner Almesberger wrote:
> > Too often at present the machine just doesn't know what to do,
> 
> See, that's exactly what I mean :-) So, why not just tell it ?
> "Hey, things are going to get a little rough for a while. Why
> don't you take a nap on that comfty swap disk while I clean up
> the house ?"
> 
> > [ * I just looked it up: "of, relating to, or resembling the mental or 
> > emotional state believed induced by the god Pan". Cool ]
> 
> Hmm, you're suggesting we follow Morpheus instead of Pan then ?
> And I always thought the OOM killer was more like Eris' work :-)

Hmm, what about embedded boxes without swap ? There you have only one
choice. Kill anything appropriate. 

I tested Marcellos, Andreas and Andrews changes and they all change the
trigger of the oom-killer to prevent the spurious unneccecary kills. But
in the case where an oom-kill is neccecary I still need my modifications
to the whom to kill decision and to the oom-killer itself.

1. Not to kill the innocent and maybe important processes like sshd

This one is solved by taking the childs into account.

2. To prevent overkill. 

This still happens with all the modifications I have tested. 
The szenario is that two processes request memory in an OOM situation.
The first caller to oom-kill is making room and then the second one is
also going to kill something. 

The oom-killer must be protected against reentrancy and it must check
for the free memory level before finally doing the kill.
See my previous patch in this thread.

BTW, I found out that hackbench is a quite good replacement for my real
application in triggering these corner cases. Just increase the number
of processes until you reach the limit of the machine.

tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
