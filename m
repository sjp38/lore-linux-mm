Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 2A4D26B005A
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 07:42:24 -0500 (EST)
Date: Thu, 8 Dec 2011 13:42:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111208124217.GD15343@redhat.com>
References: <alpine.LSU.2.00.1111041856530.22199@sister.anvils>
 <1320512782-12209-1-git-send-email-aarcange@redhat.com>
 <alpine.DEB.2.00.1112071924400.636@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112071924400.636@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Wed, Dec 07, 2011 at 07:24:59PM -0800, David Rientjes wrote:
> On Sat, 5 Nov 2011, Andrea Arcangeli wrote:
> 
> > migrate was doing a rmap_walk with speculative lock-less access on
> > pagetables. That could lead it to not serialize properly against
> > mremap PT locks. But a second problem remains in the order of vmas in
> > the same_anon_vma list used by the rmap_walk.
> > 
> > If vma_merge would succeed in copy_vma, the src vma could be placed
> > after the dst vma in the same_anon_vma list. That could still lead
> > migrate to miss some pte.
> > 
> > This patch adds a anon_vma_moveto_tail() function to force the dst vma
> > at the end of the list before mremap starts to solve the problem.
> > 
> > If the mremap is very large and there are a lots of parents or childs
> > sharing the anon_vma root lock, this should still scale better than
> > taking the anon_vma root lock around every pte copy practically for
> > the whole duration of mremap.
> > 
> > Update: Hugh noticed special care is needed in the error path where
> > move_page_tables goes in the reverse direction, a second
> > anon_vma_moveto_tail() call is needed in the error path.
> > 
> 
> Is this still needed?  It's missing in linux-next.

Yes it's needed, either this or the anon_vma lock around
move_page_tables. Then we also need the i_mmap_mutex around fork or a
triple loop in vmtruncate (then we could remove i_mmap_mutex in
mremap).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
