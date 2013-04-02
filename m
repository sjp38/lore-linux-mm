Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A70EB6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 06:56:28 -0400 (EDT)
Date: Tue, 2 Apr 2013 11:56:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/mmap: Check for RLIMIT_AS before unmapping
Message-ID: <20130402105625.GA12855@suse.de>
References: <20130402095402.GA6568@rei>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130402095402.GA6568@rei>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 02, 2013 at 11:54:03AM +0200, Cyril Hrubis wrote:
> This patch fixes corner case for MAP_FIXED when requested mapping length
> is larger than rlimit for virtual memory. In such case any overlapping
> mappings are unmapped before we check for the limit and return ENOMEM.
> 
> The check is moved before the loop that unmaps overlapping parts of
> existing mappings. When we are about to hit the limit (currently mapped
> pages + len > limit) we scan for overlapping pages and check again
> accounting for them.
> 
> This fixes situation when userspace program expects that the previous
> mappings are preserved after the mmap() syscall has returned with error.
> (POSIX clearly states that successfull mapping shall replace any
> previous mappings.)
> 
> This corner case was found and can be tested with LTP testcase:
> 
> testcases/open_posix_testsuite/conformance/interfaces/mmap/24-2.c
> 
> In this case the mmap, which is clearly over current limit, unmaps
> dynamic libraries and the testcase segfaults right after returning into
> userspace.
> 
> I've also looked at the second instance of the unmapping loop in the
> do_brk(). The do_brk() is called from brk() syscall and from vm_brk().
> The brk() syscall checks for overlapping mappings and bails out when
> there are any (so it can't be triggered from the brk syscall). The
> vm_brk() is called only from binmft handlers so it shouldn't be
> triggered unless binmft handler created overlapping mappings.
> 
> Signed-off-by: Cyril Hrubis <chrubis@suse.cz>

Reviewed-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
