Date: Fri, 22 Aug 2008 14:48:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH -mm 6/7] memcg:
 make-mapping-null-before-calling-uncharge.patch
Message-Id: <20080822144808.6652810e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822135743.cc07f7de.nishimura@mxp.nes.nec.co.jp>
References: <20080819173014.17358c17.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820185306.e897c512.kamezawa.hiroyu@jp.fujitsu.com>
	<20080820190702.616f4260.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822135743.cc07f7de.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, ryov@valinux.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Aug 2008 13:57:43 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -379,6 +377,15 @@ static void migrate_page_copy(struct pag
> >  	ClearPagePrivate(page);
> >  	set_page_private(page, 0);
> >  	page->mapping = NULL;
> You forget to remove this line :)
> 
Ouch, thanks.
-Kame

> Thanks,
> Daisuke Nishimura.
> 
> > +	/* page->mapping contains a flag for PageAnon() */
> > +	if (PageAnon(page)) {
> > +		/* This page is uncharged at try_to_unmap(). */
> > +		page->mapping = NULL;
> > +	} else {
> > +		/* Obsolete file cache should be uncharged */
> > +		page->mapping = NULL;
> > +		mem_cgroup_uncharge_cache_page(page);
> > +	}
> >  
> >  	/*
> >  	 * If any waiters have accumulated on the new page then
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
