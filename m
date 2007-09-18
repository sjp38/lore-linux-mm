Subject: Re: [PATCH/RFC 4/14] Reclaim Scalability: Define page_anon()
	function
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205425.6536.69946.sendpatchset@localhost>
	 <20070918105842.5218db50.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 18 Sep 2007 11:04:46 -0400
Message-Id: <1190127886.5035.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-18 at 10:58 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 14 Sep 2007 16:54:25 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> > +/*
> > + * Returns true if this page is anonymous, tmpfs or otherwise swap backed.
> > + */
> > +extern const struct address_space_operations shmem_aops;
> > +static inline int page_anon(struct page *page)
> > +{
> > +	struct address_space *mapping;
> > +
> > +	if (PageAnon(page) || PageSwapCache(page))
> > +		return 1;
> > +	mapping = page_mapping(page);
> > +	if (!mapping || !mapping->a_ops)
> > +		return 0;
> > +	if (mapping->a_ops == &shmem_aops)
> > +		return 1;
> > +	/* Should ramfs pages go onto an mlocked list instead? */
> > +	if ((unlikely(mapping->a_ops->writepage == NULL && PageDirty(page))))
> > +		return 1;
> > +
> > +	/* The page is page cache backed by a normal filesystem. */
> > +	return 0;
> > +}
> > +
> 
> Hi, it seems the name 'page_anon()' is not clear..
> In my understanding, an anonymous page is a MAP_ANONYMOUS page.
> Can't we have better name ?

Hi, Kame-san:

I'm open to a "better name".  Probably Rik, too -- it's his original
name.

How about one of these?

- page_is_swap_backed() or page_is_backed_by_swap_space()
- page_needs_swap_space() or page_uses_swap_space()
- pageNeedSwapSpaceToBeReclaimable() [X11-style :-)]

Other ideas?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
