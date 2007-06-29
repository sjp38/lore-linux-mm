Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200706290002.12113.ak@suse.de>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	 <200706280001.16383.ak@suse.de> <1183038137.5697.16.camel@localhost>
	 <200706290002.12113.ak@suse.de>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 13:14:17 -0400
Message-Id: <1183137257.5012.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-29 at 00:02 +0200, Andi Kleen wrote:
> 
> > -	return __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> > +	page =  __alloc_pages(gfp, 0, zonelist_policy(gfp, pol));
> > +	if (pol != &default_policy && pol != current->mempolicy)
> > +		__mpol_free(pol);
> 
> That destroyed the tail call in the fast path. I would prefer if it
> was preserved at least for the default_policy case. This means handling
> this in a separated if path.

Andi:  I could restore the tail call for the common cases of system
default and task policy, but that would require a second call to
__alloc_pages(), I think, for the shared and vma policies.  What do you
think about that solution?

> 
> Other than that it looks reasonable and we probably want something
> like this for .22.

As Christoph notes, this will have to extracted from my series. I think
that only get_vma_policy() and alloc_page_vma() need to change for now.
I won't get a chance to test anything until the 2nd week in July and
that might be too late for .22.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
