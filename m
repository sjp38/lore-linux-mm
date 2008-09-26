Date: Fri, 26 Sep 2008 19:07:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/12] memcg make page->mapping NULL before calling
 uncharge
Message-Id: <20080926190753.bd0e7ebc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <48DCAFC4.40009@linux.vnet.ibm.com>
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
	<20080925151639.5e2ddea4.kamezawa.hiroyu@jp.fujitsu.com>
	<48DCAFC4.40009@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Fri, 26 Sep 2008 15:17:48 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > This patch tries to make page->mapping to be NULL before
> > mem_cgroup_uncharge_cache_page() is called.
> > 
> > "page->mapping == NULL" is a good check for "whether the page is still
> > radix-tree or not".
> > This patch also adds BUG_ON() to mem_cgroup_uncharge_cache_page();
> > 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Looks good, small nit-pick below
> 
> >  #endif
> >  	ClearPagePrivate(page);
> >  	set_page_private(page, 0);
> > -	page->mapping = NULL;
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
> 
> Isn't it better and correct coding style to do
> 
> 	/*
> 	 * Uncharge obsolete file cache
> 	 */
> 	if (!PageAnon(page))
> 		mem_cgroup_uncharge_cache_page(page);
> 	/* else - uncharged at try_to_unmap() */
> 	page->mapping = NULL;
> 
yea, maybe.
I always wonder what I should do when I want to add comment to if-then-else...

But ok, will remove {}.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
