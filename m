Subject: Re: [PATCH 2/5] hugetlb: Fix quota management for private mappings
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0710311033160.21194@schroedinger.engr.sgi.com>
References: <20071030204554.16585.80588.stgit@kernel>
	 <20071030204615.16585.60817.stgit@kernel>
	 <20071030162219.511394fb.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0710301626580.16022@schroedinger.engr.sgi.com>
	 <1193842481.18417.133.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0710311033160.21194@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 11:25:22 -0700
Message-Id: <1193855122.6271.18.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@kvack.org, kenchen@google.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 10:33 -0700, Christoph Lameter wrote:
> On Wed, 31 Oct 2007, Adam Litke wrote:
> 
> > > The private pointer in the first page of a compound page is always 
> > > available. However, why do we not use page->mapping for that purpose? 
> > > Could we stay as close as possible to regular page cache field use?
> > 
> > There is an additional problem I forgot to mention in the previous mail.
> > The remove_from_page_cache() call path clears page->mapping.  This means
> > that if the free_huge_page destructor is called on a previously shared
> > page, we will not have the needed information to release quota.  Perhaps
> > this is a further indication that use of page->mapping at this level is
> > inappropriate. 
> 
> How does quota handle that for regular pages? Can you update the quotas 
> before the page is released?

It should happen for normal pages at truncate time, which happens when
i_nlink hits zero.  We also truncate these a whole file at a time.

I think the hugetlbfs problem is that we want to release pages at unmap
(and thus put_page()) time.  If we have an unlinked hugetlbfs file which
has 100 huge pages in it, but only a single huge page still mapped, we
probably don't want to wait around to free those hundred pages waiting
for that last user..  That's for the private pages because their last
ref is always from the ptes.

Shared should be a different matter because that ref comes from the page
cache (generally, I guess).

So, hugetlbfs has a need to release pages _earlier_ in the process than
a normal page, at least for private mappings.  The complication comes
because the private mappings really aren't file-backed in the sense that
they don't have entries in any address_space, but we still need
file-like inode operations on them.  Gah.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
