Subject: Re: [PATCH]Fix: Init page count for all pages during higher order allocs
References: <20020429202446.A2326@in.ibm.com>
	<m1r8ky1jzu.fsf@frodo.biederman.org> <20020430110108.A1275@in.ibm.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 30 Apr 2002 08:05:58 -0600
In-Reply-To: <20020430110108.A1275@in.ibm.com>
Message-ID: <m1it691dtl.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: suparna@in.ibm.com
Cc: linux-kernel@vger.kernel.org, marcelo@brutus.conectiva.com.br, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Suparna Bhattacharya <suparna@in.ibm.com> writes:

> On Mon, Apr 29, 2002 at 11:40:21AM -0600, Eric W. Biederman wrote:
> > Suparna Bhattacharya <suparna@in.ibm.com> writes:
> > 
> > > The call to set_page_count(page, 1) in page_alloc.c appears to happen 
> > > only for the first page, for order 1 and higher allocations.
> > > This leaves the count for the rest of the pages in that block 
> > > uninitialised.
> > 
> > Actually it should be zero.
> > 
> > This is deliberate because high order pages should not be referenced by
> > their partial pages.  
> 
> That sounds reasonable provided there is a way to identify the main 
> page struct corresponding to an area that's part of a higher 
> order page. 

Reasonable.  For a crash dump you are doing a physical scan through
the struct pages correct?

Actually I have a stupid question.  Given the fact that the kernel keeps
most pages in active use why is it worth checking for which pages are not
used?
 
> > It might make sense to add a PG_large flag and
> > then in the immediately following struct page add a pointer to the next
> > page, so you can identify these pages by inspection.  Doing something
> > similar to the PG_skip flag.
> 
> Maybe different solutions could emerge for this in 2.4 and 2.5. 
> 
> Even a PG_partial flag for the partial pages will enable us to
> traverse back to the main page, and vice-versa to determine the
> partial pages covered by the main page, without any additional
> pointers. Is that an acceptable option for 2.4 ? (That's one
> more page flag ...)
> 
> It would be good to have a way to determine the order directly
> from the page struct, without such traversals, at least in 2.5. 

It is important the page struct be kept small.  Especially for very rarely
used features.  I can see dedicating a bit that says get all of the information
out of the next struct page that is totally unused.  And as part of freeing
the page the first thing we do is clear that bit.  But I can't see a justification
for putting any more in the primary struct page.

> > 
> > Beyond that I get nervous, that people will treat it as endorsement of
> > doing a high order continuous allocation and then fragmenting the page.
> 
> I don't think it would amount to such an endorsement. It's just a matter
> of replicating the settings from the main page to the partial pages - 
> which might be considered an alternate protocol, though a little 
> inefficient for really high orders. However, having the partial page 
> counts zeroed out probably helps as a safeguard in some situations in
> view of the page count sanity checks. Or are there any scenarios where 
> you forsee a problem/breakage ?

Using the count on the unused page structs implies you can use them
independently.  The page count is only accurate on the initial page
struct.  The one that is used.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
