Date: Tue, 29 Apr 2008 10:48:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/8] memcg: migration handling
Message-Id: <20080429104826.e6990635.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48167BA8.2030602@cn.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
	<20080428202214.1172f4f2.kamezawa.hiroyu@jp.fujitsu.com>
	<48167BA8.2030602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008 09:36:40 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> [..snip..]
> > Index: mm-2.6.25-mm1/mm/migrate.c
> > ===================================================================
> > --- mm-2.6.25-mm1.orig/mm/migrate.c
> > +++ mm-2.6.25-mm1/mm/migrate.c
> > @@ -357,6 +357,10 @@ static int migrate_page_move_mapping(str
> >  	__inc_zone_page_state(newpage, NR_FILE_PAGES);
> >  
> >  	write_unlock_irq(&mapping->tree_lock);
> > +	if (!PageSwapCache(newpage)) {
> > +		mem_cgroup_uncharge_page(page);
> > +		mem_cgroup_getref(newpage);
> > +	}
> >  
> >  	return 0;
> >  }
> > @@ -603,7 +607,6 @@ static int move_to_new_page(struct page 
> >  		rc = fallback_migrate_page(mapping, newpage, page);
> >  
> >  	if (!rc) {
> > -		mem_cgroup_page_migration(page, newpage);
> >  		remove_migration_ptes(page, newpage);
> >  	} else
> >  		newpage->mapping = NULL;
> > @@ -633,6 +636,12 @@ static int unmap_and_move(new_page_t get
> >  		/* page was freed from under us. So we are done. */
> >  		goto move_newpage;
> >  
> > +	charge = mem_cgroup_prepare_migration(page, newpage);
> > +	if (charge == -ENOMEM) {
> > +		rc = -ENOMEM;
> > +		goto move_newpage;
> > +	}
> > +
> 
> A BUG_ON(charge) is needed to insure the only error code from
> mem_cgroup_prepare_migration() is -ENOMEM ?
> 
Hmm, it just depends on what mem_cgroup_charge_common() retruns.
And it returns 0 or -ENOMEM. But it seems good to add BUG_ON(charge)
after 'if' for sanity check.
I will add it in the next version.

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
