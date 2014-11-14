Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 984106B00D3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:01:15 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so1225283wid.3
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:01:15 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id i1si1326867wiy.105.2014.11.13.17.01.14
        for <linux-mm@kvack.org>;
        Thu, 13 Nov 2014 17:01:14 -0800 (PST)
Date: Fri, 14 Nov 2014 02:58:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
Message-ID: <20141114005833.GA1572@node.dhcp.inet.fi>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
 <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
 <20141110205814.GA4186@gmail.com>
 <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
 <20141110225036.GB4186@gmail.com>
 <CA+55aFyfgj5ntoXEJeTZyGdOZ9_A_TK0fwt1px_FUhemXGgr0Q@mail.gmail.com>
 <CA+55aFxYnBxGZr3ed0i46SpSdOj+3VSVBZiqRbdJuwFMuTmxDw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxYnBxGZr3ed0i46SpSdOj+3VSVBZiqRbdJuwFMuTmxDw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Nov 13, 2014 at 03:50:02PM -0800, Linus Torvalds wrote:
> +/*
> + * The 'tree_level' data only describes one particular level
> + * of the tree. The upper levels are totally invisible to the
> + * user of the tree walker, since the tree walker will walk
> + * those using the tree definitions.
> + *
> + * NOTE! "struct tree_entry" is an opaque type, and is just a
> + * used as a pointer to the particular level. You can figure
> + * out which level you are at by looking at the "tree_level",
> + * but even better is to just use different "lookup()"
> + * functions for different levels, at which point the
> + * function is inherent to the level.

Please, don't.

We will end up with the same last-level centric code as we have now in mm
subsystem: all code only cares about pte. It makes implementing variable
page size support really hard and lead to copy-paste approach. And to
hugetlb parallel world...

It would be nice to have tree_level description generic enough to get rid
of pte_present()/pte_dirty()/pte_* and implement generic helpers instead.

Apart from variable page size problem, we could get one day support
different CPU page table format supported in runtime: PAE/non-PAE on
32-bit x86 or LPAE/non-LPAE on ARM in one binary kernel image.

The big topic is how to get it done without significant runtime cost :-/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
