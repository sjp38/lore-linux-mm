Message-ID: <46606C71.9010008@goop.org>
Date: Fri, 01 Jun 2007 11:58:57 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org> <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Hmmm... We got there because SLUB initially return NULL for kmalloc(0). 
> Rationale: The user did not request any memory so we wont give him 
> any.
>
> That (to my surprise) caused some strange behavior of code and so we then 
> decided to keep SLAB behavior and return the smallest available object 
> size and put a warning in there. At some later point we plan to switch
> to returning NULL for kmalloc(0).
>   

Unfortunately, returning NULL is indistinguishable from ENOMEM, so the
caller would have to check to see how much it asked for before deciding
to really fail, which doesn't help things much.

Or does it (should it) return ERRPTR(-ENOMEM)?  Bit of a major API
change if not.

>> Why not just do a 1 byte allocation instead, and be done with it?  Any
>> non-constant-sized allocation will potentially have to deal with this
>> case, so it seems to me we could just put the fix in common code (and
>> use an inline wrapper to avoid it when dealing with constant non-zero
>> sized allocations).
>>     
>
> The smallest allocation that SLUB can do is 8 bytes (SLAB 32). We are
> giving the user the smallest object that we can allocate. We could just 
> remove the warning and would have the behavior that you want.
>   

I think that's reasonable.  0-sized allocations seem to be relatively
rare anyway, so its not like we're going to be filling the heap with
these things.

I'm getting a couple of these warnings out of my code, but I've been
hesitating about fixing them because I can't see it resulting in any
improvement, either locally or globally - it would just be to shut the
warning up.

> But now allocating code gets memory although none was requested. The 
> object can be modified without us being able to check.
>   

Yes, that's a problem, but maybe heap debugging would help (ie, if
enabled make sure the "zero-sized allocation" pattern is undisturbed). 
Or return a pointer to a specific non-NULL unmapped address, though that
would need special handling on the free side.  Also, callers may get
upset if they get non-unique non-NULL addresses back from allocation.

> By returning NULL any use of the returned pointer would BUG.
>   

Well, actually it would stomp usermode memory, but we generally assume
there's nothing mapped at 0.  Or there are no bugs.

> An allocation of zero bytes usually indicates that the code is not dealing 
> with a special case. Later code may operate on the allocated object. I 
> think its clearer and cleaner if code would deal with that special case 
> explicitly. We have seen a series of code pieces that do uncomfortably 
> looking operations on structures with no objects.
>   

I disagree.  There are plenty of boundary conditions where 0 is not
really a special case, and making it a special case just complicates
things.  I think at least some of the patches posted to silence this
warning have been generally negative for code quality.  If we were
seeing lots of zero-sized allocations then that might indicate something
is amiss, but it seems to me that there's just a scattered handful.

I agree that it's always a useful debugging aid to make sure that
allocated regions are not over-run, but 0-sized allocations are not
special in this regard.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
