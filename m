Date: Tue, 7 Dec 2004 14:28:05 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: PATCH: mark_page_accessed() for read()s on non-page boundaries
Message-Id: <20041207142805.2b7517b7.akpm@osdl.org>
In-Reply-To: <1102457139l.23999l.3l@stargazer.cistron.net>
References: <20041207213819.GA32537@cistron.nl>
	<20041207135205.783860cf.akpm@osdl.org>
	<1102457139l.23999l.3l@stargazer.cistron.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miquel van Smoorenburg <miquels@cistron.nl> wrote:
>
> > --- 25/mm/readahead.c~a	Tue Dec  7 13:50:04 2004
> > +++ 25-akpm/mm/readahead.c	Tue Dec  7 13:50:58 2004
> > @@ -369,8 +369,10 @@ page_cache_readahead(struct address_spac
> >  		goto out;	/* Maximally shrunk */
> >  
> >  	max = get_max_readahead(ra);
> > -	if (max == 0)
> > +	if (max == 0) {
> > +		ra->prev_page = offset;	/* For do_generic_mapping_read() */
> >  		goto out;	/* No readahead */
> > +	}
> >  
> >  	orig_next_size = ra->next_size;
> 
> OK, got it. Will go and play with that and posix_fadvise(POSIX_FADV_RANDOM)
> some more.

It'll probably need to handle the "Maximally shrunk" case too.  But I've
locally merged some readahead rework from Steve Pratt and Ram Pai, and it
looks like the changes will be simpler in that case:

page_cache_readahead(struct address_space *mapping, struct file_ra_state *ra,
		     struct file *filp, unsigned long offset,
		     unsigned long req_size)
{
	unsigned long max, min;
	unsigned long newsize = req_size;
	unsigned long block;

	/*
	 * Here we detect the case where the application is performing
	 * sub-page sized reads.  We avoid doing extra work and bogusly
	 * perturbing the readahead window expansion logic.
	 * If size is zero, there is no read ahead window so we need one
	 */
	if (offset == ra->prev_page && req_size == 1 && ra->size != 0)
		goto out;


Still.  Work against -rc3 and I can fix stuff up.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
