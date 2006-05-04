From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: RCU protected page table walking
Date: Thu, 4 May 2006 14:00:34 +0200
References: <4458CCDC.5060607@bull.net> <200605041131.46254.ak@suse.de> <4459E663.10008@bull.net>
In-Reply-To: <4459E663.10008@bull.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605041400.34851.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On Thursday 04 May 2006 13:32, Zoltan Menyhart wrote:
> Andi Kleen wrote:
> 
> > We don't free the pages until the other CPUs have been flushed synchronously.
> 
> Do you mean the TLB entries mapping the leaf pages?
> If yes, then I agree with you about them.
> Yet I speak about the directory pages. Let's take an example:

x86 uses this for the directory pages too (well for PMD/PUD - PGD never
goes away until final exit). Actually x86-64 didn't
fully at some point and it resulted in a nasty to track down bug.
But it was fixed then. I really went all over this with a very fine
comb back then and I'm pretty sure it's correct now :)

> > After the flush the other CPUs don't walk pages anymore.
> 
> Can you explain please why they do not?

Because the PGD/PMD/PUD has been rewritten and they won't be able
to find the old pages anymore. They also don't have it in their
TLBs because that has been flushed.

The problem I had on x86-64 was because visible the AMD CPUs internally cached
PMD/PGDs.

> There is a possibility that walking has already been started, but it has
> not been completed yet, when "free_pgtables()" runs.
>

Yes, that is why we delay the freeing of the pages to prevent anything
going wrong.

> > The whole thing is
> > batched because the synchronous flush can be pretty expensive.
> 
> Walking the page tables in physical mode 

What do you mean with "physical mode"?

> is insensitive to any TLB purges, 
> therefore these purges do not make sure that there is no other CPU just
> in the middle of page table walking.

A TLB Flush stops all MMU activity - or rather waits for it to finish.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
