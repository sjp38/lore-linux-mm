Date: Wed, 17 Sep 2008 15:45:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mm] memcg: fix handling of shmem migration
Message-Id: <20080917154511.683691d1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080917153826.8efbdc4b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080917133149.b012a1c2.nishimura@mxp.nes.nec.co.jp>
	<20080917144659.2e363edc.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917145003.fb4d0b95.kamezawa.hiroyu@jp.fujitsu.com>
	<20080917151951.9a181e7d.nishimura@mxp.nes.nec.co.jp>
	<20080917153826.8efbdc4b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 15:38:26 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 17 Sep 2008 15:19:51 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hmm, something like this?
> > 
> > ---
> > @@ -734,6 +734,9 @@ int mem_cgroup_prepare_migration(struct page *page, struct page *newpa
> >         if (mem_cgroup_subsys.disabled)
> >                 return 0;
> > 
> > +       if (PageSwapBacked(page))
> > +               SetPageSwapBacked(newpage);
> > +
> >         lock_page_cgroup(page);
> >         pc = page_get_page_cgroup(page);
> >         if (pc) {
> > ---
> > 
> > Or, adding MEM_CGROUP_CHARGE_TYPE_SHMEM and
> > 
> > ---
> > @@ -740,7 +740,10 @@ int mem_cgroup_prepare_migration(struct page *page, struct page *newp
> >                 mem = pc->mem_cgroup;
> >                 css_get(&mem->css);
> >                 if (pc->flags & PAGE_CGROUP_FLAG_CACHE)
> > -                       ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +                       if (page_is_file_cache(page))
> > +                               ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +                       else
> > +                               ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> >         }
> >         unlock_page_cgroup(page);
> >         if (mem) {
> > ---
> > (Of course, mem_cgroup_charge_common should be modified too.)
> > 
> like this :) I don't want to change logic in migration.c
> (and this is special case handling for memcg.)
> 
OK.
I'll rewrite and resend it later.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
