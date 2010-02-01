Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 951736B0047
	for <linux-mm@kvack.org>; Mon,  1 Feb 2010 12:04:18 -0500 (EST)
Message-ID: <4B670968.7090801@redhat.com>
Date: Mon, 01 Feb 2010 12:03:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 32 of 32] khugepaged
References: <patchbomb.1264969631@v2.random> <51b543fab38b1290f176.1264969663@v2.random>
In-Reply-To: <51b543fab38b1290f176.1264969663@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 01/31/2010 03:27 PM, Andrea Arcangeli wrote:

> +	/* stop anon_vma rmap pagetable access */
> +	spin_lock(&vma->anon_vma->lock);

This is no longer enough.  The anon_vma changes that
went into -mm recently mean that a VMA can be associated
with multiple anon_vmas.

Of course, forcefully COW copying/writing every page in
the VMA will ensure that they are all in the anon_vma
you lock with the code above.

I suspect the easiest fix would be to lock all the
anon_vmas attached to a VMA.  That should not lead to
any deadlocks, since multiple siblings of the same
parent process would be encountering their anon_vma
structs in the same order, due to the way that
anon_vma_clone and anon_vma_fork work.

This may be too subtle for lockdep, though :/

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
