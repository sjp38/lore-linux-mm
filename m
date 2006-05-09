Subject: Re: [RFC][PATCH 1/2] tracking dirty pages in shared mappings -V3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
	 <1147116034.16600.2.camel@lappy>
	 <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 09 May 2006 08:06:21 +0200
Message-Id: <1147154781.7782.5.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-05-08 at 22:41 -0700, Christoph Lameter wrote:
> On Mon, 8 May 2006, Peter Zijlstra wrote:
> 
> > @@ -2077,6 +2078,7 @@ static int do_no_page(struct mm_struct *
> >  	unsigned int sequence = 0;
> >  	int ret = VM_FAULT_MINOR;
> >  	int anon = 0;
> > +	int dirty = 0;
> 	dirtied_page = NULL ?

Much nicer indeed!

> > @@ -2150,6 +2152,11 @@ retry:
> >  		entry = mk_pte(new_page, vma->vm_page_prot);
> >  		if (write_access)
> >  			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> 
> A write fault to a shared mapping does not make the page dirty, just the 
> pte?

We do that here:

> >  			inc_mm_counter(mm, file_rss);
> >  			page_add_file_rmap(new_page);
> > +			if (write_access) {
> > +				get_page(new_page);
> > +				dirty++;



> > +int page_wrprotect(struct page *page)
> 
> The above and related functions look similar to code in 
> rmap.c and migrate.c. Could those be consolidated?

I'll have a look.

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
