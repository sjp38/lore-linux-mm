Date: Tue, 14 Dec 2004 23:14:46 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <686170000.1103094885@[10.10.2.4]>
In-Reply-To: <20041215040854.GC27225@wotan.suse.de>
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de> <19030000.1103054924@flay> <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <20041215040854.GC27225@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>, Brent Casavant <bcasavan@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>> > > I originally was a bit worried about the TLB usage, but it doesn't
>> > > seem to be a too big issue (hopefully the benchmarks weren't too
>> > > micro though)
>> > 
>> > Well, as long as we stripe on large page boundaries, it should be fine,
>> > I'd think. On PPC64, it'll screw the SLB, but ... tough ;-) We can either
>> > turn it off, or only do it on things larger than the segment size, and
>> > just round-robin the rest, or allocate from node with most free.
>> 
>> Is there a reasonably easy-to-use existing infrastructure to do this?
> 
> No. It will be a lot of work actually, requiring new code for 
> each architecture and may even be impossible on some. 
> The current hugetlb code is not really suitable for this
> because it requires an preallocated pool and only works
> for user space.

Well hold on a sec. We don't need to use the hugepages pool for this,
do we? This is the same as using huge page mappings for the whole of
kernel space on ia32. As long as it's a kernel mapping, and 16MB aligned
and contig, we get it for free, surely?

> Also at least on IA64 the large page size is usually 1-2GB 
> and that would seem to be a little too large to me for
> interleaving purposes. Also it may prevent the purpose 
> you implemented it - not using too much memory from a single
> node. 

Yes, that'd bork it. But I thought that they had a large sheaf of
mapping sizes to chose from on ia64?
 
> Using other page sizes would be probably tricky because the 
> linux VM can currently barely deal with two page sizes.
> I suspect handling more would need some VM infrastructure effort
> at least in the changed port. 

For the general case I'd agree. But this is a setup-time only tweak
of the static kernel mapping, isn't it?

I'm not saying it needs doing now. But it's an interesting future
enhancement.

M.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
