Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3F45C829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 16:31:58 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so27682543wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 13:31:57 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id d7si6924691wij.93.2015.05.22.13.31.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 13:31:55 -0700 (PDT)
Received: by wicmc15 with SMTP id mc15so409684wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 13:31:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1430231830-7702-4-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<1430231830-7702-4-git-send-email-mgorman@suse.de>
Date: Fri, 22 May 2015 13:31:55 -0700
Message-ID: <CA+8MBb+BJSdo6bPFYw1S_ej1-Sp7AEOWVp1V6eXch63B4fG59g@mail.gmail.com>
Subject: Re: [PATCH 03/13] mm: meminit: Only set page reserved in the memblock region
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 28, 2015 at 7:37 AM, Mel Gorman <mgorman@suse.de> wrote:
> Currently each page struct is set as reserved upon initialization.
> This patch leaves the reserved bit clear and only sets the reserved bit
> when it is known the memory was allocated by the bootmem allocator. This
> makes it easier to distinguish between uninitialised struct pages and
> reserved struct pages in later patches.

On ia64 my linux-next builds now report a bunch of messages like this:

put_kernel_page: page at 0xe000000005588000 not in reserved memory
put_kernel_page: page at 0xe000000005588000 not in reserved memory
put_kernel_page: page at 0xe000000005580000 not in reserved memory
put_kernel_page: page at 0xe000000005580000 not in reserved memory
put_kernel_page: page at 0xe000000005580000 not in reserved memory
put_kernel_page: page at 0xe000000005580000 not in reserved memory

the two different pages match up with two objects from the loaded kernel
that get mapped by arch/ia64/mm/init.c:setup_gate()

a000000101588000 D __start_gate_section
a000000101580000 D empty_zero_page

Should I look for a place to set the reserved bit on page structures for these
addresses? Or just remove the test and message in put_kernel_page()
[I added a debug "else" clause here - every caller passes in a page that is
not reserved]

        if (!PageReserved(page))
                printk(KERN_ERR "put_kernel_page: page at 0x%p not in
reserved memory\n",
                       page_address(page));

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
