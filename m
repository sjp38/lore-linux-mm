Received: from petasus.hd.intel.com (petasus.hd.intel.com [10.127.45.3])
	by hermes.hd.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id h1Q4gHJ05532
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 04:42:17 GMT
Received: from orsmsxvs040.jf.intel.com (orsmsxvs040.jf.intel.com [192.168.65.206])
	by petasus.hd.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.28 2003/01/13 19:44:39 dmccart Exp $) with SMTP id h1Q4eg526650
	for <linux-mm@kvack.org>; Wed, 26 Feb 2003 04:40:42 GMT
Message-ID: <A46BBDB345A7D5118EC90002A5072C780A7D57E6@orsmsx116.jf.intel.com>
From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Date: Tue, 25 Feb 2003 20:44:08 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'Martin J. Bligh'" <mbligh@aracnet.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> From: Martin J. Bligh [mailto:mbligh@aracnet.com]
> 
> >> > I have a user space page (I know the 'struct page *' and I did a
> >> > get_page() on it so it doesn't go away to swap) and I need to be able
> >> > to access it with normal pointers (to do a bunch of atomic operations
> >> > on it). I cannot use get_user() and friends, just pointers.
> >> >
> >> > So, the question is, how can I map it into the kernel space in a
> >> > portable manner? Am I missing anything very basic here?
> >>
> >> kmap or kmap_atomic
> >
> > I am trying to use kmap_atomic(), but what is the meaning of the second
> > argument, km_type? I cannot find it anywhere, or at least the difference
> > between KM_USER0 and KM_USER1, which I am guessing are the ones I need.
> 
> Each type is for a different usage, and you need to ensure that two things
> can't reuse the same type at once. As long as interrupts, or whatever
> could
> disturb you can't use what you use, you're OK. Note that you can't hold
> kmap_atomic over a schedule (presumably this means no pre-emption either).

Hmmm, ok, my scenario is this:

System call entry point (these are futex modifications),
kernel/futex.c:futex_wake() and kernel/futex.c:futex_wait(). Both of them
will require to kmap_atomic a page. When they are talking about the same
futex (say three guys come in at the same time, one to unlock, two to lock),
the three of them might end up doing kmap_atomic() over the same page. 

So, are you telling me that for that to work, I have to either:

- each caller uses a different KM_USER<WHATEVER> [kind of clumsy]

- I shall protect the kmap_atomic() region with an spinlock, to serialize
it? [note I have the spinlock already, so it'd be a matter of spinlocking
_before_ kmap_atomic() instead of after - ugly for a quick consistency
check, but can live with it].

I think I still don't really understand what's up with the KM_ flags :]

Thanks,

Inaky Perez-Gonzalez -- Not speaking for Intel -- all opinions are my own
(and my fault)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
