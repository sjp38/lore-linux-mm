Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l52EKm8c003519
	for <linux-mm@kvack.org>; Sat, 2 Jun 2007 10:20:49 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l52FNEUw493556
	for <linux-mm@kvack.org>; Sat, 2 Jun 2007 11:23:14 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l52FNDVp004189
	for <linux-mm@kvack.org>; Sat, 2 Jun 2007 11:23:14 -0400
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <46606C71.9010008@goop.org>
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org>
	 <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
	 <46606C71.9010008@goop.org>
Content-Type: text/plain
Date: Sat, 02 Jun 2007 10:23:10 -0500
Message-Id: <1180797790.18535.6.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 11:58 -0700, Jeremy Fitzhardinge wrote:
> Christoph Lameter wrote:
> > Hmmm... We got there because SLUB initially return NULL for kmalloc(0). 
> > Rationale: The user did not request any memory so we wont give him 
> > any.
> >
> > That (to my surprise) caused some strange behavior of code and so we then 
> > decided to keep SLAB behavior and return the smallest available object 
> > size and put a warning in there. At some later point we plan to switch
> > to returning NULL for kmalloc(0).
> >   
> 
> Unfortunately, returning NULL is indistinguishable from ENOMEM, so the
> caller would have to check to see how much it asked for before deciding
> to really fail, which doesn't help things much.
> 
> Or does it (should it) return ERRPTR(-ENOMEM)?  Bit of a major API
> change if not.

I'm on Christoph's side here.  I don't think it makes sense for any code
to ask to allocate zero bytes of memory and expect valid memory to be
returned.

Would a compromise be to return a pointer to some known invalid region?
This way the kmalloc(0) call would appear successful to the caller, but
any access to the memory would result in an exception.

Just my 2 cents,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
