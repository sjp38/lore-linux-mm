Date: Wed, 29 Nov 2006 07:48:34 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Slab: Remove kmem_cache_t
In-Reply-To: <456D1FDA.4040201@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0611290738270.3395@woody.osdl.org>
References: <Pine.LNX.4.64.0611281847030.12440@schroedinger.engr.sgi.com>
 <456D0757.6050903@yahoo.com.au> <Pine.LNX.4.64.0611281923460.12646@schroedinger.engr.sgi.com>
 <456D0FC4.4050704@yahoo.com.au> <20061128200619.67080e11.akpm@osdl.org>
 <Pine.LNX.4.64.0611282027431.3395@woody.osdl.org> <456D1FDA.4040201@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 29 Nov 2006, Nick Piggin wrote:
> 
> I don't see why pagetable types are conceptually different from slab here.

Because they are fundamentally _different_ on different architectures.

If they were always the same, they wouldn't be typedefs.

> pagetable types can all have the same struct name. Should we do a script
> to change them?

Theyt aren't even necessarily structs. They're quite often "unsigned 
long".

In fact, they were that on x86 for the longest time (and making them into 
a struct was a conscious thing to make sure that you couldn't use them as 
integers even by mistake).

> > 	"kmem_cache_t" is strictly _worse_ than "struct kmem_cache", not
> > just because it causes declaration issues. It also hides the fact 	that
> > the thing really is a structure (and hiding the fact that 	it's a pointer
> > is a shooting offense: things like "voidptr_t" 	should not be allowed
> > at all)
> 
> Umm, but it's not a pointer, is it?

No, I'm saying that some people hide the pointer-ness inside the typedef 
too, and that should be a shooting offence.

> I think slab.c should use struct kmem_cache, but I don't see why this script
> needs to change over all callers. At least, not in the name of solving
> dependency issues?!?

The dependency issues can come up because of a problem with typedefs.

It's strictly an error to declare the same typedef twice in the same 
scope. So if you want to have robust header files, you can do that only in 
a _single_ place. Which in turn means that you always have a dependency on 
that magic header in anything that needs it.

On the other hand, you can always pre-declare an opaque structure however 
many times you want, so there is no similar problem at all with "struct 
kmem_cache". You can just sprinkle that one-liner "I know there is such a 
thing, although I don't know what it contains" in multiple places, and 
break the dependency.

So "typedef" is strictly _inconvenient_ too, if you want to have split 
header files.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
