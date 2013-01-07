Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6A77D6B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:36:48 -0500 (EST)
Date: Mon, 7 Jan 2013 14:36:43 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: thp: Acquire the anon_vma rwsem for lock during split
Message-ID: <20130107143643.GG3885@suse.de>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
 <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
 <20130103175737.GA3885@suse.de>
 <20130104140815.GA26005@suse.de>
 <alpine.LNX.2.00.1301041253280.4520@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1301041253280.4520@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Zhouping Liu <zliu@redhat.com>, Alexander Beregalov <a.beregalov@gmail.com>, Hillf Danton <dhillf@gmail.com>, Alex Xu <alex_y_xu@yahoo.ca>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jan 04, 2013 at 01:28:09PM -0800, Hugh Dickins wrote:
> I've added Alexander, Hillf and Alex to the Cc.
> 
> On Fri, 4 Jan 2013, Mel Gorman wrote:
> > Zhouping, please test this patch.
> > 
> > Andrea and Hugh, any comments on whether this could be improved?
> 
> Your patch itself looks just right to me, no improvement required;
> and it's easy to understand how the bug crept in, from a blanket
> rwsem replacement of anon_vma mutex meeting the harmless-looking
> anon_vma_interval_tree_foreach in __split_huge_page, which looked
> as if it needed only the readlock provided by the usual method.
> 

Indeed. Thanks Hugh for taking a look over it.

> But I'd fight shy myself of trying to describe all the THP locking
> conventions in the commit message: I haven't really tried to work
> out just how right you've got all those details.
> 

I thought it was risky myself but it was the best way of getting Andrea
to object if I missed some subtlety! If I had infinite time I would
follow up with a patch to Documentation/vm/transhuge.txt explaining how
the anon_vma lock is used by THP.

> The actual race in question here was just two processes (one or both
> forked) doing split_huge_page() on the same THPage at the same time,
> wasn't it?  (Though of course we only see the backtrace from one of
> them.)  Which would be very confusing, and no surprise that the
> pmd_trans_splitting test ends up skipping pmds already updated by
> the racing process, so the mapcount doesn't match what's expected.
> Of course we need exclusive lock against that, which you give it.
> 

Ok, thanks. Will resend to Andrew with some changelog edits.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
