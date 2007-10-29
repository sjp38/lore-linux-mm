From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
Date: Tue, 30 Oct 2007 01:28:24 +1100
References: <1193064057.16541.1.camel@matrix> <1193652717.27652.45.camel@twins> <1193661308.27652.47.camel@twins>
In-Reply-To: <1193661308.27652.47.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710300128.25167.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jaya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 29 October 2007 23:35, Peter Zijlstra wrote:
> On Mon, 2007-10-29 at 11:11 +0100, Peter Zijlstra wrote:
> > On Mon, 2007-10-29 at 01:17 -0700, Jaya Kumar wrote:
> > > On 10/29/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > > On Mon, 22 Oct 2007 16:40:57 +0200 Stefani Seibold 
<stefani@seibold.net> wrote:
> > > > > The problem original occurs with the fb_defio driver
> > > > > (driver/video/fb_defio.c). This driver use the
> > > > > vm_ops.page_mkwrite() handler for tracking the modified pages,
> > > > > which will be in an extra thread handled, to perform the IO and
> > > > > clean and write protect all pages with page_clean().
> > >
> > > Hi,
> > >
> > > An aside, I just tested that deferred IO works fine on
> > > 2.6.22.10/pxa255.
> > >
> > > I understood from the thread that PeterZ is looking into page_mkclean
> > > changes which I guess went into 2.6.23. I'm also happy to help in any
> > > way if the way we're doing fb_defio needs to change.
> >
> > Yeah, its the truncate race stuff introduced by Nick in
> >   d0217ac04ca6591841e5665f518e38064f4e65bd
> >
> > I'm a bit at a loss on how to go around fixing this. One ugly idea I had
> > was to check page->mapping before going into page_mkwrite() and when
> > that is null, don't bother with the truncate check.
>
> Something like this


I think it's a fine minimal patch. Maybe add a comment to say exactly
what we're doing here (pagecache generally just uses !mapping to test
for truncate).

Otherwise, Acked-by: Nick Piggin <npiggin@suse.de>, thanks!

> ---
>  mm/memory.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -2300,6 +2300,8 @@ static int __do_fault(struct mm_struct *
>  			 * to become writable
>  			 */
>  			if (vma->vm_ops->page_mkwrite) {
> +				struct address_space *mapping = page->mapping;
> +
>  				unlock_page(page);
>  				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
>  					ret = VM_FAULT_SIGBUS;
> @@ -2314,7 +2316,7 @@ static int __do_fault(struct mm_struct *
>  				 * reworking page_mkwrite locking API, which
>  				 * is better done later.
>  				 */
> -				if (!page->mapping) {
> +				if (mapping != page->mapping) {
>  					ret = 0;
>  					anon = 1; /* no anon but release vmf.page */
>  					goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
