Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 55F8F6B007B
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 16:11:17 -0500 (EST)
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was:
 Re: [linux-pm] Memory allocations in .suspend became very unreliable)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <201001201231.17540.oliver@neukum.org>
References: <20100118110324.AE30.A69D9226@jp.fujitsu.com>
	 <195c7a901001190104x164381f9v4a58d1fce70b17b6@mail.gmail.com>
	 <1263943071.724.540.camel@pasglop>  <201001201231.17540.oliver@neukum.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Jan 2010 08:11:04 +1100
Message-ID: <1264021864.724.552.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oliver Neukum <oliver@neukum.org>
Cc: Bastien ROUCARIES <roucaries.bastien@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-01-20 at 12:31 +0100, Oliver Neukum wrote:
> 
> But we have the freezer. So generally we don't require that knowledge.
> We can expect no normal IO to happen.

That came before and it's just not a safe assumption :-) The freezer to
some extent protects drivers against ioctl's and that sort of stuff but
really that's about it. There's plenty of things in the kernel that can
kick IOs on their own for a reason or another, or do memory allocations
which in turn will try to push something out and do IOs etc... even when
"frozen".

> The question is in the suspend paths. We never may use anything
> but GFP_NOIO (and GFP_ATOMIC) in the suspend() path. We can
> take care of that requirement in the allocator only if the whole
> system
> is suspended. As soon as a driver does runtime power management,
> it is on its own. 

I'm not sure I understand what you are trying to say here :-)

First of all, the problem goes beyond what a driver does in its own
suspend() path. If it was just that, we might be able to some extent to
push enough stuff up for the driver to specify the right GFP flags
(though even that could be nasty).

The problem with system suspend also happens when your driver has not
been suspended yet, but another one, which happens to be a block device
with dirty pages for example, has.

Your not-yet-suspended driver might well be blocked somewhere in an
allocation or about to make one with some kind of internal mutex held,
that sort of thing, as part of it's normal operations, and -that- can
hang, causing problems when subsequently that same driver suspend() gets
called and tries to synchronize with the driver operations, for example
by trying to acquire that same mutex.

There's more of similarily nasty scenario. The fact is that it's going
to hit rarely, probably without a bakctrace or a crash, and so will
basically cause one of those rare "my laptop didn't suspend" cases that
may not even be reported, and just contribute to the general
unreliability of suspend/resume.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
