Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9AE426B004D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 13:26:18 -0500 (EST)
Date: Tue, 4 Dec 2012 18:17:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm/migration: Make rmap_walk_anon() and
 try_to_unmap_anon() more scalable
Message-ID: <20121204143714.GB2797@suse.de>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <20121201122649.GA20322@gmail.com>
 <CA+55aFx8QtP0hg8qxn__4vHQuzH7QkhTN-4fwgOpM-A=KuBBjA@mail.gmail.com>
 <20121201184135.GA32449@gmail.com>
 <CA+55aFyq7OaUxcEHXvJhp0T57KN14o-RGxqPmA+ks8ge6zJh5w@mail.gmail.com>
 <20121201201538.GB2704@gmail.com>
 <20121203141701.GN8218@suse.de>
 <CANN689Hm=g+PhJrVZ8mngPL58k45GfmwL_19F27WtwJC0G-=6g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CANN689Hm=g+PhJrVZ8mngPL58k45GfmwL_19F27WtwJC0G-=6g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Dec 04, 2012 at 06:37:41AM -0800, Michel Lespinasse wrote:
> On Mon, Dec 3, 2012 at 6:17 AM, Mel Gorman <mgorman@suse.de> wrote:
> > On Sat, Dec 01, 2012 at 09:15:38PM +0100, Ingo Molnar wrote:
> >> @@ -732,7 +732,7 @@ static int page_referenced_anon(struct p
> >>       struct anon_vma_chain *avc;
> >>       int referenced = 0;
> >>
> >> -     anon_vma = page_lock_anon_vma(page);
> >> +     anon_vma = page_lock_anon_vma_read(page);
> >>       if (!anon_vma)
> >>               return referenced;
> >
> > This is a slightly trickier one as this path is called from reclaim. It does
> > open the possibility that reclaim can stall something like a parallel fork
> > or anything that requires the anon_vma rwsem for a period of time. I very
> > severely doubt it'll really be a problem but keep an eye out for bug reports
> > related to delayed mmap/fork/anything_needing_write_lock during page reclaim.
> 
> I don't see why this would be a problem - rwsem does implement
> reader/writer fairness, so having some sites do a read lock instead of
> a write lock shouldn't cause the write lock sites to starve. Is this
> what you were worried about ?
> 

Yes. I did not expect they would be starved forever, just delayed longer
than they might have been before. I would be very surprised if there is
anything other than a synthetic case that will really care but I've been
"very surprised" before :)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
