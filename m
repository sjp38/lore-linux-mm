Subject: Re: [RFC] page fault retry with NOPAGE_RETRY
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0609151425050.22674@blonde.wat.veritas.com>
References: <1158274508.14473.88.camel@localhost.localdomain>
	 <20060915001151.75f9a71b.akpm@osdl.org>
	 <20060915003529.8a59c542.akpm@osdl.org>
	 <Pine.LNX.4.64.0609151425050.22674@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Sat, 16 Sep 2006 11:03:00 +1000
Message-Id: <1158368580.14473.207.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Mike Waychison <mikew@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-09-15 at 14:30 +0100, Hugh Dickins wrote:
> On Fri, 15 Sep 2006, Andrew Morton wrote:
> > 
> > This assumes that no other heavyweight process will try to modify this
> > single-threaded process's mm.  I don't _think_ that happens anywhere, does
> > it?  access_process_vm() is the only case I can think of,
> 
> "Modify" in the sense of fault into.
> Yes, access_process_vm() is all I can think of too.
> 
> > and it does down_read(other process's mmap_sem).
> 
> If there were anything else, it'd have to do so too (if not down_write).
> 
> I too like NOPAGE_RETRY: as you've both observed, it can help to solve
> several different problems.

Yes, I don't need any of the safeguards that Andrew mentioned in my case
though. I want to return all the way to userland because I want signals
to be handled (which might also be a good thing in your case in fact, so
that a process being starved by that new mecanism can still be
interrupted).

I would ask that if you decide that the more complex approach is not
2.6.19 material, that the simple addition of NOPAGE_RETRY as I've
defined could be included in a first step so I can solve my problem (and
possibly other drivers wanting to do funky things with no_page() and
still take signals), and the google patch be rebased on top of that for
additional simmering :)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
