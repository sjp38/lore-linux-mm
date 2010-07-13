Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A01E66B02A5
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 05:30:45 -0400 (EDT)
Date: Tue, 13 Jul 2010 11:30:06 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-ID: <20100713093006.GB14504@cmpxchg.org>
References: <20100712155348.GA2815@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100712155348.GA2815@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 13, 2010 at 12:53:48AM +0900, Minchan Kim wrote:
> Kukjin, Could you test below patch?
> I don't have any sparsemem system. Sorry. 
> 
> -- CUT DOWN HERE --
> 
> Kukjin reported oops happen while he change min_free_kbytes
> http://www.spinics.net/lists/arm-kernel/msg92894.html
> It happen by memory map on sparsemem. 
> 
> The system has a memory map following as. 
>      section 0             section 1              section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
> 
> It means section 0 is an incompletely filled section.
> Nontheless, current pfn_valid of sparsemem checks pfn loosely. 
> 
> It checks only mem_section's validation.
> So in above case, pfn on 0x25000000 can pass pfn_valid's validation check.
> It's not what we want.
> 
> The Following patch adds check valid pfn range check on pfn_valid of sparsemem.

Look at the declaration of struct mem_section for a second.  It is
meant to partition address space uniformly into backed and unbacked
areas.

It comes with implicit size and offset information by means of
SECTION_SIZE_BITS and the section's index in the section array.

Now you are not okay with the _granularity_ but propose to change _the
model_ by introducing a subsection within each section and at the same
time make the concept of a section completely meaningless: its size
becomes arbitrary and its associated mem_map and flags will apply to
the subsection only.

My question is: if the sections are not fine-grained enough, why not
just make them?

The biggest possible section size to describe the memory population on
this machine accurately is 16M.  Why not set SECTION_SIZE_BITS to 24?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
