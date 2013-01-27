Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id C13146B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 18:12:28 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so43919pbc.3
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 15:12:28 -0800 (PST)
Date: Sun, 27 Jan 2013 15:12:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 7/11] ksm: make KSM page migration possible
In-Reply-To: <1359265635.6763.0.camel@kernel>
Message-ID: <alpine.LNX.2.00.1301271506480.17495@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251802050.29196@eggly.anvils> <1359265635.6763.0.camel@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 26 Jan 2013, Simon Jeons wrote:
> On Fri, 2013-01-25 at 18:03 -0800, Hugh Dickins wrote:
> > +	while (!get_page_unless_zero(page)) {
> > +		/*
> > +		 * Another check for page->mapping != expected_mapping would
> > +		 * work here too.  We have chosen the !PageSwapCache test to
> > +		 * optimize the common case, when the page is or is about to
> > +		 * be freed: PageSwapCache is cleared (under spin_lock_irq)
> > +		 * in the freeze_refs section of __remove_mapping(); but Anon
> > +		 * page->mapping reset to NULL later, in free_pages_prepare().
> > +		 */
> > +		if (!PageSwapCache(page))
> > +			goto stale;
> > +		cpu_relax();
> > +	}
> > +
> > +	if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> >  		put_page(page);
> >  		goto stale;
> >  	}
> > +
> >  	if (locked) {
> >  		lock_page(page);
> > -		if (page->mapping != expected_mapping) {
> > +		if (ACCESS_ONCE(page->mapping) != expected_mapping) {
> >  			unlock_page(page);
> >  			put_page(page);
> >  			goto stale;
> >  		}
> >  	}
> 
> Could you explain why need check page->mapping twice after get page?

Once for the !locked case, which should not return page if mapping changed.
Once for the locked case, which should not return page if mapping changed.
We could use "else", but that wouldn't be an improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
