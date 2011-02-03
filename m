Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8C48D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:22:24 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p13LMLk2009174
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:21 -0800
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by wpaz29.hot.corp.google.com with ESMTP id p13LMJcY004879
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:20 -0800
Received: by pzk37 with SMTP id 37so362945pzk.12
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:22:19 -0800 (PST)
Date: Thu, 3 Feb 2011 13:22:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 1/6] count transparent hugepage splits
In-Reply-To: <20110201003358.98826457@kernel>
Message-ID: <alpine.DEB.2.00.1102031235100.453@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003358.98826457@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> 
> The khugepaged process collapses transparent hugepages for us.  Whenever
> it collapses a page into a transparent hugepage, we increment a nice
> global counter exported in sysfs:
> 
> 	/sys/kernel/mm/transparent_hugepage/khugepaged/pages_collapsed
> 
> But, transparent hugepages also get broken down in quite a few
> places in the kernel.  We do not have a good idea how how many of
> those collpased pages are "new" versus how many are just fixing up
> spots that got split a moment before.
> 
> Note: "splits" and "collapses" are opposites in this context.
> 
> This patch adds a new sysfs file:
> 
> 	/sys/kernel/mm/transparent_hugepage/pages_split
> 
> It is global, like "pages_collapsed", and is incremented whenever any
> transparent hugepage on the system has been broken down in to normal
> PAGE_SIZE base pages.  This way, we can get an idea how well khugepaged
> is keeping up collapsing pages that have been split.
> 
> I put it under /sys/kernel/mm/transparent_hugepage/ instead of the
> khugepaged/ directory since it is not strictly related to
> khugepaged; it can get incremented on pages other than those
> collapsed by khugepaged.
> 
> The variable storing this is a plain integer.  I needs the same
> amount of locking that 'khugepaged_pages_collapsed' has, for
> instance.

i.e. no global locking, but we've accepted the occassional off-by-one 
error (even though splitting of hugepages isn't by any means lightning 
fast and the overhead of atomic ops would be negligible).

> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
