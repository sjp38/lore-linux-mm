Date: Tue, 20 May 2008 11:51:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to
 ksize().
In-Reply-To: <1211307820.18026.190.camel@calx>
Message-ID: <Pine.LNX.4.64.0805201149270.10868@schroedinger.engr.sgi.com>
References: <20080520095935.GB18633@linux-sh.org>  <2373.1211296724@redhat.com>
  <Pine.LNX.4.64.0805200944210.6135@schroedinger.engr.sgi.com>
 <1211307820.18026.190.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 May 2008, Matt Mackall wrote:

> > Hmm. That means we are sanctioning using ksize on arbitrary objects? SLUB 
> > supports that but SLAB wont and neither will SLOB. I think we need to stay 
> > with the strict definition that is needed by SLOB.
> 
> Of course SLUB won't be able to tell you the size of objects allocated
> statically, through bootmem, etc.

Right the function actually give misleading results even if you just pass 
a pointer to an int at an address that is page backed but not using a slab 
allocator. Then PAGE_SIZE will be returned?

So the semantics are screwed up here. kobjsize() should only be called for 
slab objects. 

Remove kobjsize completely and replace with calls to ksize? Callers must 
not call ksize() on non slab objects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
