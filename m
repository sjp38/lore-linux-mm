Date: Fri, 1 Jun 2007 11:38:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
In-Reply-To: <46603371.50808@goop.org>
Message-ID: <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Jeremy Fitzhardinge wrote:

> Perhaps I missed it, but what's the rationale for complaining about
> 0-sized allocations?  They seem like a perfectly reasonable thing to me;
> they turn up at the boundary conditions of many algorithms, and avoiding
> them just cruds up the callsites to make them go through hoops to avoid
> allocation. 

Hmmm... We got there because SLUB initially return NULL for kmalloc(0). 
Rationale: The user did not request any memory so we wont give him 
any.

That (to my surprise) caused some strange behavior of code and so we then 
decided to keep SLAB behavior and return the smallest available object 
size and put a warning in there. At some later point we plan to switch
to returning NULL for kmalloc(0).
 
> Why not just do a 1 byte allocation instead, and be done with it?  Any
> non-constant-sized allocation will potentially have to deal with this
> case, so it seems to me we could just put the fix in common code (and
> use an inline wrapper to avoid it when dealing with constant non-zero
> sized allocations).

The smallest allocation that SLUB can do is 8 bytes (SLAB 32). We are
giving the user the smallest object that we can allocate. We could just 
remove the warning and would have the behavior that you want.

But now allocating code gets memory although none was requested. The 
object can be modified without us being able to check.

By returning NULL any use of the returned pointer would BUG.

An allocation of zero bytes usually indicates that the code is not dealing 
with a special case. Later code may operate on the allocated object. I 
think its clearer and cleaner if code would deal with that special case 
explicitly. We have seen a series of code pieces that do uncomfortably 
looking operations on structures with no objects.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
