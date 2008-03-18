Date: Tue, 18 Mar 2008 10:42:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [git pull] slub fallback fix
In-Reply-To: <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0803181037470.21992@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com>
 <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Linus Torvalds wrote:

> > We need to reenable interrupts before calling the page allocator from the
> > fallback path for kmalloc. Used to be okay with the alternate fastpath 
> > which shifted interrupt enable/disable to the fastpath. But the slowpath
> > is always called with interrupts disabled now. So we need this fix.
> 
> I think this fix is bogus and inefficient.
> 
> The proper fix would seem to be to just not disable the irq's 
> unnecessarily!
> 
> We don't care what the return state of the interrupts are, since the 
> caller will restore the _true_ interrupt state (which we don't even know 
> about, so we can't do it). 
> 
> So why isn't the patch just doing something like the appended instead of 
> disabling and enabling interrupts unnecessarily?

Fallback is rare and I'd like to have the fallback logic in one place. It 
would also mean that the interrupt state on return to slab_alloc() would 
be indeterminate. Currently that works but it may be surprising in the 
future when changes are made there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
