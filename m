Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id CCD726B0068
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 20:01:05 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 14 Jan 2013 18:01:02 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 88A423E40044
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 17:56:20 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0F0uPKG228346
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 17:56:25 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0F0uNIF018160
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 17:56:23 -0700
Message-ID: <50F4A92F.2070204@linux.vnet.ibm.com>
Date: Mon, 14 Jan 2013 16:56:15 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
References: <201301142036.r0EKaYGN005907@como.maths.usyd.edu.au>
In-Reply-To: <201301142036.r0EKaYGN005907@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/14/2013 12:36 PM, paul.szabo@sydney.edu.au wrote:
> I understand that more RAM leaves less lowmem. What is unacceptable is
> that PAE crashes or freezes with OOM: it should gracefully handle the
> issue. Noting that (for a machine with 4GB or under) PAE fails where the
> HIGHMEM4G kernel succeeds and survives.

You have found a delta, but you're not really making apples-to-apples
comparisons.  The page tables (a huge consumer of lowmem in your bug
reports) have much more overhead on a PAE kernel.  A process with a
single page faulted in with PAE will take at least 4 pagetable pages
(it's 7 in practice for me with sleeps).  It's 2 pages minimum (and in
practice with sleeps) on HIGHMEM4G.

There's probably a bug here.  But, it's incredibly unlikely to be seen
in practice on anything resembling a modern system.  The 'sleep' issue
is easily worked around by upgrading to a 64-bit kernel, or using sane
ulimit values.  Raising the vm.min_free_kbytes sysctl (to perhaps 10x of
its current value on your system) is likely to help the hangs too,
although it will further "consume" lowmem.

I appreciate your persistence here, but for a bug with such a specific
use case, and with so many reasonable workarounds, it's not something I
want to dig in to much deeper.  I'll be happy to answer any questions if
you want to go digging deeper, or want some pointers on where to go
looking to fix this properly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
