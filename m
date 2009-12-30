Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AA5EC60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 11:50:00 -0500 (EST)
Date: Wed, 30 Dec 2009 16:49:52 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/3 -mmotm-2009-12-10-17-19] Count zero page as
 file_rss
In-Reply-To: <4B38876F.6010204@gmail.com>
Message-ID: <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com> <ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com> <4B38876F.6010204@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009, Minchan Kim wrote:
> I missed Hugh. 

Thank you: it is sweet of you to say so :)

> 
> Minchan Kim wrote:
> > Long time ago, we counted zero page as file_rss.
> > But after reinstanted zero page, we don't do it.
> > It means rss of process would be smaller than old.
> > 
> > It could chage OOM victim selection.

Eh?  We don't use rss for OOM victim selection, we use total_vm.

I know that's under discussion, and there are good arguments on
both sides (I incline to the rss side, but see David's point about
predictability); but here you seem to be making an argument for
back-compatibility, yet there is no such issue in OOM victim selection.

And if we do decide that rss is appropriate for OOM victim selection,
then we would prefer to keep the ZERO_PAGE out of rss, wouldn't we?

> > 
> > Kame reported following as
> > "Before starting zero-page works, I checked "questions" in lkml and
> > found some reports that some applications start to go OOM after zero-page
> > removal.
> > 
> > For me, I know one of my customer's application depends on behavior of
> > zero page (on RHEL5). So, I tried to add again it before RHEL6 because
> > I think removal of zero-page corrupts compatibility."
> > 
> > So how about adding zero page as file_rss again for compatibility?

I think not.

KAMEZAWA-san can correct me (when he returns in the New Year) if I'm
wrong, but I don't think his customer's OOMs had anything to do with
whether the ZERO_PAGE was counted in file_rss or not: the OOMs came
from the fact that many pages were being used up where just the one
ZERO_PAGE had been good before.  Wouldn't he have complained if the
zero_pfn patches hadn't solved that problem?

You are right that I completely overlooked the issue of whether to
include the ZERO_PAGE in rss counts (now being a !vm_normal_page,
it was just natural to leave it out); and I overlooked the fact that
it used to be counted into file_rss in the old days (being !PageAnon).

So I'm certainly at fault for that, and thank you for bringing the
issue to attention; but once considered, I can't actually see a good
reason why we should add code to count ZERO_PAGEs into file_rss now.
And if this patch falls, then 1/3 and 3/3 would fall also.

And the patch below would be incomplete anyway, wouldn't it?
There would need to be a matching change to zap_pte_range(),
but I don't see that.

We really don't want to be adding more and more ZERO_PAGE/zero_pfn
tests around the place if we can avoid them: KOSAKI-san has a strong
argument for adding such a test in kernel/futex.c, but I don't the
argument here.

Hugh

> > 
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/memory.c |    7 +++++--
> >  1 files changed, 5 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 3743fb5..a4ba271 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1995,6 +1995,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	int reuse = 0, ret = 0;
> >  	int page_mkwrite = 0;
> >  	struct page *dirty_page = NULL;
> > +	int zero_pfn = 0;
> >  
> >  	old_page = vm_normal_page(vma, address, orig_pte);
> >  	if (!old_page) {
> > @@ -2117,7 +2118,8 @@ gotten:
> >  	if (unlikely(anon_vma_prepare(vma)))
> >  		goto oom;
> >  
> > -	if (is_zero_pfn(pte_pfn(orig_pte))) {
> > +	zero_pfn = is_zero_pfn(pte_pfn(orig_pte));
> > +	if (zero_pfn) {
> >  		new_page = alloc_zeroed_user_highpage_movable(vma, address);
> >  		if (!new_page)
> >  			goto oom;
> > @@ -2147,7 +2149,7 @@ gotten:
> >  	 */
> >  	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> >  	if (likely(pte_same(*page_table, orig_pte))) {
> > -		if (old_page) {
> > +		if (old_page || zero_pfn) {
> >  			if (!PageAnon(old_page)) {
> >  				dec_mm_counter(mm, file_rss);
> >  				inc_mm_counter(mm, anon_rss);
> > @@ -2650,6 +2652,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  		spin_lock(ptl);
> >  		if (!pte_none(*page_table))
> >  			goto unlock;
> > +		inc_mm_counter(mm, file_rss);
> >  		goto setpte;
> >  	}
> >  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
