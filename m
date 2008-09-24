Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <48DAC285.80507@goop.org>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
	 <1222291248.8277.90.camel@pasglop>  <48DAB7E2.5030009@goop.org>
	 <1222294041.8277.104.camel@pasglop>  <48DAC285.80507@goop.org>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 08:53:04 +1000
Message-Id: <1222296784.8277.126.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Chubb <peterc@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

> Yes, that sounds fine in principle, but the practise gets tricky.  The
> trouble with that kind of interface is that it can be fairly heavyweight
> unless you amortise the cost of the transaction setup/commit with
> multiple operations.

I agree. Anyway, I'm sure if we get everybody around the same table, we
can find something, maybe not that high level, but a better set of
accessors that fits all needs with a more precise semantic. Anyway, I'll
see if I can come up with ideas later that we can discuss.

It's also all inline so it does give us flexibility in having things
compile down to nothing on archs where they aren't needed.

> Are you using the lazy_mmu hooks we put in, or something else?

Yes. We used to do it differently but it was actually racy in a subtle
way, and I switched it to use your lazy_mmu hooks a while ago.

> Likely; it's one of those overused generic words.  The specific meaning
> I'm using is "we can roll a bunch of updates into a single hypercall". 
> Operations which do atomic RMW  or fetch-set are typically not batchable
> because the caller wants the result *now* and can't wait for a deferred
> result.

Right. For us it's mostly about flushing the hash entries, though there
is no fundamental difference I believe here, it's about updating a
cache, whether it's the TLB, our hash table, hypervisor shadows, etc...
and we -should- be able to find a more sensible common ground.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
