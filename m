Message-ID: <4186E41E.5080909@yahoo.com.au>
Date: Tue, 02 Nov 2004 12:34:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
References: <4181EF2D.5000407@yahoo.com.au> <20041029074607.GA12934@holomorphy.com> <Pine.LNX.4.58.0411011612060.8399@server.graphe.net> <20041102005439.GQ2583@holomorphy.com>
In-Reply-To: <20041102005439.GQ2583@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <christoph@lameter.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Fri, 29 Oct 2004, William Lee Irwin III wrote:
> 
>>>This raises the rather serious question of what you actually did
>>>besides rearranging Lameter's code. It had all the same problems;
>>>resolving them is a prerequisite to going anywhere with all this.
> 
> 
> On Mon, Nov 01, 2004 at 04:15:41PM -0800, Christoph Lameter wrote:
> 
>>Could you be specific as to the actual problems? I have worked through
>>several archs over time and my code offers a fallback to the use of the
>>page_table_lock if an arch does not provide the necessary atomic ops.
>>So what are the issues with my code? I fixed the PAE code based on Nick's
>>work. AFAIK this was the only known issue.
> 
> 
> Well, I'm not going to sit around and look for holes in this all day
> (that should have been done by the author), however it's not a priori
> true that decoupling locking surrounding tlb_flush_mmu() from pte
> locking is correct.
> 

It still turns preempt off, so you're pinned to the CPU.

It is not a problem for the arch independant code. tlb_xxx
are done after eg. ptep_get_and_clear, so there is no more
serialisation needed there.

The only problem would be architectures that rely on it in their
flush implementations; i386 doesn't look like it needs that. It
would only stop two flushes to the same mm from going on in
parallel, but its already taking a global lock there where it
matters anyway...

...And architectures like SPARC64 that rely on it for external
synchronisation. In that case you saw my trivial patch to revert
to the old behaviour for that arch.

But aside from all that, Christoph's patch _doesn't_ move the
locking out of tlb_gather operations IIRC.

> The audits behind this need to be better.
> 

Sure I haven't audited all architectures. I thought it was
pretty clear that one could fall back to the old behaviour
if required.

Why do you say the audits need to be better? No doubt there will
still be bugs, but I didn't just say "ahh let's remove the lock
from around the tlb operations and pray it works".

I could very well be missing something though - You must be
seeing some fundamental problems or nasty bugs to say that it's
been designed it in a vacuum, and that the audits are no good...
What are they please?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
