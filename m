Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 592476B01FA
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 11:56:52 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b559c57a-0acb-4338-af21-dbfc3b3c0de5@default>
Date: Fri, 23 Apr 2010 08:56:17 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <20100422134249.GA2963@ca-server1.us.oracle.com>
 <4BD06B31.9050306@redhat.com> <53c81c97-b30f-4081-91a1-7cef1879c6fa@default>
 <4BD07594.9080905@redhat.com> <b1036777-129b-4531-a730-1e9e5a87cea9@default>
 <4BD16D09.2030803@redhat.com> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
 <4BD1A74A.2050003@redhat.com> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default
 4BD1B427.9010905@redhat.com>
In-Reply-To: <4BD1B427.9010905@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > Each page is either in frontswap OR on the normal swap device,
> > never both.  So, yes, both reads and writes are avoided if memory
> > is available and there is no write issued to the io subsystem if
> > memory is available.  The is_memory_available decision is determined
> > by the hypervisor dynamically for each page when the guest attempts
> > a "frontswap_put".  So, yes, you are indeed "swapping to the
> > hypervisor" but, at least in the case of Xen, the hypervisor
> > never swaps any memory to disk so there is never double swapping.
>=20
> I see.  So why not implement this as an ordinary swap device, with a
> higher priority than the disk device?  this way we reuse an API and
> keep
> things asynchronous, instead of introducing a special purpose API.

Because the swapping API doesn't adapt well to dynamic changes in
the size and availability of the underlying "swap" device, which
is very useful for swap to (bare-metal) hypervisor.

> Doesn't this commit the hypervisor to retain this memory?  If so, isn't
> it simpler to give the page to the guest (so now it doesn't need to
> swap at all)?

Yes the hypervisor is committed to retain the memory.  In
some ways, giving a page of memory to a guest (via ballooning)
is simpler and in some ways not.  When a guest "owns" a page,
it can do whatever it wants with it, independent of what is best
for the "whole" virtualized system.  When the hypervisor
"owns" the page on behalf of the guest but the guest can't
directly address it, the hypervisor has more flexibility.
For example, tmem optionally compresses all frontswap pages,
effectively doubling the size of its available memory.
In the future, knowing that a guest application can never
access the pages directly, it might store all frontswap pages in
(slower but still synchronous) phase change memory or "far NUMA"
memory.

> What about live migration?  do you live migrate frontswap pages?

Yes, fully supported in Xen 4.0.  And as another example of
flexibility, note that "lazy migration" of frontswap'ed pages
might be quite reasonable.

> >> The guest can easily (and should) issue 64k dmas using
> scatter/gather.
> >> No need for copying.
> >>
> > In many cases, this is true.  For the swap subsystem, it may not
> always
> > be true, though I see recent signs that it may be headed in that
> > direction.
>=20
> I think it will be true in an overwhelming number of cases.  Flash is
> new enough that most devices support scatter/gather.

I wasn't referring to hardware capability but to the availability
and timing constraints of the pages that need to be swapped.

> > In any case, unless you see this SSD discussion as
> > critical to the proposed acceptance of the frontswap patchset,
> > let's table it until there's some prototyping done.
>
> It isn't particularly related.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
