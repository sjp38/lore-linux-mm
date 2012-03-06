Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 2B4B76B0092
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 18:31:21 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] memcg: fix mapcount check in move charge code for anonymous page
Date: Tue,  6 Mar 2012 18:31:07 -0500
Message-Id: <1331076667-11118-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <alpine.LSU.2.00.1203061230530.17934@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Mar 06, 2012 at 12:55:42PM -0800, Hugh Dickins wrote:
> On Mon, 5 Mar 2012, Daisuke Nishimura wrote:
> > Hi, Horiguchi-san.
> > On Fri,  2 Mar 2012 15:35:08 -0500
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> >
> > > Currently charge on shared anonyous pages is supposed not to moved
> > > in task migration. To implement this, we need to check that mapcount > 1,
> > > instread of > 2. So this patch fixes it.
> > >
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > ---
> > >  mm/memcontrol.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >
> > > diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> > > index b6d1bab..785f6d3 100644
> > > --- linux-next-20120228.orig/mm/memcontrol.c
> > > +++ linux-next-20120228/mm/memcontrol.c
> > > @@ -5102,7 +5102,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> > >  		return NULL;
> > >  	if (PageAnon(page)) {
> > >  		/* we don't move shared anon */
> > > -		if (!move_anon() || page_mapcount(page) > 2)
> > > +		if (!move_anon() || page_mapcount(page) > 1)
> > >  			return NULL;
> > >  	} else if (!move_file())
> > >  		/* we ignore mapcount for file pages */
> > > --
> > > 1.7.7.6
> > >
> > Sorry, it's my fault..
> > Thank you for catching this.
> >
> > Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>
> I'm perversely sorry to see this fix already wing its way into 3.3-rc,
> but never mind.
>
> I was puzzling over that same "> 2" test when thinking through the
> stats move locking, and again when swap accounting appeared to be
> broken through and through (now fixed by two-liner in page_cgroup.c).
>
> Why is there any test on page_mapcount(page) there at all?
> 2.6.34 comments it
> 	* TODO: We don't move charges of shared(used by multiple
> 	* processes) pages for now.
> as if it's an unwelcome restriction to be eliminated later.

I see.
This comment implies this restiction is a temporary one.

> I don't understand why it was ever there, and would like to remove
> it (and update the Documentation file) - just to remove a little
> unnecessary complication, including mem_cgroup_count_swap_user().
>
> The file case moves account, even when the page is not mapped into
> this address space, even when it's mapped into a thousand others.
>
> Why treat the anonymous so differently here?

I'm not sure the reason, but current behavior is obviously confusing
(at least for me.) We need to fix it in clearer manner.

IMO, ideally the charge of shared (both file and anon) pages should
be accounted for all cgroups to which the processes mapping the pages
belong to, where each charge is weighted by inverse number of mapcount.
I think accounting total number of mapcount with another counter does
not work, because the weight of charge depends on each page and the
total count of mapcount doesn't describe the proportion among cgroups.
But anyway, it adds more complexity and needs much work, so is not
a short term fix.

> I'd have thought it
> quite likely (by no means certain, but quite likely) that when you
> move a task sharing an anon page from one cg to another, you'll
> move the other task(s) sharing it immediately after - strange that
> these shared pages should then get left behind.

I agree. Currently we can exactly account only if all processes charging
shared anon pages are migrated to the same cgroup. Otherwise, something
strange happen.

> I was pleased by the "> 2" bug, there almost all the life of
> move_charge_at_immigrate, demonstrating that nobody was depending
> upon the documented behaviour.
>
> I've a few more cleanups in the swap accounting area, I guess I
> should just post this change along with them and we discuss then,
> unless you can enlighten me what it's about before I get there.

I just began hacking memcg code few weeks ago, so I don't have any
more detailed idea about it now.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
