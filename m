Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5413jak006202
	for <linux-mm@kvack.org>; Sun, 3 Jun 2007 21:03:45 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5413jhe543784
	for <linux-mm@kvack.org>; Sun, 3 Jun 2007 21:03:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5413ihE031830
	for <linux-mm@kvack.org>; Sun, 3 Jun 2007 21:03:44 -0400
Subject: Re: [RFC 0/4] CONFIG_STABLE to switch off development checks
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <46619AB6.5060606@goop.org>
References: <20070531002047.702473071@sgi.com> <46603371.50808@goop.org>
	 <Pine.LNX.4.64.0706011126030.2284@schroedinger.engr.sgi.com>
	 <46606C71.9010008@goop.org>
	 <1180797790.18535.6.camel@kleikamp.austin.ibm.com>
	 <46619AB6.5060606@goop.org>
Content-Type: text/plain
Date: Sun, 03 Jun 2007 20:03:41 -0500
Message-Id: <1180919021.8897.19.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, 2007-06-02 at 09:28 -0700, Jeremy Fitzhardinge wrote:
> Dave Kleikamp wrote:
> > I'm on Christoph's side here.  I don't think it makes sense for any code
> > to ask to allocate zero bytes of memory and expect valid memory to be
> > returned.
> >   
> 
> Yes, everyone agrees on that.  If you do kmalloc(0), its never OK to
> dereference the result.  The question is whether kmalloc(0) should complain.

Yeah, I see that you aren't necessarily asking for valid memory, just
something that appears valid.  I'm still of the mind that if code is
asking for a zero-length allocation, it's raising a flag that it's not
taking some corner case into account.  But I think I'm just
regurgitating what Christoph is arguing.

> > Would a compromise be to return a pointer to some known invalid region?
> > This way the kmalloc(0) call would appear successful to the caller, but
> > any access to the memory would result in an exception.
> >   
> 
> Yes, that's what Christoph has posted.

Oh.  I went back and re-read the thread and it looks like you proposed
this already.  I don't see where Christoph did, or agreed, but maybe I
missed something.

> I'm slightly concerned about
> kmalloc() returning the same non-NULL address multiple times, but it
> seems sound otherwise.

If the caller is asking for 0 bytes, it shouldn't be doing anything with
the returned address except checking for a NULL return.  But then, it's
hard to predict everything that calling code might be doing, such as
allocating buffers and creating a hash based on their addresses.  Of
course, if there's code that would have a problem with it, I think it's
a further argument that it would be better off avoiding the calling
kmalloc(0) in the first place.

Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
