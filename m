Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 70B5F6B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 19:41:24 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so969604dak.11
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 16:41:23 -0800 (PST)
Message-ID: <1359333683.6763.13.camel@kernel>
Subject: Re: [PATCH 7/11] ksm: make KSM page migration possible
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 27 Jan 2013 18:41:23 -0600
In-Reply-To: <alpine.LNX.2.00.1301271506480.17495@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251802050.29196@eggly.anvils>
	 <1359265635.6763.0.camel@kernel>
	 <alpine.LNX.2.00.1301271506480.17495@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 2013-01-27 at 15:12 -0800, Hugh Dickins wrote:
> On Sat, 26 Jan 2013, Simon Jeons wrote:
> > On Fri, 2013-01-25 at 18:03 -0800, Hugh Dickins wrote:
> > > +	while (!get_page_unless_zero(page)) {
> > > +		/*
> > > +		 * Another check for page->mapping != expected_mapping would
> > > +		 * work here too.  We have chosen the !PageSwapCache test to
> > > +		 * optimize the common case, when the page is or is about to
> > > +		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
> > > +		 * in the freeze_refs section of __remove_mapping(); but Anon
> > > +		 * page->mapping reset to NULL later, in free_pages_prepare().
> > > +		 */
> > > +		if (!PageSwapCache(page))
> > > +			goto stale;
> > > +		cpu_relax();
> > > +	}
> > > +
> > > +	if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> > >  		put_page(page);
> > >  		goto stale;
> > >  	}
> > > +
> > >  	if (locked) {
> > >  		lock_page(page);
> > > -		if (page->mapping != expected_mapping) {
> > > +		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> > >  			unlock_page(page);
> > >  			put_page(page);
> > >  			goto stale;
> > >  		}
> > >  	}
> > 
> > Could you explain why need check page->mapping twice after get page?
> 
> Once for the !locked case, which should not return page if mapping changed.
> Once for the locked case, which should not return page if mapping changed.
> We could use "else", but that wouldn't be an improvement.

But for locked case, page->mapping will be check twice.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
