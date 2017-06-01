Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 103E06B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:09:14 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so8214079wmf.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:09:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si20185398wrx.326.2017.06.01.01.09.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 01:09:12 -0700 (PDT)
Date: Thu, 1 Jun 2017 10:09:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170601080909.GD32677@dhcp22.suse.cz>
References: <c59a0893-d370-130b-5c33-d567a4621903@suse.cz>
 <20170524103947.GC3063@rapoport-lnx>
 <20170524111800.GD14733@dhcp22.suse.cz>
 <20170524142735.GF3063@rapoport-lnx>
 <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170601065302.GA30495@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601065302.GA30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu 01-06-17 09:53:02, Mike Rapoport wrote:
> On Tue, May 30, 2017 at 04:39:41PM +0200, Michal Hocko wrote:
> > On Tue 30-05-17 16:04:56, Andrea Arcangeli wrote:
> > > 
> > > UFFDIO_COPY while not being a major slowdown for sure, it's likely
> > > measurable at the microbenchmark level because it would add a
> > > enter/exit kernel to every 4k memcpy. It's not hard to imagine that as
> > > measurable. How that impacts the total precopy time I don't know, it
> > > would need to be benchmarked to be sure.
> > 
> > Yes, please!
> 
> I've run a simple test (below) that fills 1G of memory either with memcpy
> of ioctl(UFFDIO_COPY) in 4K chunks.
> The machine I used has two "Intel(R) Xeon(R) CPU E5-2680 0 @ 2.70GHz" and
> 128G of RAM.
> I've averaged elapsed time reported by /usr/bin/time over 100 runs and here
> what I've got:
> 
> memcpy with THP on: 0.3278 sec
> memcpy with THP off: 0.5295 sec
> UFFDIO_COPY: 0.44 sec

I assume that the standard deviation is small?
 
> That said, for the CRIU usecase UFFDIO_COPY seems faster that disabling THP
> and then doing memcpy.

That is a bit surprising. I didn't think that the userfault syscall
(ioctl) can be faster than a regular #PF but considering that
__mcopy_atomic bypasses the page fault path and it can be optimized for
the anon case suggests that we can save some cycles for each page and so
the cumulative savings can be visible.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
