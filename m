Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 51BDC9000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 19:03:44 -0400 (EDT)
Date: Wed, 6 Jul 2011 16:03:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 38032] New: default values of
 /proc/sys/net/ipv4/udp_mem does not consider huge page allocatio
Message-Id: <20110706160318.2c604ae9.akpm@linux-foundation.org>
In-Reply-To: <bug-38032-10286@https.bugzilla.kernel.org/>
References: <bug-38032-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, netdev@vger.kernel.org
Cc: bugme-daemon@bugzilla.kernel.org, starlight@binnacle.cx, Rafael Aquini <aquini@linux.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

(cc's added)

On Tue, 21 Jun 2011 00:35:22 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=38032
> 
>            Summary: default values of /proc/sys/net/ipv4/udp_mem does not
>                     consider huge page allocatio
>            Product: Memory Management
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: starlight@binnacle.cx
>         Regression: No
> 
> 
> In the RHEL 5.5 back-port of this tunable we ran into trouble locking up
> systems because the boot-time default is set based on physical memory does not
> account for the hugepages= in the boot parameters.  So the UDP socket buffer
> limit can exceed phyisical memory.  Don't know if this is an issue in mainline
> kernels but it seems likely so reporting this as a courtsey.  Seems like it
> would be easy to fix the default to account for the memory reserved by
> hugepages which is not available for slab allocations.
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=714833
> 

Yes, we've made similar mistakes in other places.

I don't think we really have an official formula for what callers
should be doing here.  net/ipv4/udp.c:udp_init() does

        nr_pages = totalram_pages - totalhigh_pages;                            

which assumes that totalram_pages does not include the pages which were
lost to hugepage allocations.

I *think* that this is now the case, but it wasn't always the case - we
made relatively recent fixes to the totalram_pages maintenance.

Perhaps UDP should be using the misnamed nr_free_buffer_pages() here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
