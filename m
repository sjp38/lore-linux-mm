Date: Tue, 22 Apr 2008 05:14:14 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2]: introduce fast_gup
Message-ID: <20080422031414.GA21993@wotan.suse.de>
References: <20080328025455.GA8083@wotan.suse.de> <20080328030023.GC8083@wotan.suse.de> <1208444605.7115.2.camel@twins> <alpine.LFD.1.00.0804170814090.2879@woody.linux-foundation.org> <1208448768.7115.30.camel@twins> <alpine.LFD.1.00.0804170916470.2879@woody.linux-foundation.org> <1208450119.7115.36.camel@twins> <alpine.LFD.1.00.0804170940270.2879@woody.linux-foundation.org> <1208453014.7115.39.camel@twins> <alpine.LFD.1.00.0804171127310.2879@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0804171127310.2879@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, axboe@kernel.dk, linux-mm@kvack.org, linux-arch@vger.kernel.org, Clark Williams <williams@redhat.com>, Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 11:28:45AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 17 Apr 2008, Peter Zijlstra wrote:
> > 
> > D'0h - clearly not my day today...
> 
> Ok, I'm acking this one ;)
> 
> And yes, it would be nice if the gup patches would go in early, since I 
> wouldn't be entirely surprised if other architectures didn't have some 
> other subtle issues here. We've never accessed the page tables without 
> locking before, so we've only had races with hardware, never software.

Well I'd love them to go in 2.6.26. Andrew will be sending you some
precursor patches soon, and then I can rediff the x86 fast_gup.

We actually do access the page tables without the traditional linux vm
locking in architectures like powerpc that do software pagetable walks.
That's why their pagetables are RCUed for example.

So the concept is actually more foreign to x86 than it is to some others.

BTW. we do have powerpc patches for fast_gup. The "problem" with that
is that it requires my speculative page references from the lockless
pagecache patches (basically fast_gup for powerpc is exactly like
lockless pagecache but substitute the pagecache radix tree for the
page tables). But that might have to wait for 2.6.27. At least we'll
have the x86 fast_gup.

But the upshot is that I now have "real world" benchmark results to
justify adding the complexity of speculative references. After that,
adding lockless pagecache is more or less a noop ;) Everything's
falling into place, mwa ha ha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
