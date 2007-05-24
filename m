Date: Wed, 23 May 2007 19:04:28 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
In-Reply-To: <20070524014223.GA22998@wotan.suse.de>
Message-ID: <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
 <1179963619.32247.991.camel@localhost.localdomain>
 <20070524014223.GA22998@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 24 May 2007, Nick Piggin wrote:
> 
> At most, if Linus really doesn't want ->fault to do the nopfn thing, then
> I would be happy to leave in ->nopfn... but I don't see much reason not
> to just merge them anyway... one fewer branch and less code in the
> page fault handler.

I just think that the "->fault" calling convention is _broken_.

If you want to install the PFN in the low-level driver, just

 - pass the whole "struct vm_fault" to the PFN-installing thing (so that 
   the driver at least doesn't have to muck with the address)

 - return a nice return value saying that you aren't returning a page. And 
   since you *also* need to return a value saying whether the page you 
   want to install is locked or not, that just means that the "struct page 
   *" approach (with a few extra error cases) won't cut it.

 - don't add yet another interface. Replace it cleanly. If you don't want 
   to re-use the name, fine, but at least replace it with something 
   better. 

The old "nopage()" return values weren't exactly pretty before either, but 
dang, do we really have to make it even MORE broken by having to have 
_both_ the old and the new ones, with different interfaces and magic 
locking rules depending on flags? I say "no".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
