Date: Mon, 8 May 2006 22:41:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/2] tracking dirty pages in shared mappings -V3
In-Reply-To: <1147116034.16600.2.camel@lappy>
Message-ID: <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>  <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy>  <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy>  <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 May 2006, Peter Zijlstra wrote:

> @@ -2077,6 +2078,7 @@ static int do_no_page(struct mm_struct *
>  	unsigned int sequence = 0;
>  	int ret = VM_FAULT_MINOR;
>  	int anon = 0;
> +	int dirty = 0;
	dirtied_page = NULL ?

> @@ -2150,6 +2152,11 @@ retry:
>  		entry = mk_pte(new_page, vma->vm_page_prot);
>  		if (write_access)
>  			entry = maybe_mkwrite(pte_mkdirty(entry), vma);

A write fault to a shared mapping does not make the page dirty, just the 
pte?

>  			inc_mm_counter(mm, file_rss);
>  			page_add_file_rmap(new_page);
> +			if (write_access) {
> +				get_page(new_page);
> +				dirty++;
				dirtied_page = new_page; ?
				get_page(dirtied_page); ?

> +	if (dirty) {
> +		set_page_dirty(new_page);
> +		put_page(new_page);
> +	}

if (dirtied_page)
		set_page_dirty(dirtied_page);
		put_page(dirtied_page)
?

> @@ -2235,6 +2250,7 @@ static inline int handle_pte_fault(struc
>  	pte_t entry;
>  	pte_t old_entry;
>  	spinlock_t *ptl;
> +	struct page *page = NULL;
use dirtied_page instead to make it the same as the other function?

> +int page_wrprotect(struct page *page)

The above and related functions look similar to code in 
rmap.c and migrate.c. Could those be consolidated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
