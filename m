Date: Wed, 4 Mar 1998 21:26:18 GMT
Message-Id: <199803042126.VAA01736@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: reverse pte lookups and anonymous private mappings; avl trees?
In-Reply-To: <Pine.LNX.3.95.980302235716.8007A-100000@as200.spellcast.com>
References: <199803022303.XAA03640@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.95.980302235716.8007A-100000@as200.spellcast.com>
Sender: owner-linux-mm@kvack.org
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi,

Another observation on the subject of new page lists.

You suggested adding:

> +	/* used for private mappings -> inode == NULL or &swapper_inode */
> +	struct vm_area_struct *vma;
> +	unsigned long vma_offset;
> +
> +	/* page on one of the circular page_queues */
> +	struct page *pgq_next;
> +	struct page *pgq_prev;

to the struct page.  However, note that the vma and vma_offset fields
are irrelevant to pages which are not mapped (the fields can be
initialised on first map, and a page which is purely in the page or swap
cache is not attached to any particular vma and so doesn't need these
lookups).  Detecting such unmapped pages reliably may require separate
unmapped and mapped page counts.

Given this, can we not over load the two new fields and reduce the
expansion of the struct page?  The answer is yes, if and only if we
restrict the new page queues to unmapped pages.  For my own code, the
only queue which is really necessary is the list of pages ready to be
reclaimed at interrupt time, and those pages will never be mapped.  The
other queues you mention:

> +#define PgQ_Locked	0	/* page is unswappable - mlock()'d */
> +#define PgQ_Active	1	/* page is mapped and active -> young */
> +#define PgQ_Inactive	2	/* page is mapped, but hasn't been referenced recently -> old */
> +#define PgQ_Swappable	3	/* page has no mappings, is dirty */
> +#define PgQ_Swapping	4	/* page is being swapped */
> +#define PgQ_Dumpable	5	/* page has no mappings, is not dirty, but is still in the page cache */

don't seem to give us all that much extra, since we probably never want
to go out and explicitly search for all pages on such lists.  (That's
assuming that the page aging and swapping scanner is working by walking
pages in physical address order, not by traversing any other lists.)

Other than that, I like this idea more and more.  Overloading these two
sets of fields gives us huge extra functionality over the 2.0 vm, and at
the cost of only one extra longword per page.

Cheers,
 Stephen.
