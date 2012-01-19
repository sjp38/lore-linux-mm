Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id D2E1B6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 15:24:49 -0500 (EST)
Date: Thu, 19 Jan 2012 12:24:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 42578] Kernel crash "Out of memory error by X" when using
 NTFS file system on external USB Hard drive
Message-Id: <20120119122448.1cce6e76.akpm@linux-foundation.org>
In-Reply-To: <201201180922.q0I9MCYl032623@bugzilla.kernel.org>
References: <bug-42578-27@https.bugzilla.kernel.org/>
	<201201180922.q0I9MCYl032623@bugzilla.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, Stuart Foster <smf.linux@ntlworld.com>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 18 Jan 2012 09:22:12 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=42578

Stuart has an 8GB x86_32 machine.  It has large amounts of NTFS
pagecache in highmem.  NTFS is using 512-byte buffer_heads.  All of the
machine's lowmem is being consumed by struct buffer_heads which are
attached to the highmem pagecache and the machine is dead in the water,
getting a storm of ooms.

A regression, I think.  A box-killing one on a pretty simple workload
on a not uncommon machine.

We used to handle this by scanning highmem even when there was plenty
of free highmem and the request is for a lowmmem pages.  We have made a
few changes in this area and I guess that's what broke it.


I think a suitable fix here would be to extend the
buffer_heads_over_limit special-case.  If buffer_heads_over_limit is
true, both direct-reclaimers and kswapd should scan the highmem zone
regardless of incoming gfp_mask and regardless of the highmem free
pages count.

In this mode, we only scan the file lru.  We should perform writeback
as well, because the buffer_heads might be dirty.

[aside: If all of a page's buffer_heads are dirty we can in fact
reclaim them and mark the entire page dirty.  If some of the
buffer_heads are dirty and the others are uptodate we can even reclaim
them in this case, and mark the entire page dirty, causing extra I/O
later.  But try_to_release_page() doesn't do these things.]


I think it is was always wrong that we only strip buffer_heads when
moving pages to the inactive list.  What happens if those 600MB of
buffer_heads are all attached to inactive pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
