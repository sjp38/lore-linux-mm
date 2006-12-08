Message-ID: <4578BE37.1010109@goop.org>
Date: Thu, 07 Dec 2006 17:21:59 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Add __GFP_MOVABLE for callers to flag allocations that
 may be migrated
References: <20061204113051.4e90b249.akpm@osdl.org> <Pine.LNX.4.64.0612041133020.32337@schroedinger.engr.sgi.com> <20061204120611.4306024e.akpm@osdl.org> <Pine.LNX.4.64.0612041211390.32337@schroedinger.engr.sgi.com> <20061204131959.bdeeee41.akpm@osdl.org> <Pine.LNX.4.64.0612041337520.851@schroedinger.engr.sgi.com> <20061204142259.3cdda664.akpm@osdl.org> <Pine.LNX.4.64.0612050754560.11213@schroedinger.engr.sgi.com> <20061205112541.2a4b7414.akpm@osdl.org> <Pine.LNX.4.64.0612051159510.18687@schroedinger.engr.sgi.com> <20061205214721.GE20614@skynet.ie> <Pine.LNX.4.64.0612051521060.20570@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0612060903161.7238@skynet.skynet.ie> <Pine.LNX.4.64.0612060921230.26185@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0612060921230.26185@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 6 Dec 2006, Mel Gorman wrote:
>   
>> Objective: Get contiguous block of free pages
>> Required: Pages that can move
>> Move means: Migrating them or reclaiming
>> How we do it for high-order allocations: Take a page from the LRU, move
>> 	the pages within that high-order block
>> How we do it for unplug: Take the pages within the range of interest, move
>> 	all the pages out of that range
>>     
>
> This is mostly the same. For unplug we would clear the freelists of 
> page in the unplug range and take the pages off the LRU that are in the 
> range of interest and then move them. Page migration takes pages off the 
> LRU.
>   

You can also deal with memory hotplug by adding a Xen-style
pseudo-physical vs machine address abstraction.  This doesn't help with
making space for contiguous allocations, but it does allow you to move
"physical" pages from one machine page to another if you want to.  The
paravirt ops infrastructure has already appeared in -git, and I'll soon
have patches to allow Xen's paravirtualized mmu mode to work with it,
which is a superset of what would be required to implement movable pages
for hotpluggable memory.

(I don't know if you actually want to consider this approach; I'm just
pointing out that it definitely a bad idea to conflate the two problems
of memory fragmentation and hotplug.)

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
