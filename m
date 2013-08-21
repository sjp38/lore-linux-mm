Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 7C02D6B00B3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 11:24:42 -0400 (EDT)
Date: Wed, 21 Aug 2013 18:25:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Transparent huge page collapse and NUMA
Message-ID: <20130821152538.GA17743@shutemov.name>
References: <CAJLXCZTtJmQo5WnwsdQWnoMPYSxOjxU0x77J59qE-GKOL9tqbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJLXCZTtJmQo5WnwsdQWnoMPYSxOjxU0x77J59qE-GKOL9tqbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Davidoff <davidoff@qedmf.net>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Aug 20, 2013 at 12:05:03PM -0400, Andrew Davidoff wrote:
> Hi,
> 
> In an effort to learn more about transparent huge pages and NUMA, I
> have written a very simple C snippet that malloc()s in a loop. I am
> running this under numactl with an interleave policy across both the
> NUMA nodes in the system. To make watching allocation progress easier,
> I am malloc()ing 4k (1 page) at a time.
> 
> If I watch node usage for the process (numa_maps) allocation looks
> correct (interleave), but then allocation will drop on one node and
> increase on another, at the same time as I see an increase in
> pages_collapsed. It appears as though pages are always migrating away
> from and to the same nodes, resulting in allocation (again, by
> examining numa_maps) being almost entirely on one node.

khugepaged strategy for NUMA is pretty simplistic: it tries to allocate on
the node the first small page is belong to. See khugepaged_scan_pmd().
It probably should be improved.

> This leads me to believe that khugepaged's defrag is to blame, though
> I am not certain. I tried to disable transparent huge page defrag
> completely via the following under /sys:
> 
> /sys/kernel/mm/transparent_hugepage/defrag
> /sys/kernel/mm/transparent_hugepage/khugepaged/defrag
> 
> but the same behavior persists. I am not sure if this is an indication
> that I don't know how to control transparent huge page collapse, or or
> that my issue isn't defrag/collapse related.

defrag knob only affects whether we want to use __GFP_WAIT for huge page
allocation, but not collapse itself. It basically means whether we want
kernel to defrag the memory to find suitable huge page window.

The only way to stop collapse fully is

echo never > /sys/kernel/mm/transparent_hugepage/enabled

Probably, we should introduce a knob.

> 
> Do I understand what I am seeing? Does anyone have any thoughts on this?
> 
> The OS is CentOS5.8 running the Oracle Unbreakable Kernel 2,
> 2.6.39-400.109.4.el5uek.
> 
> Further questions:
> 
> The way I understand it, transparent_hugepage/defrag controls defrag
> on page fault, and transparent_hugepage/khugepaged/defrag controls
> maintenance defrag (time based). Is that correct?

Yes.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
