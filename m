Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4ABD56B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 03:49:51 -0500 (EST)
Received: by iyj17 with SMTP id 17so19946342iyj.14
        for <linux-mm@kvack.org>; Tue, 11 Jan 2011 00:49:49 -0800 (PST)
Date: Tue, 11 Jan 2011 17:49:36 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] memcg: remove charge variable in unmap_and_move
Message-ID: <20110111084936.GD2113@barrios-desktop>
References: <1294725650-4732-1-git-send-email-minchan.kim@gmail.com>
 <20110111153513.1c09fa21.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110111153513.1c09fa21.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 11, 2011 at 03:35:13PM +0900, Daisuke Nishimura wrote:
> Hi,
> 
> On Tue, 11 Jan 2011 15:00:50 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > memcg charge/uncharge could be handled by mem_cgroup_[prepare/end]
> > migration itself so charge local variable in unmap_and_move lost the role
> > since we introduced 01b1ae63c2.
> > 
> > In addition, the variable name is not good like below.
> > 
> > int unmap_and_move()
> > {
> > 	charge = mem_cgroup_prepare_migration(xxx);
> > 	..
> > 		BUG_ON(charge); <-- BUG if it is charged?
> > 		..
> > 		uncharge:
> > 		if (!charge)    <-- why do we have to uncharge !charge?
> > 			mem_group_end_migration(xxx);
> > 	..
> > }
> > 
> > So let's remove unnecessary and confusing variable.
> > 
> > Suggested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/migrate.c |   12 ++++--------
> >  1 files changed, 4 insertions(+), 8 deletions(-)
> > 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index b8a32da..e393841 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -623,7 +623,6 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	struct page *newpage = get_new_page(page, private, &result);
> >  	int remap_swapcache = 1;
> >  	int rcu_locked = 0;
> > -	int charge = 0;
> >  	struct mem_cgroup *mem = NULL;
> >  	struct anon_vma *anon_vma = NULL;
> >  
> > @@ -662,12 +661,10 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  	}
> >  
> >  	/* charge against new page */
> > -	charge = mem_cgroup_prepare_migration(page, newpage, &mem);
> > -	if (charge == -ENOMEM) {
> > -		rc = -ENOMEM;
> > +	rc = mem_cgroup_prepare_migration(page, newpage, &mem);
> > +	if (rc == -ENOMEM)
> >  		goto unlock;
> > -	}
> > -	BUG_ON(charge);
> > +	BUG_ON(rc);
> >  
> >  	if (PageWriteback(page)) {
> >  		if (!force || !sync)
> > @@ -760,8 +757,7 @@ rcu_unlock:
> >  	if (rcu_locked)
> >  		rcu_read_unlock();
> >  uncharge:
> > -	if (!charge)
> > -		mem_cgroup_end_migration(mem, page, newpage, rc == 0);
> > +	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
> >  unlock:
> >  	unlock_page(page);
> >  
> I proposed pseud code like above, but it's wrong unfortunately.
> If mem_cgroup_prepare_migration() has succeeded, rc is overwritten to 0.
> So even if we failed before calling move_to_new_page(), rc is 0 and
> mem_cgroup_end_migration() mis-understand this migration has succeeded.

Right. I missed it.
Thanks for the review.

> 
> And, it seems to be just a bit off-topic, the place of the comment
> "prepare cgroup just returns 0 or -ENOMEM" isn't good, seeing the commit e8589cc1,
> which introduced the comment first.
> 
> So, we should do like:
> 
> 	/* charge against new page */
> 	if (mem_cgroup_end_migration(page, &newpage, &mem)) {
> 		/* prepare_migration just returns 0 or -ENOMEM */
> 		rc = -ENOMEM;
> 		goto unlock;
> 	}

Hmm.. I don't think so. The comment should be in there which is initialized the
variable but comment is confusing. So instead of moving, I will fix the comment.


> 
> 	if (PageWriteback(page)) {
> 		...
> 
> uncharge:
> 	mem_cgroup_end_migration(mem, page, newpage, rc == 0);
> 
> or, overwrite rc to -EAGAIN again.
> I don't stick to checking "BUG_ON(charge)" personally.

I agree. BUG_ON is meaningless.
I will resend the patch.

Thanks. :)

> 
> 
> Thanks,
> Daisuke Nishimura.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
