Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id E10F46B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 18:12:44 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Thu, 1 Mar 2012 16:12:42 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 930B019D804F
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 16:12:15 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q21NCKb2140912
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 16:12:20 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q21NCJfi002674
	for <linux-mm@kvack.org>; Thu, 1 Mar 2012 16:12:20 -0700
Date: Thu, 1 Mar 2012 15:12:16 -0800
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] bootmem/sparsemem: remove limit constraint in
 alloc_bootmem_section
Message-ID: <20120301231216.GA3252@linux.vnet.ibm.com>
References: <1330112038-18951-1-git-send-email-nacc@us.ibm.com>
 <20120228154732.GE1199@suse.de>
 <20120229181233.GF5136@linux.vnet.ibm.com>
 <20120229152830.22fc72a2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120229152830.22fc72a2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Anton Blanchard <anton@au1.ibm.com>, Paul Mackerras <paulus@samba.org>, Ben Herrenschmidt <benh@kernel.crashing.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, stable@vger.kernel.org

On 29.02.2012 [15:28:30 -0800], Andrew Morton wrote:
> On Wed, 29 Feb 2012 10:12:33 -0800
> Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> 
> > While testing AMS (Active Memory Sharing) / CMO (Cooperative Memory
> > Overcommit) on powerpc, we tripped the following:
> > 
> > kernel BUG at mm/bootmem.c:483!
> >
> > ...
> > 
> > This is
> > 
> >         BUG_ON(limit && goal + size > limit);
> > 
> > and after some debugging, it seems that
> > 
> > 	goal = 0x7ffff000000
> > 	limit = 0x80000000000
> > 
> > and sparse_early_usemaps_alloc_node ->
> > sparse_early_usemaps_alloc_pgdat_section calls
> > 
> > 	return alloc_bootmem_section(usemap_size() * count, section_nr);
> > 
> > This is on a system with 8TB available via the AMS pool, and as a quirk
> > of AMS in firmware, all of that memory shows up in node 0. So, we end up
> > with an allocation that will fail the goal/limit constraints. In theory,
> > we could "fall-back" to alloc_bootmem_node() in
> > sparse_early_usemaps_alloc_node(), but since we actually have HOTREMOVE
> > defined, we'll BUG_ON() instead. A simple solution appears to be to
> > unconditionally remove the limit condition in alloc_bootmem_section,
> > meaning allocations are allowed to cross section boundaries (necessary
> > for systems of this size).
> > 
> > Johannes Weiner pointed out that if alloc_bootmem_section() no longer
> > guarantees section-locality, we need check_usemap_section_nr() to print
> > possible cross-dependencies between node descriptors and the usemaps
> > allocated through it. That makes the two loops in
> > sparse_early_usemaps_alloc_node() identical, so re-factor the code a
> > bit.
> 
> The patch is a bit scary now, so I think we should merge it into
> 3.4-rc1 and then backport it into 3.3.1 if nothing blows up.
> 
> Do you think it should be backported into 3.3.x?  Earlier kernels?

Upon review, it would be good if we can get it pushed back to kernels
3.0.x, 3.1.x and 3.2.x.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
