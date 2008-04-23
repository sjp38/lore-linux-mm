Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NLBwMb016942
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:11:58 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NLBwX5217332
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:11:58 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NLBlMP023974
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 17:11:48 -0400
Date: Wed, 23 Apr 2008 14:11:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 18/18] hugetlb: my fixes 2
Message-ID: <20080423211136.GG10548@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net> <480F13F5.9090003@firstfloor.org> <20080423184959.GD10548@us.ibm.com> <480F8FE5.1030106@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480F8FE5.1030106@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [21:37:09 +0200], Andi Kleen wrote:
> 
> > they blatantly are ignoring information being provided by
> > the kernel *and* are non-portable.
> 
> And? I'm sure both descriptions apply to significant parts of the
> deployed userland, including software that deals with hugepages. You
> should watch one of the Dave Jones' "why user space sucks" talks at
> some point @)

My point was simply that I don't know of any applications that are so
hard-coded (although there might be some in SHM_HUGETLB land). If you
know of any that would be great.

> > Sure, but that's an administrative choice and might be the default.
> > We're already requiring extra effort to even use 1G pages, right, by
> > specifying hugepagesz=1G, why does it matter if they also have to
> > specify hugepagesz=2M.
> 
> Like I said earlier hugepagesz=2M is basically free, so there is no
> reason to not have it even when you happen to have 1GB pages too.

I think I was getting confused by the talk about legacy apps and
hugepage pool allocations. And I think I might need to change my
stance...

On the one hand, there is the discussion about /proc/meminfo.

On the other, there is discussion about kernel command-line.

For the latter, I believe that only sizes that wish to be preallocated
should need to be specified on the command-line. That is, all available
hugepage sizes are visible in /proc and /sys once the kernel has booted.
But only the ones that have been specified on the kernel-cmdline *might*
have hugepages allocated during boot (depends on the success of the
allocations, for instance).

Outstanding issues:

 - specifying default hugepagesize other than the one on the kernel
   cmdline when only one is specified on the kernel cmdline. This might
   be a case for just making the default hugepagesize the only one
   available previously (2M on x86_64, 4M/2M on x86, 16M on power, etc).
   That is, regardless of the kernel boot-stanza, the default
   hugepagesize if CONFIG_HUGETLB_PAGE is set is the same on a per-arch
   basis.

 - How to deal with archs with many hugepage sizes available (IA64?) Do
   we show all of them in /proc/meminfo?

Using ppc with 64K, 16M, and 16G hugepages as an example, here is the
result (meminfo shows all three sizes always, with 16M first) for
various kernel command-lines:

hugepages=20

	allocates 20 16M hugepages

hugepages=20 hugepagesz=64k hugepages=40
hugepagesz=64k hugepages=20 hugepages=40

	allocatees 20 16M hugepages and 40 64K hugepages

hugepagesz=16G hugepages=2 hugepages=20 hugepagesz=64k hugepages=40
hugepagesz=16G hugepages=2 hugepagesz=16M hugepages=20 hugepagesz=64k hugepages=40

	allocates 2 16G hugepages, 20 16M hugepages and 40 64K hugepages

hugepagesz=64k hugepages=40

	allocates 40 64k hugepages

In all of the above cases, at run-time, all three hugepage sizes are
visible in the sense that we can try to echo commands into
/proc/sys/vm/nr_hugepages (or the appropriate replacement sysfs
interface). Availability to applications depends on administrators
mounting hugetlbfs with the appropriate size= parameter (I believe).

Does that all seem sane?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
