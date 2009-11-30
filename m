Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D1B4D600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 07:07:10 -0500 (EST)
Date: Mon, 30 Nov 2009 13:07:05 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091130120705.GD30235@random.random>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
 <Pine.LNX.4.64.0911241640590.25288@sister.anvils>
 <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 30, 2009 at 09:46:16AM +0900, KAMEZAWA Hiroyuki wrote:
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

If those ptes are all old there's no reason to keep those pages in ram
more... I don't like those magic number levels. If you saw slowdowns
it'd be interesting to get more information on those workloads. I
never seen swap out workloads in real life that are not 99% I/O
dominated, there's nothing that loads the cpu anything close to 100%,
so nothing that a magic check like above could affect. Besides tmpfs
unmap methods are different from ksm and anon pages unmap methods, and
certain locks are coarser if there's userland taking i_mmap_lock for
I/O during paging.

> After this patch, the number of shared swappable page will be unlimited.

It is unlimited even without ksm, tmpfs may be limited but it's not
like we stop fork from sharing at some point and anon_vma is less
finegrined than rmap_item and it can also include in its list vmas not
mapping the page in presence of mremap/munmap partial truncation of
the copied/shared vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
