Subject: Re: [patch 3/8] mm: merge nopfn into fault
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
Content-Type: text/plain
Date: Thu, 24 May 2007 09:40:19 +1000
Message-Id: <1179963619.32247.991.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-18 at 08:23 -0700, Linus Torvalds wrote:
> 
> If we are changing the calling semantics of "nopage", then we should also 
> remove the horrible, horrible hack of making the "nopfn" function itself 
> do the "populate the page tables".
> 
> It would be *much* better to just

  .../...

> and let the caller always insert the thing into the page tables.
> 
> Wouldn't it be nice if we never had drivers etc modifying page tables 
> directly? Even with helpers like "vm_insert_pfn()"?

The problem is that this is racy vs. concurrent unmap_mapping_range().

As I explained in my previous email, spufs and the DRI are 2 examples
where we need to expose to userland a mapping whose backing PFN's have
to be switched between different physical storage.

The only way I've found to have this be race free is to have the
->nopfn() function do the actual PTE insertion while holding a
lock/mutex that is also taken by whatever calles unmap_mapping_range()
when the switching occurs).

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
