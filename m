Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FBFB8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 11:43:21 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w126-v6so4123084qka.11
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 08:43:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i19-v6sor7283044qtc.128.2018.09.19.08.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Sep 2018 08:43:20 -0700 (PDT)
MIME-Version: 1.0
References: <20180820212556.GC2230@char.us.oracle.com> <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
 <1534801939.10027.24.camel@amazon.co.uk> <20180919010337.GC8537@350D>
In-Reply-To: <20180919010337.GC8537@350D>
From: Jonathan Adams <jwadams@google.com>
Date: Wed, 19 Sep 2018 08:43:07 -0700
Message-ID: <CA+VK+GM6CaPnGKcPjEn7U=4ubtC-JWZ9k98BTxzRH_TthaFXDw@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bsingharora@gmail.com
Cc: dwmw@amazon.co.uk, torvalds@linux-foundation.org, konrad.wilk@oracle.com, deepa.srinivasan@oracle.com, Jim Mattson <jmattson@google.com>, andrew.cooper3@citrix.com, linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com, linux-mm@kvack.org, tglx@linutronix.de, joao.m.martins@oracle.com, pradeep.vincent@oracle.com, ak@linux.intel.com, khalid.aziz@oracle.com, kanth.ghatraju@oracle.com, liran.alon@oracle.com, keescook@google.com, jsteckli@os.inf.tu-dresden.de, kernel-hardening@lists.openwall.com, chris.hyser@oracle.com, tyhicks@canonical.com, john.haxby@oracle.com, jcm@redhat.com

(apologies again; resending due to formatting issues)
On Tue, Sep 18, 2018 at 6:03 PM Balbir Singh <bsingharora@gmail.com> wrote:
>
> On Mon, Aug 20, 2018 at 09:52:19PM +0000, Woodhouse, David wrote:
> > On Mon, 2018-08-20 at 14:48 -0700, Linus Torvalds wrote:
> > >
> > > Of course, after the long (and entirely unrelated) discussion about
> > > the TLB flushing bug we had, I'm starting to worry about my own
> > > competence, and maybe I'm missing something really fundamental, and
> > > the XPFO patches do something else than what I think they do, or my
> > > "hey, let's use our Meltdown code" idea has some fundamental weakness
> > > that I'm missing.
> >
> > The interesting part is taking the user (and other) pages out of the
> > kernel's 1:1 physmap.
> >
> > It's the *kernel* we don't want being able to access those pages,
> > because of the multitude of unfixable cache load gadgets.
>
> I am missing why we need this since the kernel can't access
> (SMAP) unless we go through to the copy/to/from interface
> or execute any of the user pages. Is it because of the dependency
> on the availability of those features?
>
SMAP protects against kernel accesses to non-PRIV (i.e. userspace)
mappings, but that isn't relevant to what's being discussed here.

Davis is talking about the kernel Direct Map, which is a PRIV (i.e.
kernel) mapping of all physical memory on the system, at
  VA = (base + PA).
Since this mapping exists for all physical addresses, speculative
load gadgets (and the processor's prefetch mechanism, etc.) can
load arbitrary data even if it is only otherwise mapped into user
space.

XPFO fixes this by unmapping the Direct Map translations when the
page is allocated as a user page. The mapping is only restored:
   1. temporarily if the kernel needs direct access to the page
      (i.e. to zero it, access it from a device driver, etc),
   2. when the page is freed

And in so doing, significantly reduces the amount of non-kernel data
vulnerable to speculative execution attacks against the kernel.
(and reduces what data can be loaded into the L1 data cache while
in kernel mode, to be peeked at by the recent L1 Terminal Fault
vulnerability).

Does that make sense?

Cheers,
- jonathan
