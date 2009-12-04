Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 16AB96B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 09:45:46 -0500 (EST)
Date: Fri, 4 Dec 2009 15:45:40 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091204144540.GI28697@random.random>
References: <20091202125501.GD28697@random.random>
 <20091203134610.586E.A69D9226@jp.fujitsu.com>
 <20091204135938.5886.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091204135938.5886.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 04, 2009 at 02:06:07PM +0900, KOSAKI Motohiro wrote:
> Windows kernel have zero page thread and it clear the pages in free list
> periodically. because many windows subsystem prerefer zero filled page.
> hen, if we use windows guest, zero filled page have plenty mapcount rather
> than other typical sharing pages, I guess.
> 
> So, can we mark as unevictable to zero filled ksm page? 

I don't like magics for zero ksm page, or magic number after which we
consider unevictable.

Just breaking the loop after 64 young are cleared and putting it back
to the head of the active list is enough. Clearly it requires a bit
more changes to fit into current code that uses page_referenced to
clear all young bits ignoring if they were set during the clear loop.

I think it's fishy to ignore the page_referenced retval and I don't
like the wipe_page_referenced concept. page_referenced should only be
called when we're in presence of VM pressure that requires
unmapping. And we should always re-add the page to active list head,
if it was found referenced as retval of page_referenced. I cannot care
less about first swapout burst to be FIFO because it'll be close to
FIFO anyway. The wipe_page_referenced thing was called 1 year ago
shortly after the page was allocated, then app touches the page after
it's in inactive anon, and then the app never touches the page again
for one year. And yet we consider it active after 1 year we cleared
its referenced bit. It's all very fishy... Plus that VM_EXEC is still
there. The only magic allowed that I advocate is to have a
page_mapcount() check to differentiate between pure cache pollution
(i.e. to avoid being forced to O_DIRECT without actually activating
unnecessary VM activity on mapped pages that aren't pure cache
pollution by somebody running a backup with tar).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
