Subject: Re: PTE access rules & abstraction
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <Pine.LNX.4.64.0809241919520.575@blonde.site>
References: <1221846139.8077.25.camel@pasglop>  <48D739B2.1050202@goop.org>
	 <1222117551.12085.39.camel@pasglop>
	 <Pine.LNX.4.64.0809241919520.575@blonde.site>
Content-Type: text/plain
Date: Thu, 25 Sep 2008 07:20:48 +1000
Message-Id: <1222291248.8277.90.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-09-24 at 19:45 +0100, Hugh Dickins wrote:

> The powerpc bug whereof you write appears to have been there since ...
> linux-2.4.0 or earlier:
> 			entry = ptep_get_and_clear(pte);
> 			set_pte(pte, pte_modify(entry, newprot));
> 
> But perhaps powerpc was slightly different back in those days.
> It sounds to me like a bug in your current ptep_get_and_clear(),
> not checking if already hashed?

Yes, I figured out the bug was already there. And no, it's not the
right approach to have ptep_get_and_clear() flush because it would
mean that call cannot batch flushes, and thus we would lose ability to
batch in zap_pte_range().

> Though what we already have falls somewhat short of perfection,
> I've much more enthusiasm for fixing its bugs, than for any fancy
> redesign introducing its own bugs.  Others have more stamina!

Well, the current set accessor, as far as I'm concerned is a big pile of
steaming shit that evolved from x86-specific gunk raped in different
horrible ways to make it looks like it fits on other architectures and
additionally mashed with goo to make it somewhat palatable by
virtualization stuff. Yes, bugs can be fixed but it's still an horrible
mess.

Now, regarding the above bug, I'm afraid the only approaches I see that
would work would be to have either a ptep_get_and_clear_flush(), which I
suppose x86 virt. people will hate, or maybe to actually have a powerpc
specific variant of the new start/commit hooks that does the flush.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
