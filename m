Message-ID: <4614E293.3010908@shadowen.org>
Date: Thu, 05 Apr 2007 12:50:43 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>  <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <1175544797.22373.62.camel@localhost.localdomain> <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com> <461169CF.6060806@google.com> <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 2 Apr 2007, Martin Bligh wrote:
> 
>>> Its just the opposite. The vmemmap code is so efficient that we can remove
>>> lots of other code and gops of these alternate implementations. On x86_64
>>> its even superior to FLATMEM since FLATMEM still needs a memory reference
>>> for the mem_map area. So if we make SPARSE standard for all configurations
>>> then there is no need anymore for FLATMEM DISCONTIG etc etc. Can we not
>>> cleanup all this mess? Get rid of all the gazillions of #ifdefs please? This
>>> would ease code maintenance significantly. I hate having to constantly
>>> navigate my way through all the alternatives.
>> The original plan when this was first merged was pretty much that -
>> for sparsemem to replace discontigmem once it was well tested. Seems
>> to have got stalled halfway through ;-(
> 
> But you made big boboo in SPARSEMEM. Virtual memmap is a textbook case 
> that was not covered. Instead this horrible stuff that involves calling 
> functions in VM primitives. We could have been there years ago...
> 
>> Not sure we'll get away with replacing flatmem for all arches, but
>> we could at least get rid of discontigmem, it seems.
> 
> I think we could start with x86_64 and ia64. Both will work fine with 
> SPARSE VIRTUAL (and SGIs concerns about performance are addressed) and we 
> could remove the other alternatives. That is going to throw out lots of 
> stuff. Then proceed to other arches
> 
> Could the SPARSEMEM folks take this over this patch? You have more 
> resources and I am all alone on this. I will post another patchset today 
> that also includes an IA64 implementation.

That would be me.  I have been offline writing for OLS and did not get
to respond before this.

When we first saw these patches the reaction was a general positive
despite skepticism on the general utility of vmemmmap.  The patches
appear to provide an architecture neutral implementation.  At that time
s390 was just starting to use vmemmap bringing 2x implementations into
the kernel.  Now we have three.  Clearly, even if vemmemap was a net
performance loss having only one implementation has to be a good thing
for maintainability/coverage.

Without some benchmarking and some general testing it certainly is
premature to be removing the other memory models, but for sure that was
the original plan.  The original assumption that as time went on the
other models would wither on the vine, this has only happened on powerpc
so far.

So I will go and:

1) talk to s390 and find out if they can use this same form, as one
implementation of vmemmap only should be the goal, and

2) take the current patches and try and get some benchmarks for them
against other memory models

Christoph if you could let us know which benchmarks you are seeing gains
with that would be a help.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
