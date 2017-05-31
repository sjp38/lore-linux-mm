Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 387336B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 10:32:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so3195812wmf.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 07:32:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i201si20260947wmd.25.2017.05.31.07.32.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 07:32:19 -0700 (PDT)
Date: Wed, 31 May 2017 16:32:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170531143216.GR27783@dhcp22.suse.cz>
References: <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530154326.GB8412@redhat.com>
 <20170531120822.GL27783@dhcp22.suse.cz>
 <8FA5E4C2-D289-4AF5-AA09-6C199E58F9A5@linux.vnet.ibm.com>
 <20170531141809.GB302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531141809.GB302@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Rapoprt <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 31-05-17 16:18:09, Andrea Arcangeli wrote:
> On Wed, May 31, 2017 at 03:39:22PM +0300, Mike Rapoport wrote:
> > For the CRIU usecase, disabling THP for a while and re-enabling it
> > back will do the trick, provided VMAs flags are not affected, like
> > in the patch you've sent.  Moreover, we may even get away with
> 
> Are you going to check uname -r to know when the kABI changed in your
> favor (so CRIU cannot ever work with enterprise backports unless you
> expand the uname -r coverage), or how do you know the patch is
> applied?

I would assume such a patch would be backported to stable trees because
to me it sounds like the current semantic is simply broken and needs
fixing anyway but it shouldn't be much different from any other bugs.

This is far from ideal from the "guarantee POV" of course.

> Optimistically assuming people is going to run new CRIU code only on
> new kernels looks very risky, it would leads to silent random memory
> corruption, so I doubt you can get away without a uname -r check.
> 
> This is fairly simple change too, its main cons is that it adds a
> branch to the page fault fast path, the old behavior of the prctl and
> the new madvise were both zero cost.
> 
> Still if the prctl is preferred despite the added branch, to avoid
> uname -r clashes, to me it sounds better to add a new prctl ID and
> keep the old one too. The old one could be implemented the same way as
> the new one if you want to save a few bytes of .text. But the old one
> should probably do a printk_once to print a deprecation warning so the
> old ID with weaker (zero runtime cost) semantics can be removed later.

this would be an option as well although it adds to the mess...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
