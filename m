Subject: Re: Query on remap_pfn_range compatibility
Message-ID: <OF0A92B996.F674A9A0-ON86256F93.0066BC3F@raytheon.com>
From: Mark_H_Johnson@raytheon.com
Date: Mon, 24 Jan 2005 13:05:44 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

wli wrote...
> On Mon, Jan 24, 2005 at 10:54:22AM -0600, Mark_H_Johnson@raytheon.com
wrote:
> > I read the messages on lkml from September 2004 about the introduction
of
> > remap_pfn_range and have a question related to coding for it. What do
you
> > recommend for driver coding to be compatible with these functions
> > (remap_page_range, remap_pfn_range)?
> > For example, I see at least two (or three) combination I need to
address:
> >  - 2.4 (with remap_page_range) OR 2.6.x (with remap_page_range)
> >  - 2.6.x-mm (with remap_pfn_range)
> > Is there some symbol or #ifdef value I can depend on to determine which
> > function I should be calling (and the value to pass in)?
>
> Not sure. One on kernel version being <= 2.6.10 would probably serve
> your purposes, though it's not particularly well thought of. I suspect
> people would suggest splitting up the codebase instead of sharing it
> between 2.4.x and 2.6.x, where I've no idea how well that sits with you.

I guess I could do that, but if a distribution picks up remap_pfn_range
in an earlier kernel, that doesn't work either. If it gets back ported
to 2.4 the conditional gets a little more complicated.

Splitting the code base is a pretty harsh solution.

I am also trying to avoid an ugly hack like the following:

  VMA_PARAM_IN_REMAP=`grep remap_page_range
$PATH_LINUX_INCLUDE/linux/mm.h|grep vma`
  if [ -z "$VMA_PARAM_IN_REMAP" ]; then
    export REMAP_PAGE_RANGE_PARAM="4"
  else
    export REMAP_PAGE_RANGE_PARAM="5"
  endif

in a build script which detects if remap_page_range() has 4 or 5 parameters
and then pass an appropriate value into the code using gcc -D. [ugh]

Would it be acceptable to add a symbol like
  #define MM_VM_REMAP_PFN_RANGE
in include/linux/mm.h or is that too much of a hack as well?

> I vaguely suspected something like this would happen, but there were
> serious and legitimate concerns about new usage of the 32-bit unsafe
> methods being reintroduced, so at some point the old hook had to go.
I don't doubt the need to remove the old interface. But I see possible
problem areas on > 4 Gbyte machines, such as virt_to_phys defined in
linux/asm-i386/io.h, that are not getting fixed or do I misread the
way that code works.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
