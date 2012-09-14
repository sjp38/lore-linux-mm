Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3E8806B0213
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 08:13:45 -0400 (EDT)
Subject: Re: [PATCH 0/3] KVM: PPC: Book3S HV: More flexible allocator for linear memory
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <20120914081140.GC15028@bloggs.ozlabs.ibm.com>
Date: Fri, 14 Sep 2012 14:13:37 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <F7ED8384-5B23-478C-B2B7-927A3A755E98@suse.de>
References: <20120912003427.GH32642@bloggs.ozlabs.ibm.com> <9650229C-2512-4684-98EC-6E252E47C4A9@suse.de> <20120914081140.GC15028@bloggs.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: kvm-ppc@vger.kernel.org, KVM list <kvm@vger.kernel.org>, linux-mm@kvack.org, m.nazarewicz@samsung.com


On 14.09.2012, at 10:11, Paul Mackerras wrote:

> On Fri, Sep 14, 2012 at 01:32:23AM +0200, Alexander Graf wrote:
>>=20
>> On 12.09.2012, at 02:34, Paul Mackerras wrote:
>>=20
>>> This series of 3 patches makes it possible for guests to allocate
>>> whatever size of HPT they need from linear memory preallocated at
>>> boot, rather than being restricted to a single size of HPT (by
>>> default, 16MB) and having to use the kernel page allocator for
>>> anything else -- which in practice limits them to at most 16MB given
>>> the default value for the maximum page order.  Instead of allocating
>>> many individual pieces of memory, this allocates a single contiguous
>>> area and uses a simple bitmap-based allocator to hand out pieces of =
it
>>> as required.
>>=20
>> Have you tried to play with CMA for this? It sounds like it could buy =
us exactly what we need.
>=20
> Interesting, I hadn't noticed that there.  I had a bit of a look at
> it, and it's certainly in the right general direction, however it
> would need some changes to do what we need.  It limits the alignment
> to at most 512 pages, i.e. 2MB with 4k pages or 32MB with 64k pages,
> but we need RMAs of 64MB to 256MB for PPC970 and they have to be
> aligned on their size, as do the HPTs for PPC970.
>=20
> Secondly, it has a link with the page allocator that I don't fully
> understand, but it seems from the comments in alloc_contig_range()
> (mm/page_alloc.c) that you can allocate at most MAX_ORDER_NR_PAGES
> pages at once, and that defaults to 16MB for ppc64, which isn't nearly
> enough.  If that's true then it would make it unusable for this.

So do you think it makes more sense to reimplement a large page =
allocator in KVM, as this patch set does, or improve CMA to get us =
really big chunks of linear memory?

Let's ask the Linux mm guys too :). Maybe they have an idea.


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
