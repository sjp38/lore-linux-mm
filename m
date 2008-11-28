Date: Fri, 28 Nov 2008 13:21:58 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] lockdep: check fs reclaim recursion
Message-ID: <20081128122158.GD13786@wotan.suse.de>
References: <20081128120548.GB13786@wotan.suse.de> <20081128121127.GF18333@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081128121127.GF18333@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 28, 2008 at 01:11:27PM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > Hi,
> > 
> > After yesterday noticing some code in mm/filemap.c accidentally perform 
> > a __GFP_FS allocation when it should not have been, I thought it might 
> > be a good idea to try to catch this kind of thing with lockdep.
> > 
> > I coded up a little idea that seems to work. Unfortunately the system 
> > has to actually be in __GFP_FS page reclaim, then take the lock, before 
> > it will mark it. But at least that might still be some orders of 
> > magnitude more common (and more debuggable) than an actual deadlock 
> > condition, so we have some improvement I hope.
> > 
> > I guess we could do the same thing with __GFP_IO and even GFP_NOIO 
> > locks too, but I don't know how expensive it is to add these 
> > annotations to lockdep. [...]
> 
> Same cost as normal locking, i.e. as cheap and local as it gets. Lockdep 
> is only expensive computationally when new rules are discovered and have 
> to be validated - but that is rare.

OK, good... I'll think about whether it makes sense to add those locks.
Actually, it probably makes sense to merge the __GFP_FS thing first,
with a design that will allow further types to be added easily.

 
> Nice feature - and we want more of this type of preventive dependency 
> tracking - so feel free to add it whenever you run into an example like 
> this.

Well, lockdep has most of the support with iits "recusion possibility"
checking for interrupts. All the names in the lockdep code are geared
completely toward interrupts, but the concept is almost exactly the same
here (I can't think if there are any other important points in the kernel
where similar situation can arise, but it wouldn't surprise me if there
is). 


> What merge route would you prefer? tip/core/locking would be the natural 
> home of it (we already have a fair bit of lockdep stuff queued up there 
> for v2.6.29) - it also touches a few FS bits.

I'm happy for you or Peter to merge yet though there, sure. Just let
me get some more input and then I'll try fix it up and make it merge
worthy :)

BTW. Do you have the might_lock annotations in there? I thought I'd see
them in 2.6.28, but they don't seem to be there. No problems with them?

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
