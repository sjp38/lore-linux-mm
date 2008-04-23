Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NIlcv6020510
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:47:38 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NIo1rU212822
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 12:50:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NIo0WF006839
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 12:50:00 -0600
Date: Wed, 23 Apr 2008 11:49:59 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 18/18] hugetlb: my fixes 2
Message-ID: <20080423184959.GD10548@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.569358000@nick.local0.net> <480F13F5.9090003@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480F13F5.9090003@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [12:48:21 +0200], Andi Kleen wrote:
> npiggin@suse.de wrote:
> 
> Thanks for these fixes. The subject definitely needs improvement, or
> rather all these fixes should be folded into the original patches.
> 
> > Here is my next set of fixes and changes:
> > - Allow configurations without the default HPAGE_SIZE size (mainly useful
> >   for testing but maybe it is the right way to go).
> 
> I don't think it is the correct way. If you want to do it this way you
> would need to special case it in /proc/meminfo to keep things
> compatible.

I'm not sure I believe you here. /proc/meminfo displays both the number
of hugepages and the size. If any app relied on hugepages being a fixed
size, well, they blatantly are ignoring information being provided by
the kernel *and* are non-portable.

> Also in general I would think that always keeping the old huge page
> size around is a good idea. There is some chance at least to allocate
> 2MB pages after boot (especially with the new movable zone and with
> lumpy reclaim), so it doesn't need to be configured at boot time
> strictly. And why take that option away from the user?

Sure, but that's an administrative choice and might be the default.
We're already requiring extra effort to even use 1G pages, right, by
specifying hugepagesz=1G, why does it matter if they also have to
specify hugepagesz=2M. So nothing is being taken away from the user,
unless their administrator only expliclity specified one hugepage size.

Otherwise, we get implicit command-line arguments like:

hugepagesz=1G hugepages=10 hugepages=20

I prefer the flexibility of allowing an administrator to specify exactly
what pool-sizes they want to allow users access to. They also have to
mount hugetlbfs, and specify the size there, but still, I think Nick's
way is the right way forward, especially given the potential for more
than 2 hugepage sizes available.

So I'd say the cmdline should function like:

a) no hugepagesz= specified. hugepages= defaults to the "default"
hugepage size, which is arch-defined (as the historical value, I guess).

b) hugepagesz= specified. every hugepagesz that should be available must
be specified (if the pool is not going to be allocated at boot-time, say
for 64K and 16M pages on power, could the admin to
hugepagesz=64k,16m?)

> Also I would hope that distributions keep their existing /hugetlbfs
> (if they have one) at the compat size for 100% compatibility to
> existing applications.

Sure, but this is again an administrative decision and such, decided by
the distro, not the kernel.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
