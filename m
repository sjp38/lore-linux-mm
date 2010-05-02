Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 96E426006AB
	for <linux-mm@kvack.org>; Sun,  2 May 2010 12:07:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b09a9cc6-8481-4dd3-8374-68ff6fb714d9@default>
Date: Sun, 2 May 2010 09:06:12 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>>
 <4BD1A74A.2050003@redhat.com>>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com>>
 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>>
 <4BD3377E.6010303@redhat.com>>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>>
 <ce808441-fae6-4a33-8335-f7702740097a@default>>
 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
 <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default>
 <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org>
 <4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default
 4BDD3079.5060101@vflare.org>
In-Reply-To: <4BDD3079.5060101@vflare.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Avi Kivity <avi@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > NO!  Frontswap on Xen+tmem never *never* _never_ NEVER results
> > in host swapping.  Host swapping is evil.  Host swapping is
> > the root of most of the bad reputation that memory overcommit
> > has gotten from VMware customers.  Host swapping can't be
> > avoided with some memory overcommit technologies (such as page
> > sharing), but frontswap on Xen+tmem CAN and DOES avoid it.
>=20
> Why host-level swapping is evil? In KVM case, VM is just another
> process and host will just swap out pages using the same LRU like
> scheme as with any other process, AFAIK.

The first problem is that you are simulating a fast resource
(RAM) with a resource that is orders of magnitude slower with
NO visibility to the user that suffers the consequences.  A good
analogy (and no analogy is perfect) is if Linux discovers a 16MHz
80286 on a serial card in addition to the 32 3GHz cores on a
Nehalem box and, whenever the 32 cores are all busy, randomly
schedules a process on the 80286, while recording all CPU usage
data as if the 80286 is a "real" processor.... "Hmmm... why
did my compile suddenly run 100 times slower?"

The second problem is "double swapping": A guest may choose
a page to swap to "guest swap", but invisibly to the guest,
the host first must fetch it from "host swap".  (This may
seem like it is easy to avoid... it is not and happens more
frequently than you might think.)

Third, host swapping makes live migration much more difficult.
Either the host swap disk must be accessible to all machines
or data sitting on a local disk MUST be migrated along with
RAM (which is not impossible but complicates live migration
substantially).  Last I checked, VMware does not allow
page-sharing and live migration to both be enabled for the
same host.

If you talk to VMware customers (especially web-hosting services)
that have attempted to use overcommit technologies that require
host-swapping, you will find that they quickly become allergic
to memory overcommit and turn it off.  The end users (users of
the VMs that inexplicably grind to a halt) complain loudly.
As a result, RAM has become a bottleneck in many many systems,
which ultimately reduces the utility of servers and the value
of virtualization.

> Also, with frontswap, host cannot discard pages at any time as is
> the case will cleancache

True.  But in the Xen+tmem implementation there are disincentives
for a guest to unnecessarily retain pages put into frontswap,
so the host doesn't need to care that it can't discard the pages
as the guest is "billed" for them anyway.

So far we've been avoiding hypervisor policy implementation
questions and focused on mechanism (because, after all, this
is a *Linux kernel* mailing list), but we can go there if
needed.

> IMHO, along with cleancache, we should just have in in-memory
> compressed swapping at *host* level i.e. no frontswap. I agree
> that using frontswap hooks, it is easy to implement ramzswap
> functionality but I think its not worth replacing this driver
> with frontswap hooks. This driver already has all the goodness:
> asynchronous interface, ability to dynamically add/remove ramzswap
> devices etc. All that is lacking in this driver is a more efficient
> 'discard' functionality so we can free a page as soon as it becomes
> unused.

The key missing element with ramzswap is that, with frontswap, EVERY
attempt to swap a page to RAM is evaluated and potentially rejected
by the "backend" (hypervisor).  Further, no additional per-guest
system administration is required to configure ramzswap.  (How big
should it be anyway?) This level of dynamicity is important to
optimally managing physical memory in a rapidly changing virtual
environment.

> It should also be easy to extend this driver to allow sending pages
> to host using virtio (for KVM) or Xen hypercalls, if frontswap is
> needed at all.
>=20
> So, IMHO we can focus on cleancache development and add missing
> parts to ramzswap driver.

I'm certainly open to someone exploring this approach to see if
it works for swap-to-hypervisor-RAM.  It has been my understanding
that Linus rejected the proposed discard hooks, without which
ramzswap doesn't even really work for swap-to-in-kernel-compressed-
RAM. However, I suspect that ramzswap, even with the discard hooks,
will not have the "dynamic range" useful for swap-to-hypervisor-RAM,
but frontswap will work fine for swap-to-in-kernel-compressed-RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
