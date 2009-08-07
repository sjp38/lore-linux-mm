Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 46DAB6B004D
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 04:00:37 -0400 (EDT)
Date: Fri, 7 Aug 2009 10:00:18 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/6] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090807080018.GD20292@elte.hu>
References: <1249574827-18745-1-git-send-email-mel@csn.ul.ie> <1249574827-18745-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1249574827-18745-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>


* Mel Gorman <mel@csn.ul.ie> wrote:

> This patch adds a simple post-processing script for the 
> page-allocator-related trace events. It can be used to give an 
> indication of who the most allocator-intensive processes are and 
> how often the zone lock was taken during the tracing period. 
> Example output looks like

Note, this script hard-codes certain aspects of the output format:

+my $regex_traceevent =
+'\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\s*(.*)';
+my $regex_fragdetails = 'page=([0-9a-f]*) pfn=([0-9]*) alloc_order=([0-9]*)
+fallback_order=([0-9]*) pageblock_order=([0-9]*) alloc_migratetype=([0-9]*)
+fallback_migratetype=([0-9]*) fragmenting=([0-9]) change_ownership=([0-9])';
+my $regex_statname = '[-0-9]*\s\((.*)\).*';
+my $regex_statppid = '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';

the proper appproach is to parse /debug/tracing/events/mm/*/format. 
That is why we emit a format string - to detach tools and reduce the 
semi-ABI effect.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
