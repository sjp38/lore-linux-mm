Date: Fri, 28 Nov 2008 13:11:27 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [rfc] lockdep: check fs reclaim recursion
Message-ID: <20081128121127.GF18333@elte.hu>
References: <20081128120548.GB13786@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081128120548.GB13786@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>


* Nick Piggin <npiggin@suse.de> wrote:

> Hi,
> 
> After yesterday noticing some code in mm/filemap.c accidentally perform 
> a __GFP_FS allocation when it should not have been, I thought it might 
> be a good idea to try to catch this kind of thing with lockdep.
> 
> I coded up a little idea that seems to work. Unfortunately the system 
> has to actually be in __GFP_FS page reclaim, then take the lock, before 
> it will mark it. But at least that might still be some orders of 
> magnitude more common (and more debuggable) than an actual deadlock 
> condition, so we have some improvement I hope.
> 
> I guess we could do the same thing with __GFP_IO and even GFP_NOIO 
> locks too, but I don't know how expensive it is to add these 
> annotations to lockdep. [...]

Same cost as normal locking, i.e. as cheap and local as it gets. Lockdep 
is only expensive computationally when new rules are discovered and have 
to be validated - but that is rare.

Nice feature - and we want more of this type of preventive dependency 
tracking - so feel free to add it whenever you run into an example like 
this.

What merge route would you prefer? tip/core/locking would be the natural 
home of it (we already have a fair bit of lockdep stuff queued up there 
for v2.6.29) - it also touches a few FS bits.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
