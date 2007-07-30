Date: Mon, 30 Jul 2007 11:39:21 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [SPARC32] NULL pointer derefference
In-Reply-To: <20070729.211929.78713482.davem@davemloft.net>
Message-ID: <Pine.LNX.4.61.0707301127050.679@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0707300301340.32210@mtfhpc.demon.co.uk>
 <20070729.211929.78713482.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: aaw@google.com, akpm@linux-foundation.org, linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, wli@holomorphy.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi David,

Thanks for the comments.

On Sun, 29 Jul 2007, David Miller wrote:

> From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
> Date: Mon, 30 Jul 2007 03:18:42 +0100 (BST)
>
>> Unfortunatly Sparc32 sun4c low level memory management apears to be
>> incompatible with commit b6a2fea39318e43fee84fa7b0b90d68bed92d2ba
>> mm: variable length argument support.
>>
>> For some reason, this commit corrupts the memory used by the low level
>> context/pte handling ring buffers in arch/sparc/mm/sun4c (in
>> add_ring_ordered, head->next becomes set to a NULL pointer).
>>
>> I had a quick look at http://www.linux-mm.org to see if there were any
>> diagrams that show what is going on in the memory management systems, to
>> see if there was something that I could use to help me work out what is
>> going on, but I could not see any.
>
> One possible issue is sequencing, perhaps the stack argument copy
> is occuring before the new context is setup properly on sun4c.
>

I will see if I can generate some debug code to check out this posibility.

> Another issue might be the new flush_cache_page() call in this
> new code in fs/exec.c, there are now cases where flush_cache_page()
> will be called on kernel addresses, and sun4c's implementation might
> not like that at all.
>

I backed the commit out of my latest git pull (app 2am this morning) and I 
end up with a working kernel so this confirms that is is somthing 
specific to this patch.

I will try adding in a flush_cache_page() at an appropriate point on the 
pre-commit version of the code to see if that makes a mess of things.

Regards
 	Mark Fortescue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
