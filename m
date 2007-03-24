Date: Fri, 23 Mar 2007 20:58:10 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-Id: <20070323205810.3860886d.akpm@linux-foundation.org>
In-Reply-To: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007 01:44:38 -0700 "Ken Chen" <kenchen@google.com> wrote:

> On 3/21/07, Adam Litke <agl@us.ibm.com> wrote:
> > The main reason I am advocating a set of pagetable_operations is to
> > enable the development of a new hugetlb interface.  During the hugetlb
> > BOFS at OLS last year, we talked about a character device that would
> > behave like /dev/zero.  Many of the people were talking about how they
> > just wanted to create MAP_PRIVATE hugetlb mappings without all the fuss
> > about the hugetlbfs filesystem.  /dev/zero is a familiar interface for
> > getting anonymous memory so bringing that model to huge pages would make
> > programming for anonymous huge pages easier.
> 
> I think we have enough infrastructure currently in hugetlbfs to
> implement what Adam wants for something like a /dev/hugetlb char
> device (except we can't afford to have a zero hugetlb page since it
> will be too costly on some arch).
> 
> I really like the idea of having something similar to /dev/zero for
> hugetlb page.  So I coded it up on top of existing hugetlbfs.  The
> core change is really small and half of the patch is really just
> moving things around.  I think this at least can partially fulfill the
> goal.

Standing back and looking at this...

afaict the whole reason for this work is to provide a quick-n-easy way to
get private mappings of hugetlb pages.  With the emphasis on quick-n-easy.

We can do the same with hugetlbfs, but that involves (horror) "fuss".

The way to avoid "fuss" is of course to do it once, do it properly then stick
it in a library which everyone uses.

But libraries are hard, for a number of distributional reasons.  It is
easier for us to distribute this functionality within the kernel.  In fact,
if Linus's tree included a ./userspace/libkernel/libhugetlb/ then we'd
probably provide this functionality in there.

This comes up regularly, and it's pretty sad.

Probably the kernel team should be maintaining, via existing processes, a
separate libkernel project, to fix these distributional problems.  The
advantage in this case is of course that our new hugetlb functionality
would be available to people on 2.6.18 kernels, not only on 2.6.22 and
later.

Am I wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
