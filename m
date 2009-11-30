Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 73128600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 06:55:55 -0500 (EST)
Date: Mon, 30 Nov 2009 11:55:53 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0911301141010.20054@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241640590.25288@sister.anvils>
 <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> Hmm. I'm not sure how many pages are shared in a system but
> can't we add some threshold for avoidng too much scan against shared pages ?
> (in vmscan.c)
> like..
>       
>        if (page_mapcount(page) > (XXXX >> scan_priority))
> 		return 1;
> 
> I saw terrible slow downs in shmem-swap-out in old RHELs (at user support).
> (Added kosaki to CC.)
> 
> After this patch, the number of shared swappable page will be unlimited.

I don't think KSM swapping changes the story here at all: I don't
think it significantly increases the likelihood of pages with very
high mapcounts on the LRUs.  You've met the issue with shmem, okay,
I've always thought shared library text pages would be a problem.

I've often thought that some kind of "don't bother if the mapcount is
too high" check in vmscan.c might help - though I don't think I've
ever noticed the bugreport it would help with ;)

I used to imagine doing up to a certain number inside the rmap loops
and then breaking out (that would help with those reports of huge
anon_vma lists); but that would involve starting the next time from
where we left off, which would be difficult with the prio_tree.

Your proposal above (adjusting the limit according to scan_priority,
yes that's important) looks very promising to me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
