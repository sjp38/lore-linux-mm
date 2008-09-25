Message-ID: <48DBD532.80607@goop.org>
Date: Thu, 25 Sep 2008 11:15:14 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: PTE access rules & abstraction
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>	 <1222117551.12085.39.camel@pasglop>	 <Pine.LNX.4.64.0809241919520.575@blonde.site>	 <1222291248.8277.90.camel@pasglop>	 <Pine.LNX.4.64.0809250049270.21674@blonde.site> <1222304686.8277.136.camel@pasglop>
In-Reply-To: <1222304686.8277.136.camel@pasglop>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Thu, 2008-09-25 at 00:55 +0100, Hugh Dickins wrote:
>   
>> Whyever not the latter?  Jeremy seems to have gifted that to you,
>> for precisely such a purpose.
>>     
>
> Yeah. Not that I don't quite understand what the point of the
> start/modify/commit thing the way it's currently used in mprotect since
> we are doing the whole transaction for a single PTE change, ie how does
> that help with hypervisors vs. a single ptep_modify_protection() for
> example is beyond me :-)
>
> When I think about transactions, I think about starting a transaction,
> changing a -bunch- of PTEs, then commiting... Essentially I see the PTE
> lock thing as being a transaction.

I think we need to be a bit clearer about the terminology:

A batch is a bunch of things that can be optionally deferred so they can
be done in chunks.

A transaction is something that must either complete successfully, or
have no effect at all.  Doing multiple things in a transaction means
that they must all complete or none.  (In general we assume there's
nothing about these low-level pagetable operations which can fail, so we
can ignore the failure part of transactions.)

In this case, a batch is not a transaction.  Doing things between
arch_enter_lazy_mmu_mode/arch_leave_lazy_mmu_mode makes no guarantees
about when operations are performed, other than guaranteeing that
they'll all be done by the time arch_leave_lazy_mmu_mode returns.  
Everything about how things are chunked into batches are up to the
underlying architecture, and the calling code can't make any assumptions
about it (the specific problem we've had to fix in a couple of places is
things expecting to be able to read back their recent pagetable
modifications immediately after issuing the call).

The ptep_modify_prot_start/commit pair specifies a single pte update in
such a way to allow more implementation flexibility - ie, there's no
naked requirement for an atomic fetch-and-clear operation.  I chose the
transaction-like terminology to emphasize that the start/commit
functions must be strictly paired; there's no way to fail or abort the
"transaction".  A whole group of those start/commit pairs can be batched
together without affecting their semantics.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
