Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id A5AD76B00D5
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:55:37 -0400 (EDT)
Date: Tue, 26 Mar 2013 09:55:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 05/10] migrate: add hugepage migration code to
 migrate_pages()
Message-ID: <20130326085535.GL2295@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325130416.GV2154@dhcp22.suse.cz>
 <1364274790-z44rtlpy-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364274790-z44rtlpy-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue 26-03-13 01:13:10, Naoya Horiguchi wrote:
> On Mon, Mar 25, 2013 at 02:04:16PM +0100, Michal Hocko wrote:
> > On Fri 22-03-13 16:23:50, Naoya Horiguchi wrote:
[...]
> > > @@ -1012,14 +1040,8 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> > >  	check_range(mm, mm->mmap->vm_start, mm->task_size, &nmask,
> > >  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
> > >  
> > > -	if (!list_empty(&pagelist)) {
> > > -		err = migrate_pages(&pagelist, new_node_page, dest,
> > > +	return migrate_movable_pages(&pagelist, new_node_page, dest,
> > >  					MIGRATE_SYNC, MR_SYSCALL);
> > > -		if (err)
> > > -			putback_lru_pages(&pagelist);
> > > -	}
> > > -
> > > -	return err;
> > 
> > This is really confusing. Why migrate_pages doesn't do putback cleanup
> > on its own but migrate_movable_pages does?
> 
> I consider migrate_movable_pages() as a wrapper of migrate_pages(),
> not the variant of migrate_pages().

The naming suggests that this is the same functionality for a "different"
type of pages.

> We can find the same pattern in the callers like
> 
>   if (!list_empty(&pagelist)) {
>         err = migrate_pages(...);
>         if (err)
>                 putback_lru_pages(&pagelist);
>   }
> 
> , so it can be simplified by migrate_movable_pages().

I would rather see the same pattern for both. It could be error prone if

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
