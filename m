Date: Mon, 14 Oct 2002 23:48:41 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch, feature] nonlinear mappings, prefaulting support,
 2.5.42-F8
In-Reply-To: <20021015011807.GA27718@bjl1.asuk.net>
Message-ID: <Pine.LNX.4.44.0210142341450.5788-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Oct 2002, Jamie Lokier wrote:
> 
> I like the SIGBUS.  Am I correct to assume that, when there is memory
> pressure, some pages are evicted from memory and all accesses to those
> pages from userspace will raise SIBUS until the mapping is
> reastablished?  Am I correct to assume this works fine on /dev/shm files?

It should work fine, assuming the shm interface has a "populate" macro.

The only real problem I think the interface has is that the nonlinear 
mappings cannot have private pages in them - because while the MM would be 
happy to swap them out, there is no sane way to get them back.

The private page information actually does exist in the page tables, but 
the _protection_ does not. That's in the VMA, and since one of the whole 
points with the nonlinear mapping is that the VMA is "anonymous", we're 
kind of screwed.

As it is, you cannot really even add private pages to the linear mapping: 
all the page add interfaces are for shared pages only. But I could imagine 
that it could be useful to have a "add private page here".

(The "add private page here" interface might also have a "use previous 
page if one existed" method, in which case the SIGBUS handler could just 
use that one, and thus generate the protection information on the fly - 
while generating the actual swap-in data from the page table entry itself)

Ingo - what do you think? I suspect a anonymous ("swap-backed" as opposed
to "backed by this file") interface might be quite useful.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
