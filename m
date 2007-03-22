Date: Thu, 22 Mar 2007 10:38:17 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: pagetable_ops: Hugetlb character device example
Message-ID: <20070322103817.GA7348@infradead.org>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <1174506228.21684.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1174506228.21684.41.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 21, 2007 at 02:43:48PM -0500, Adam Litke wrote:
> The main reason I am advocating a set of pagetable_operations is to
> enable the development of a new hugetlb interface.  During the hugetlb
> BOFS at OLS last year, we talked about a character device that would
> behave like /dev/zero.  Many of the people were talking about how they
> just wanted to create MAP_PRIVATE hugetlb mappings without all the fuss
> about the hugetlbfs filesystem.  /dev/zero is a familiar interface for
> getting anonymous memory so bringing that model to huge pages would make
> programming for anonymous huge pages easier.

That is a very laudable goal, but an utterly wrong way to get there.
Despite Linus' veto a while ago what we really want is support for transparent
super pages.  Adding random pointer indirections where we had the direct
hugetlb calls before isn't helpful for that at all.  As a start you might
want to make a clear destinction between core hugetlb code and the
filesystem interface to it without all the useless indirections.  That
should get you as far as your char dev interface.  But over the long
term the core VM needs to deal with multiple (and probably not just two)
page sizes.  Given that the code to deal with different sized pages is
essentially the same just on different units on most architectures cries
for a better method to implement this than adding random function indirection
that point to mostly identical code.


And your driver is the best example of why we utterly don't want
a page_table operations interface.  The last thing we want is random
driver taking over core VM functionality.  The right way would be to a
filesystem/driver to tell (or maybe just give hints) which page size
to use for this mapping.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
