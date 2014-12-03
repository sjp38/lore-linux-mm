Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9396B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 19:00:03 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so14476653pad.31
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 16:00:02 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xb5si16862246pab.87.2014.12.02.16.00.00
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 16:00:01 -0800 (PST)
Date: Wed, 3 Dec 2014 09:00:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141203000026.GA30217@bbox>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141202100125.GD27014@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Dec 02, 2014 at 11:01:25AM +0100, Michal Hocko wrote:
> On Mon 01-12-14 08:56:52, Minchan Kim wrote:
> [...]
> > From 2edd6890f92fa4943ce3c452194479458582d88c Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Mon, 1 Dec 2014 08:53:55 +0900
> > Subject: [PATCH] madvise.2: Document MADV_FREE
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  man2/madvise.2 | 13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> > 
> > diff --git a/man2/madvise.2 b/man2/madvise.2
> > index 032ead7..33aa936 100644
> > --- a/man2/madvise.2
> > +++ b/man2/madvise.2
> > @@ -265,6 +265,19 @@ file (see
> >  .BR MADV_DODUMP " (since Linux 3.4)"
> >  Undo the effect of an earlier
> >  .BR MADV_DONTDUMP .
> > +.TP
> > +.BR MADV_FREE " (since Linux 3.19)"
> > +Gives the VM system the freedom to free pages, and tells the system that
> > +information in the specified page range is no longer important.
> > +This is an efficient way of allowing
> > +.BR malloc (3)
> 
> This might be rather misleading. Only some malloc implementations are
> using this feature (jemalloc, right?). So either be specific about which
> implementation or do not add it at all.

Make sense. I don't think it's a good idea to say specific example
in man page, which is rather arguable and limit the idea.

> 
> > +to free pages anywhere in the address space, while keeping the address space
> > +valid. The next time that the page is referenced, the page might be demand
> > +zeroed, or might contain the data that was there before the MADV_FREE call.
> > +References made to that address space range will not make the VM system page the
> > +information back in from backing store until the page is modified again.
> 
> I am not sure I understand the last sentence. So say I did MADV_FREE and
> the reclaim has dropped that page. I know that the file backed mappings
> are not supported yet but assume they were for a second... Now, I do
> read from that location again what is the result?

Zero page.

> If we consider anon mappings then the backing store is misleading as
> well because memory was dropped and so always newly allocated.

When I read the sentence at first, I thought backing store means swap
so I don't have any trouble to understand it. But I agree your opinion.
Target for man page is not a kernel developer but application developer.

> I would rather drop the whole sentence and rather see an explanation
> what is the difference between to MADV_DONT_NEED.
> "
> Unlike MADV_DONT_NEED the memory is freed lazily e.g. when the VM system
> is under memory pressure.
> "

It's a good idea but I don't think it's enough. At least we should explan
cancel of delay free logic(ie, write). So, How about this?

MADV_FREE " (since Linux 3.19)"

Gives the VM system the freedom to free pages, and tells the system that
it's okay to free pages if the VM system has reasons(e.g., memory pressure).
So, it looks like delayed MADV_DONTNEED.
The next time that the page is referenced, the page might be demand
zeroed if the VM system freed the page. Otherwise, it might contain the data
that was there before the MADV_FREE call if the VM system didn't free the page.
New write in the page after the MADV_FREE call makes the VM system not free
the page any more.
It works only with private anonymous pages (see mmap(2)).

> 
> > +It works only with private anonymous pages (see
> > +.BR mmap (2)).
> >  .SH RETURN VALUE
> >  On success
> >  .BR madvise ()
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
