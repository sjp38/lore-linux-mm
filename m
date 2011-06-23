Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E1A2A900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:10:51 -0400 (EDT)
Date: Thu, 23 Jun 2011 10:10:44 +0000
From: Rick van Rein <rick@vanrein.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110623101044.GA2910@phantom.vanrein.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110622110034.89ee399c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

Hello,

> > The concerning pages are then marked with the hwpoison flag and thus won't be
> > used by the memory managment system.
> 
> The google kernel has a similar capability.  I asked Nancy to comment
> on these patches and she said:
> 
> : One, the bad addresses are passed via the kernel command line, which
> : has a limited length.  It's okay if the addresses can be fit into a
> : pattern, but that's not necessarily the case in the google kernel.

They are guaranteed to fit in 5 patterns (and even that is a choice).
The BadRAM pattern printing option built into Memtest86 will never
create more than that.  If your memory is really screwed, it will
simply make patterns so generic that at least all the faults are
covered.

The figure 5 is a bit arbitrary, but was chosen in a time that we all
used LILO and had to live with its limited cmdline length.  GRUB is
more relaxed in that respect, but there has never been a need to go
beyond five.  Most errors are regular patterns (because an entire row,
or an entire column is damaged if not just a single cell is affected)
that will fit into a limited number of patterns without a need for so
many.

> : And
> : even with patterns, the limit on the command line length limits the
> : number of patterns that user can specify.  Instead we use lilo to pass
> : a file containing the bad pages in e820 format to the kernel.

I've looked into the aproach of e820 and actually turned away from it.
The e820 format does not permit to specify the regularity that comes
with real-life memory problems.  Having made the BadRAM patch, I've seen
numerous examples, and they all came down to single-cell errors and
either one or more rows and/or one or more columns of cells.  There has
never been a reporting of such erratic destruction that it could not
comfortably (that is, with minimal pages sacrificed) fit in the limit
of 5 patterns that Memtest86 (not BadRAM) imposes.  I'm pretty sure I
would have heard about it if there had been any such problems, given
the interactivity of people who had gone through all the effort of
patching a kernel.  Kernel patchers are not usually the silent kind
when it comes to an opportunity to improve Linux ;-)

> : Second, the BadRAM patch expands the address patterns from the command
> : line into individual entries in the kernel's e820 table.  The e820
> : table is a fixed buffer [...]

This is not how BadRAM works -- it will set a page flag for defected
pages in Linux' page table.  It does this before getting to the stage
where all pages are initially 'freed' into the memory pool, and can
thus avoid that damaged pages are ever released for allocation.

> : We require a much larger number of entries (on
> : the order of a few thousand), so much of the google kernel patch deals
> : with expanding the e820 table.

Interesting.  I have made a deliberate choice not to go that way,
but that was because we were looking at e820 as a communications
mechanism between a BadRAM-supportive GRUB and the kernel.  The
advantage of that would have been to do it before the kernel.

Indeed, if you take this route you will see a severe expansion of the
e820 table.  A damaged row (or column) does indeed lead to 4096 or so
error spots, that is quite common.

I'd like to know -- are the pages with faults that you have not also
organised in a regular pattern, which is what BadRAM addresses?  If
not, that would be a strongly countering argument for the
pattern-based approach of BadRAM, but I would be really surprised if
one or two patterns (or up to five) could not comfortably describe
the error patterns -- as they were designed to match how memory
hardware actually work.

Also, if you find 4093 error pages, you would not generalise it to
a 4096 page error, right?  I would not feel comfortable in that
case.

> : Also, with the BadRAM patch, entries
> : that don't fit in the table are silently dropped and this isn't
> : appropriate for us.

The e820 page is not used, so nothing is silently dropped.  BadRAM
would rather err at the expense of a few pages than miss an opportunity
to fix a problem.  There's nothing Google-specific about that wish :-)

> : Another caveat of mapping out too much bad memory in general.

Never seen that, or heard complaints about it, in over 10 years.  Do
you have examples on the contrary, or is this merely a concern?

> : If too
> : much memory is removed from low memory, a system may not boot.  We
> : solve this by generating good maps.  Our userspace tools do not map out
> : memory below a certain limit, and it verifies against a system's iomap
> : that only addresses from memory is mapped out.

I've seen rare occasions where a system could not be helped due to a
bug in the low parts of memory, indeed.  Maybe 1 or 2 cases in >10 years.

> - If this patchset is merged and a major user such as google is
>   unable to use it and has to continue to carry a separate patch then
>   that's a regrettable situation for the upstream kernel.

First, I wonder if there is any conflict at all.  If someone wanted
to use their own local approach, such as one based on e820 tables, I
don't think there would be any interference?

But I doubt that Google's requirements are that different from those of
other users.  BadRAM adds a layer of abstraction, but this is not an
office worker's abstraction -- instead it reflects the structures of
hardware, leading to the BadRAM pattern abstraction.  I really believe
that Google would be able to work easily with the BadRAM patch if it
was in conflict with their e820-based approach.

> - Google's is, afaik, the largest use case we know of: zillions of
>   machines for a number of years.  And this real-world experience tells
>   us that the badram patchset has shortcomings.  Shortcomings which we
>   can expect other users to experience.

Please, do show examples and figures of how common they are if you have
anything concrete to counter the pattern-based approach.  I am eager
to learn if my experience with a diverse set of individual cases for over
a decade has any shortcomings.


Best wishes,
 -Rick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
