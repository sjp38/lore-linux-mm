Date: Thu, 3 Apr 2003 00:59:09 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
In-Reply-To: <110950000.1049326945@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0304030053240.1279-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Apr 2003, Dave McCracken wrote:
> --On Wednesday, April 02, 2003 15:38:45 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> 
> > But:
> > 
> > +	/* Double check to make sure the pte page hasn't been freed */
> > +	if (!pmd_present(*pmd))
> > +		goto out_unmap;
> > +
> > 	==> munmap, pte page is freed, reallocated for pagecache, someone
> > 	    happens to write the correct value into it.
> > 	
> > +	if (page_to_pfn(page) != pte_pfn(*pte))
> > +		goto out_unmap;
> > +
> > +	if (addr)
> > +		*addr = address;
> > +
> 
> Oops.  The pmd_present() check should be after the page_to_pfn() !=
> pte_pfn() check.

No, you're forgetting that the case Andrew rightly indicates is
covered by the ptecount check I added to page_convert_anon, and
commented at length there.  As I said yesterday, I don't think
this "Double check" on *pmd serves any real purpose as coded
(whereas the earlier "Double check" on *pgd is vital).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
