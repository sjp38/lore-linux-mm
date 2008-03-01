Date: Sat, 01 Mar 2008 16:02:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 03/21] use an array for the LRU pagevecs
In-Reply-To: <20080229154056.GF28849@shadowen.org>
References: <20080228192928.165393706@redhat.com> <20080229154056.GF28849@shadowen.org>
Message-Id: <20080301153941.528A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andy

sorry, almost mistake maked by me. 

> >  #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
> >  
> > +static inline int is_active_lru(enum lru_list l)
> > +{
> > +	if (l == LRU_ACTIVE)
> > +		return 1;
> > +	return 0;
> 
> Can this not be:
> 
> 	return (l == LRU_ACTIVE);

yes, your code is more better.

Thanks.


> > @@ -98,6 +97,19 @@ void put_pages_list(struct list_head *pa
> >  EXPORT_SYMBOL(put_pages_list);
> >  
> >  /*
> > + * Returns the LRU list a page should be on.
> > + */
> > +enum lru_list page_lru(struct page *page)
> > +{
> > +	enum lru_list lru = LRU_BASE;
> > +
> > +	if (PageActive(page))
> > +		lru += LRU_ACTIVE;
> 
> This is introducing an assumption that LRU_BASE and LRU_INACTIVE are
> synonymous?  Would it not be better to explicitly use LRU_INACTIVE:

Yes.
this patch series assume LRU_BASE == LRU_INACTIVE.

> So either:
> 
> 	if (PageActive(page))
> 		lru = LRU_ACTIVE;
> 	else
> 		lru = LRU_INACTIVE;

if add LRU_FILE, this statement makes messy.
key point of indexed arraynize is able to arithmetic calculationed.


> Or if (as I assume) this is later going to have other mappings added in
> you could do it more like the following.  This should produce identicle
> asm, but removes any possiblity of LRU_BASE/INACTIVE slippage breaking
> things:
> 
> 	enum lru_list lru = LRU_INACTIVE;
> 
> 	if (PageActive(page))
> 		lru += (LRU_ACTIVE - LRU_INACTIVE);

I think your code is more descriptive, but not best simply.
I think LRU_BASE == LRU_INACTIVE assumption make simply code.

> > -	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
> > +	if (PageActive(page)) {
> > +		ClearPageActive(page);
> > +	}
> 
> {}'s are not needed here.

agghh
thank you good catch ;)


Thank you again for your very careful reviews.


- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
