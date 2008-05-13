Message-ID: <4829D9F0.70109@cray.com>
Date: Tue, 13 May 2008 13:12:00 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Guarantee faults for processes that call mmap(MAP_PRIVATE)
 on hugetlbfs v2
References: <20080507193826.5765.49292.sendpatchset@skynet.skynet.ie> <20080508014822.GE5156@yookeroo.seuss> <20080508111408.GB30870@shadowen.org>
In-Reply-To: <20080508111408.GB30870@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Without patch 3 the parent is still vunerable during the period the
> child exists.  Even if that child does nothing with the pages not even
> referencing them, and then execs immediatly.  As soon as we fork any
> reference from the parent will trigger a COW, at which point there may
> be no pages available and the parent will have to be killed.  That is
> regardless of the fact the child is not going to reference the page and
> leave the address space shortly.  With patch 3 on COW if we find no memory
> available the page may be stolen for the parent saving it, and the _risk_
> of reference death moves to the child; the child is killed only should it
> then re-reference the page.
> 
> Without patch 3 a both the parent and child are immediatly vunerable on
> fork() until the child leaves the address space.  With patch 3 only the
> child is vunerable.  The main scenario where mapper protection is useful
> is for main payload applications which fork helpers.  The parent by
> definition is using the mapping heavily whereas we do not expect the
> children to even be aware of it.  As the child will not touch the
> mapping both parent and child should be safe even if we do have to steal
> to save the parent.

I agree, it's important to close this window for the parent.  This will 
be helpful for our customers as we move towards wider use of libhugetlbfs.

Thanks, Mel!

-Andrew Hastings
  Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
