Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2LLikRV020917
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 16:44:46 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2LLfcPM251166
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 14:41:46 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k2LLicPS023557
	for <linux-mm@kvack.org>; Tue, 21 Mar 2006 14:44:38 -0700
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through
	"/proc/meminfo: Wired"
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 21 Mar 2006 13:43:12 -0800
Message-Id: <1142977393.10906.204.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-03-20 at 08:37 -0500, Stone Wang wrote:
> --- linux-2.6.15.orig/include/linux/mm.h        2006-01-02 22:21:10.000000000 -0500
> +++ linux-2.6.15/include/linux/mm.h     2006-03-07 01:49:12.000000000 -0500
> @@ -218,6 +221,10 @@
>         unsigned long flags;            /* Atomic flags, some possibly
>                                          * updated asynchronously */
>         atomic_t _count;                /* Usage count, see below. */
> +       unsigned short wired_count; /* Count of wirings of the page.
> +                                        * If not zero,the page would be SetPageWired,
> +                                        * and put on Wired list of the zone.
> +                                        */
>         atomic_t _mapcount;             /* Count of ptes mapped in mms,
>                                          * to show when page is mapped
>                                          * & limit reverse map searches. 

We're usually pretty picky about adding stuff to 'struct page'.  It
_just_ fits inside a cacheline on most 32-bit architectures.  

Can this wired_count not be derived at runtime?  It seems like it would
be possible to run through all VMAs mapping the page, and determining
how many of them are VM_LOCKED.  Would that be too slow?

Also, does it matter how many times it is locked, or just that
_somebody_ has it locked?  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
