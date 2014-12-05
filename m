Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 29AE26B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 02:07:45 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so133124pdi.30
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 23:07:44 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id qs1si19421588pbb.167.2014.12.04.23.07.41
        for <linux-mm@kvack.org>;
        Thu, 04 Dec 2014 23:07:43 -0800 (PST)
Date: Fri, 5 Dec 2014 16:08:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141205070816.GB3358@bbox>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
 <20141130235652.GA10333@bbox>
 <20141202100125.GD27014@dhcp22.suse.cz>
 <20141203000026.GA30217@bbox>
 <20141203101329.GB23236@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141203101329.GB23236@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Dec 03, 2014 at 11:13:29AM +0100, Michal Hocko wrote:
> On Wed 03-12-14 09:00:26, Minchan Kim wrote:
> > On Tue, Dec 02, 2014 at 11:01:25AM +0100, Michal Hocko wrote:
> > > On Mon 01-12-14 08:56:52, Minchan Kim wrote:
> > > [...]
> > > > From 2edd6890f92fa4943ce3c452194479458582d88c Mon Sep 17 00:00:00 2001
> > > > From: Minchan Kim <minchan@kernel.org>
> > > > Date: Mon, 1 Dec 2014 08:53:55 +0900
> > > > Subject: [PATCH] madvise.2: Document MADV_FREE
> > > > 
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  man2/madvise.2 | 13 +++++++++++++
> > > >  1 file changed, 13 insertions(+)
> > > > 
> > > > diff --git a/man2/madvise.2 b/man2/madvise.2
> > > > index 032ead7..33aa936 100644
> > > > --- a/man2/madvise.2
> > > > +++ b/man2/madvise.2
> > > > @@ -265,6 +265,19 @@ file (see
> > > >  .BR MADV_DODUMP " (since Linux 3.4)"
> > > >  Undo the effect of an earlier
> > > >  .BR MADV_DONTDUMP .
> > > > +.TP
> > > > +.BR MADV_FREE " (since Linux 3.19)"
> > > > +Gives the VM system the freedom to free pages, and tells the system that
> > > > +information in the specified page range is no longer important.
> > > > +This is an efficient way of allowing
> > > > +.BR malloc (3)
> > > 
> > > This might be rather misleading. Only some malloc implementations are
> > > using this feature (jemalloc, right?). So either be specific about which
> > > implementation or do not add it at all.
> > 
> > Make sense. I don't think it's a good idea to say specific example
> > in man page, which is rather arguable and limit the idea.
> > 
> > > 
> > > > +to free pages anywhere in the address space, while keeping the address space
> > > > +valid. The next time that the page is referenced, the page might be demand
> > > > +zeroed, or might contain the data that was there before the MADV_FREE call.
> > > > +References made to that address space range will not make the VM system page the
> > > > +information back in from backing store until the page is modified again.
> > > 
> > > I am not sure I understand the last sentence. So say I did MADV_FREE and
> > > the reclaim has dropped that page. I know that the file backed mappings
> > > are not supported yet but assume they were for a second... Now, I do
> > > read from that location again what is the result?
> > 
> > Zero page.
> 
> OK, it felt strange at first but now that I am thinking about it some
> more it starts making sense. So the semantic is: Either zero page
> (disconnected from the backing store) or the original content after
> madvise(MADV_FREE). The page gets connected to the backing store after
> it gets modified again. If this is the case then the sentence in the man
> page makes perfect sense.
> 
> What made me confused was that I expected file backed pages would get a
> fresh page from the origin but this would be awkward I guess. 
> 
> > > If we consider anon mappings then the backing store is misleading as
> > > well because memory was dropped and so always newly allocated.
> > 
> > When I read the sentence at first, I thought backing store means swap
> > so I don't have any trouble to understand it. But I agree your opinion.
> > Target for man page is not a kernel developer but application developer.
> > 
> > > I would rather drop the whole sentence and rather see an explanation
> > > what is the difference between to MADV_DONT_NEED.
> > > "
> > > Unlike MADV_DONT_NEED the memory is freed lazily e.g. when the VM system
> > > is under memory pressure.
> > > "
> > 
> > It's a good idea but I don't think it's enough. At least we should explan
> > cancel of delay free logic(ie, write). So, How about this?
> > 
> > MADV_FREE " (since Linux 3.19)"
> > 
> > Gives the VM system the freedom to free pages, and tells the system that
> > it's okay to free pages if the VM system has reasons(e.g., memory pressure).
> > So, it looks like delayed MADV_DONTNEED.
> > The next time that the page is referenced, the page might be demand
> > zeroed if the VM system freed the page. Otherwise, it might contain the data
> > that was there before the MADV_FREE call if the VM system didn't free the page.
> > New write in the page after the MADV_FREE call makes the VM system not free
> > the page any more.
> 
> Dunno, I guess the original content was slightly better. Or the
> following wording from UNIX man pages is even more descriptive
> (http://www.lehman.cuny.edu/cgi-bin/man-cgi?madvise+3)
> "
> Tell the kernel that contents in the specified address range are no
> longer important and the range will be overwritten. When there is
> demand for memory, the system will free pages associated with the
> specified address range. In this instance, the next time a page in the
> address range is referenced, it will contain all zeroes.  Otherwise,
> it will con- tain the data that was there prior to the MADV_FREE
> call. References made to the address range will not make the system read
> from backing store (swap space) until the page is modified again.
> 
> This value cannot be used on mappings that have underlying file objects.
> "

For me, it would be better.
Thanks for the heads up.

> 
> I would just clarify the last sentence with addition
> (MAP_PRIVATE|MAP_ANONYMOUS mappings in this implementation). The

I want to be consistent with KSM/THP which used "private anonymous pages".
So, I guess man page maintainer already acked the term so I want to use it,
too.


> difference to MADV_DONTNEED is more complicated now so I wouldn't make
> the text even more confusing.
> 
> Anyway the confusion started on my end so feel free to stick with the
> BSD wording (modulo malloc note which is really confusing as the default
> glibc allocator doesn't do that AFAIK).
