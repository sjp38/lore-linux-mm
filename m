Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE386B012C
	for <linux-mm@kvack.org>; Tue, 26 May 2015 06:22:27 -0400 (EDT)
Received: by wizk4 with SMTP id k4so71923282wiz.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 03:22:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pz10si23037236wjc.109.2015.05.26.03.22.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 May 2015 03:22:25 -0700 (PDT)
Date: Tue, 26 May 2015 11:22:19 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/13] mm: meminit: Only set page reserved in the
 memblock region
Message-ID: <20150526102219.GB13750@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-4-git-send-email-mgorman@suse.de>
 <CA+8MBb+BJSdo6bPFYw1S_ej1-Sp7AEOWVp1V6eXch63B4fG59g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+8MBb+BJSdo6bPFYw1S_ej1-Sp7AEOWVp1V6eXch63B4fG59g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 22, 2015 at 01:31:55PM -0700, Tony Luck wrote:
> On Tue, Apr 28, 2015 at 7:37 AM, Mel Gorman <mgorman@suse.de> wrote:
> > Currently each page struct is set as reserved upon initialization.
> > This patch leaves the reserved bit clear and only sets the reserved bit
> > when it is known the memory was allocated by the bootmem allocator. This
> > makes it easier to distinguish between uninitialised struct pages and
> > reserved struct pages in later patches.
> 
> On ia64 my linux-next builds now report a bunch of messages like this:
> 
> put_kernel_page: page at 0xe000000005588000 not in reserved memory
> put_kernel_page: page at 0xe000000005588000 not in reserved memory
> put_kernel_page: page at 0xe000000005580000 not in reserved memory
> put_kernel_page: page at 0xe000000005580000 not in reserved memory
> put_kernel_page: page at 0xe000000005580000 not in reserved memory
> put_kernel_page: page at 0xe000000005580000 not in reserved memory
> 
> the two different pages match up with two objects from the loaded kernel
> that get mapped by arch/ia64/mm/init.c:setup_gate()
> 
> a000000101588000 D __start_gate_section
> a000000101580000 D empty_zero_page
> 
> Should I look for a place to set the reserved bit on page structures for these
> addresses?

That would be preferred.

> Or just remove the test and message in put_kernel_page()
> [I added a debug "else" clause here - every caller passes in a page that is
> not reserved]
> 
>         if (!PageReserved(page))
>                 printk(KERN_ERR "put_kernel_page: page at 0x%p not in
> reserved memory\n",
>                        page_address(page));
> 

But as it's a debugging check that is ia-64 specific I think either
should be fine.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
