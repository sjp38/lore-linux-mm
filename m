Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 554646B007B
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 08:59:52 -0500 (EST)
Date: Fri, 19 Feb 2010 13:59:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 01/12] mm,migration: Take a reference to the anon_vma
	before migrating
Message-ID: <20100219135934.GF30258@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie> <1266516162-14154-2-git-send-email-mel@csn.ul.ie> <20100219091244.2116db73.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100219091244.2116db73.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 09:12:44AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 18 Feb 2010 18:02:31 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
> > locking an anon_vma and it does not appear to have sufficient locking to
> > ensure the anon_vma does not disappear from under it.
> > 
> > This patch copies an approach used by KSM to take a reference on the
> > anon_vma while pages are being migrated. This should prevent rmap_walk()
> > running into nasty surprises later because anon_vma has been freed.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> I have no objection to this direction. But after this patch, you can remove
> rcu_read_lock()/unlock() in unmap_and_move().
> ruc_read_lock() is for guarding against anon_vma replacement.
> 

Thanks. I expected that would be the case but was going to leave at
least one kernel release between when compaction went in and I did that.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
