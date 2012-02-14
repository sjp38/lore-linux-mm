Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 559C86B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 15:37:14 -0500 (EST)
Date: Tue, 14 Feb 2012 12:37:12 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-Id: <20120214123712.77aa54ce.akpm@linux-foundation.org>
In-Reply-To: <20120214130955.GM17917@csn.ul.ie>
References: <bug-42578-27@https.bugzilla.kernel.org/>
	<201201180922.q0I9MCYl032623@bugzilla.kernel.org>
	<20120119122448.1cce6e76.akpm@linux-foundation.org>
	<20120210163748.GR5796@csn.ul.ie>
	<4F36DD77.1080306@ntlworld.com>
	<20120214130955.GM17917@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Stuart Foster <smf.linux@ntlworld.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 14 Feb 2012 13:09:55 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> Stuart Foster reported on https://bugzilla.kernel.org/show_bug.cgi?id=42578
> that copying large amounts of data from NTFS caused an OOM kill on 32-bit
> X86 with 16G of memory. Andrew Morton correctly identified that the problem
> was NTFS was using 512 blocks meaning each page had 8 buffer_heads in low
> memory pinning it.
> 
> In the past, direct reclaim used to scan highmem even if the allocating
> process did not specify __GFP_HIGHMEM but not any more. kswapd no longer
> will reclaim from zones that are above the high watermark. The intention
> in both cases was to minimise unnecessary reclaim. The downside is on
> machines with large amounts of highmem that lowmem can be fully consumed
> by buffer_heads with nothing trying to free them.
> 
> The following patch is based on a suggestion by Andrew Morton to extend
> the buffer_heads_over_limit case to force kswapd and direct reclaim to
> scan the highmem zone regardless of the allocation request or
> watermarks.

Seems reasonable, thanks.

I wonder if we really needed to change balance_pdgat().  The smaller we
can make profile of the special-case-hack the better.  Perhaps poking
it into direct reclaim was sufficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
