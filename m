Date: Thu, 24 May 2007 04:16:16 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
Message-ID: <20070524021616.GB13694@wotan.suse.de>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net> <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org> <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de> <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 07:04:28PM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 24 May 2007, Nick Piggin wrote:
> > 
> > At most, if Linus really doesn't want ->fault to do the nopfn thing, then
> > I would be happy to leave in ->nopfn... but I don't see much reason not
> > to just merge them anyway... one fewer branch and less code in the
> > page fault handler.
> 
> I just think that the "->fault" calling convention is _broken_.
> 
> If you want to install the PFN in the low-level driver, just
> 
>  - pass the whole "struct vm_fault" to the PFN-installing thing (so that 
>    the driver at least doesn't have to muck with the address)

I was going to suggest that too, not a bad idea, but I think it is
not a big problem if we allow some special drivers to get access to
the address if they need to (otherwise they'll just go off and try
to invent their own thing).


>  - return a nice return value saying that you aren't returning a page. And 
>    since you *also* need to return a value saying whether the page you 
>    want to install is locked or not, that just means that the "struct page 
>    *" approach (with a few extra error cases) won't cut it.

Yeah we can do that. We could have the VM_FAULT_ code in the first byte,
and return flags in the second, with the upper 2 bytes reserved... or
something like that.


>  - don't add yet another interface. Replace it cleanly. If you don't want 
>    to re-use the name, fine, but at least replace it with something 
>    better. 

I will definitely do that, but it is far easier to first merge it and
*then* clean up the drivers, rather than carry around all the patches
to do it. The nopage compat code is really small, so I don't see a
problem with carrying it around for a few -rcs until people have had time
to test and ack their driver conversions.

Actually I had a tear in my eye when removing the nopage name... it is
more quirky and has more character than the bland "fault"! :)

 
> The old "nopage()" return values weren't exactly pretty before either, but 
> dang, do we really have to make it even MORE broken by having to have 
> _both_ the old and the new ones, with different interfaces and magic 
> locking rules depending on flags? I say "no".

Well thanks a lot for the feedback. I'll try to make some improvements
and hopefully we can try again when 2.6.23 opens.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
