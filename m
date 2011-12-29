Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 7DEBE6B004D
	for <linux-mm@kvack.org>; Thu, 29 Dec 2011 12:07:51 -0500 (EST)
Received: by iacb35 with SMTP id b35so28719478iac.14
        for <linux-mm@kvack.org>; Thu, 29 Dec 2011 09:07:50 -0800 (PST)
Date: Thu, 29 Dec 2011 09:07:45 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: memblock and bootmem problems if start + size = 4GB
Message-ID: <20111229170745.GE3516@google.com>
References: <4EEF42F5.7040002@monstr.eu>
 <20111219162835.GA24519@google.com>
 <4EF05316.5050803@monstr.eu>
 <20111229155836.GB3516@google.com>
 <4EFC995A.5090904@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EFC995A.5090904@monstr.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yinghai Lu <yinghai@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Sam Ravnborg <sam@ravnborg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello,

On Thu, Dec 29, 2011 at 05:46:18PM +0100, Michal Simek wrote:
> First of all I don't like to use your term "extend range coverages".
> We don't want to extend any ranges - we just wanted to place memory to the end
> of address space and be able to work with.

It is, as long as we use address ranges.  Either we can express length
of zero or include the last address.

> It is limitation which should be fixed somehow.
> And I would expect that PFN_XX(base + size) will be in u32 range.
>
> Probably the best solution will be to use PFN macro in one place and
> do not covert addresses in common code.
> 
> + change parameters in bootmem code because some arch do
> free_bootmem_node(..., PFN_PHYS(), ...)
> and
> reserve_bootmem_node(..., PFN_PHYS(), ...)

So now we're talking about a lot of code just for ONE page and
regardless of the representation in the memblock or other memory
management code, I think trying to use that page is fundamentally a
bad idea.  There are a lot of places in the kernel where phys_addr_t
is used.  Using that one last page risks obscure overflow bug if any
of them is using [start,end) ranges and bugs triggered such way would
be extremely difficult to track down.  It doesn't make any sense to do
that for that one last page.  It's less severe but in the same vein as
trying to use %NULL as a valid address.  It's an absurdly silly
tradeoff.

So, FWIW, I think that is a horrible idea.

> >  On
> >extreme cases, people even carry separate valid flag to use %NULL as
> >valid address, which is pretty silly, IMHO.  So, unless there's some
> >benefit that I'm missing, I still think it's an overkill.  It's more
> >complex and difficult to test and verify.  Why bother for a single
> >page?
> 
> Where do you think this page should be placed? In common code or in architecture memory
> code where one page from the top of 4G should be subtract?

With the pending updates to memblock code in tip scheduled for the
coming merge window, I *think* it would be a single (or a few) line
change in memblock_add_region() where it checks for overflow.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
