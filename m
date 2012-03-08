Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 269886B00E9
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 01:10:01 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B01143EE0C0
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:59 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9110845DE53
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D17345DD78
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57C721DB803F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3CD21DB803C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:09:58 +0900 (JST)
Date: Thu, 8 Mar 2012 15:08:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix mapcount check in move charge code for
 anonymous page
Message-Id: <20120308150826.b45f1f16.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1331076667-11118-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <alpine.LSU.2.00.1203061230530.17934@eggly.anvils>
	<1331076667-11118-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Hugh Dickins <hughd@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue,  6 Mar 2012 18:31:07 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Tue, Mar 06, 2012 at 12:55:42PM -0800, Hugh Dickins wrote:
> > On Mon, 5 Mar 2012, Daisuke Nishimura wrote:
> > > Hi, Horiguchi-san.
> > > On Fri,  2 Mar 2012 15:35:08 -0500
> > > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> > >
> > > > Currently charge on shared anonyous pages is supposed not to moved
> > > > in task migration. To implement this, we need to check that mapcount > 1,
> > > > instread of > 2. So this patch fixes it.
> > > >
> > > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > > ---
> > > >  mm/memcontrol.c |    2 +-
> > > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > >
> > > > diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> > > > index b6d1bab..785f6d3 100644
> > > > --- linux-next-20120228.orig/mm/memcontrol.c
> > > > +++ linux-next-20120228/mm/memcontrol.c
> > > > @@ -5102,7 +5102,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
> > > >  		return NULL;
> > > >  	if (PageAnon(page)) {
> > > >  		/* we don't move shared anon */
> > > > -		if (!move_anon() || page_mapcount(page) > 2)
> > > > +		if (!move_anon() || page_mapcount(page) > 1)
> > > >  			return NULL;
> > > >  	} else if (!move_file())
> > > >  		/* we ignore mapcount for file pages */
> > > > --
> > > > 1.7.7.6
> > > >
> > > Sorry, it's my fault..
> > > Thank you for catching this.
> > >
> > > Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> >
> > I'm perversely sorry to see this fix already wing its way into 3.3-rc,
> > but never mind.
> >
> > I was puzzling over that same "> 2" test when thinking through the
> > stats move locking, and again when swap accounting appeared to be
> > broken through and through (now fixed by two-liner in page_cgroup.c).
> >
> > Why is there any test on page_mapcount(page) there at all?
> > 2.6.34 comments it
> > 	* TODO: We don't move charges of shared(used by multiple
> > 	* processes) pages for now.
> > as if it's an unwelcome restriction to be eliminated later.
> 
> I see.
> This comment implies this restiction is a temporary one.
> 

We don't dicided a policy.



> > I don't understand why it was ever there, and would like to remove
> > it (and update the Documentation file) - just to remove a little
> > unnecessary complication, including mem_cgroup_count_swap_user().
> >
> > The file case moves account, even when the page is not mapped into
> > this address space, even when it's mapped into a thousand others.
> >
> > Why treat the anonymous so differently here?
> 
> I'm not sure the reason, but current behavior is obviously confusing
> (at least for me.) We need to fix it in clearer manner.
> 
> IMO, ideally the charge of shared (both file and anon) pages should
> be accounted for all cgroups to which the processes mapping the pages
> belong to, where each charge is weighted by inverse number of mapcount.

One of problems is that shared file between memcg cannot be reclaimed.
Assume independent memcgs A and B. And file X is shared between A and B but linked to
B's LRU. Now, it's accounted to B.

If we do accounting both to A and B, we cannot reclaim it. And overhead of
memcg will be very huge.

I think it may be a way to add memcg atrribute per inode by fadvise() or some
or system config.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
