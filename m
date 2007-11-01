Subject: Re: Interesting Bug in page migration via mbind()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710311406570.22599@schroedinger.engr.sgi.com>
References: <1193863506.5299.139.camel@localhost>
	 <Pine.LNX.4.64.0710311406570.22599@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 01 Nov 2007 12:46:24 -0400
Message-Id: <1193935584.5300.68.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 14:07 -0700, Christoph Lameter wrote:
> On Wed, 31 Oct 2007, Lee Schermerhorn wrote:
> 
> > How to address?
> 
> Looks like we are not updating the vma information correctly when 
> splitting vmas?

Update:  error path is [NOT try_to_unmap()...]:

do_mbind()->migrate_pages()->unmap_and_move()=>new_vma_page()
->page_address_in_vma()->vma_address()

do_mbind() passes the first vma of the range to migrate_pages() via the
'void * private' argument.  This vma is passed to page_address_in_vma().
However, the pages in the page list to be migrated can come from
multiple vmas.  

I have an idea for a patch:

We need to pass a valid vma--i.e., one that actually maps the page--to
vma_address().  In new_vma_page(), fetch page_address_in_vma().  If
returns EFAULT,  "find the vma that maps page".  How?  Couple of
options:

1) start by assuming that it's a later vma in the vm_next list--probably
the very next one--and try subsequent vmas in a loop.  It may not be the
very next vma if none of the pages in that vma are migratable.  But,
this method should work.

2) call into rmap.c--some new function?--to look up vma based on page's
index--the way try_to_unmap_file() does.  Sounds heavier weight to me,
so I'll start with option 1 and see what it looks like.

Will send shortly, if I get to it today.  Else, after the weekend.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
