Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 31F816B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 04:59:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id r15so5183942wrr.16
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 01:59:48 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id e15si2123848eda.4.2018.02.23.01.59.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Feb 2018 01:59:46 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id 39E83B8AC1
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 09:59:46 +0000 (GMT)
Date: Fri, 23 Feb 2018 09:59:45 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Message-ID: <20180223095945.jwinc5yng27ptzzz@techsingularity.net>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
 <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

On Thu, Feb 22, 2018 at 10:19:32PM +0100, Thomas Schoebel-Theuer wrote:
> Please have a look at the attached patchset for kernel 3.16 which is in
> _production_ at 1&1 Internet SE at about 20,000 servers for several years
> now, starting from kernel 3.2.x to 3.16.x (or maybe the very first version
> was for 2.6.32, I don't remember exactly).
> 

3.16 is 4 years old. Crucially, it's missing at least commit
0aaa29a56e4fb ("mm, page_alloc: reserve pageblocks for high-order atomic
allocations on demand") and commit 97a16fc82a7c5 ("mm, page_alloc: only
enforce watermarks for order-0 allocations"), both of which were
introduced in 4.4 (2 years ago) and both which have a significant impact
on the treatment of high-order allocation requests.

> It has collected several millions of operation hours in total, and it is
> known to work miracles for some of our workloads.
> 

Be that as it may, it does not prove that it's necessary for current
kernels, if the tuning is necessary or if it's possible to deal with
this without manual monitoring and tuning of individual hardware
configurations or workloads.

> Porting to later kernels should be relatively easy. Also notice that the
> switch labels at patch #2 could need some minor tweaking, e.g. also
> including ZONE_DMA32 or similar, and also might need some
> architecture-specific tweaking. All of the tweaking is depending on the
> actual workload. I am using it only at datacenter servers (webhosting) and
> at x86_64.
> 
> Please notice that the user interface of my patchset is extremely simple and
> can be easily understood by junior sysadmins:
> 
> After running your box for several days or weeks or even months (or
> possibly, after you just got an OOM), just do
> # cat /proc/sys/vm/perorder_statistics > /etc/defaults/my_perorder_reserve
> 

And my point was that in so far as it is possible, this should be managed
without tuning at all. My concern is that if the patches were merged as-is
without supporting proof showing how and when it's necessary that it's
effectively dead code.

> Also no need for adding anything to the boot commandline. Fragmentation will
> typically occur only after some days or weeks or months of operation, at
> least in all of the practical cases I have personally seen at 1&1
> datacenters and their workloads.
> 

I accept the logic but it's also been a long time since I received a
high-order-atomic-allocation failure bug in the field. That said, none of
the field situations I deal with use SLUB on the grounds the reliance of
high-order allocations for high performance can be problematic in itself
within sufficently long uptimes.

> When requested, I can post the mathematical theory behind the patch, or I
> could give a presentation at some of the next conferences if I would be
> invited (or better give a practical explanation instead). But probably
> nobody on these lists wants to deal with any theories.
> 

I think I'm ok, I should have a reasonable grounding in the relevant
theory to not require a detailed exaplanation.

I accept that your day-to-day situation does not allow much upstream
hacking but the associated data for the patches in general are
insufficient to show that it's a problem with current kernels and is
absolutely required to have a tunable. The current HIGHATOMIC protection
and alternative treatment of watermarks may be enough. Alternatively, it
may be necessary to more aggressively protect MIGRATE_UNMOVABLE
pageblocks from being polluted with MOVABLE pages when fallbacks and
memory pressure occurs but that has similarly not been proven.

A changelog for adding new pools should include details on why the
existing mechanisms do not work, why they cannot be handled
automatically (e.g. preemptively moving MOVABLE pages out of UNMOVABLE
blocks before fragmentation degrades further) and an example of an OOM
caused by fragmentation.

I recognise that the burden of proof is high in this case but I'm not
comfortable with adding tuning and maintenance overhead just in case
it's required.

> Just _play_ with the patchset practically, and then you will notice.
> 

Unfortunately, since the last round of patches I wrote dealing with
high-order allocation failures, I have not personally encountered a situation
whereby performance or functionality were limited by high-order allocation
delays or failures. It could be argued that THP allocations were a problem
but for the most part, that has been dealt with by not stalling aggressively
any more as the overhead was too high for the relatively marginal gain (this
is not universally accepted but in those cases, it goes back to preemptively
moving MOVABLE pages out of UNMOVABLE pageblocks). I could play with the
patch but it's highly unlikely I'll detect a difference. While I have a
test-bed, it doesn't have loading of long uptime of complex applications
depending on jumbo frame allocations critical for high-performance.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
