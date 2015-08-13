Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D68CC6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 01:11:18 -0400 (EDT)
Received: by pawu10 with SMTP id u10so29797172paw.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:11:18 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com. [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id yd1si1771861pab.194.2015.08.12.22.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 22:11:17 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so15029003pdr.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 22:11:17 -0700 (PDT)
Date: Wed, 12 Aug 2015 22:10:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: page-flags behavior on compound pages: a worry
In-Reply-To: <20150807144949.GA12177@node.dhcp.inet.fi>
Message-ID: <alpine.LSU.2.11.1508122112530.4539@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-5-git-send-email-kirill.shutemov@linux.intel.com> <alpine.LSU.2.11.1508052001350.6404@eggly.anvils> <20150806153259.GA2834@node.dhcp.inet.fi>
 <alpine.LSU.2.11.1508061121120.7500@eggly.anvils> <20150807144949.GA12177@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 7 Aug 2015, Kirill A. Shutemov wrote:
> On Thu, Aug 06, 2015 at 12:24:22PM -0700, Hugh Dickins wrote:
> > 
> > Oh, and I know a patchset which avoids these problems completely,
> > by not using compound pages at all ;)
> 
> BTW, I haven't heard anything about the patchset for a while.
> What's the status?

It's gone well, and being put into wider use here.  But I'm not
one for monthly updates of large patchsets myself, always too much
to do; and nobody else seemed anxious to have it yet, back in March.

As I said at the time of posting huge tmpfs against v3.19, it was
fully working (and little changed since), but once memory pressure
had disbanded a team to swap it out, there was nothing to put it
together again later, to restore the original hugepage performance.

I couldn't imagine people putting it into real use while that remained
the case, so spent the next months adding "huge tmpfs recovery" -
considered hooking into khugepaged, but settled on work item queued
from fault.

Which has worked out well, except that I had to rush it in before
I went on vacation in June, then spent last month fixing all the
concurrent hole-punching bugs Andres found with his fuzzing while
I was away.  Busy time, stable now; but I do want to reconsider a
few rushed decisions before offering the rebased and extended set.

And there's three pieces of the work not begun:

The page-table allocation delay in mm/memory.c had been great for
the first posting, but not good enough for recovery (replacing ptes
by pmd): for the moment I skate around that by guarding with mmap_sem,
but mmap_sem usually ends up regrettable, and shouldn't be necessary -
there's just a lot of scattered walks to work through, adjusting them
to racy replacement of ptes by pmd.  Maybe I can get away without
doing this for now, we seem to be working well enough without it.

And I suspect that my queueing a recovery work item from fault
is over eager, needs some stats and knobs to tune it down.  Though
not surfaced as a problem yet; and I don't think we could live with
the opposite extreme, of khugepaged lumbering its way around the vmas.

But the one I think I shall have to do something better about before
posting, is NUMA.  For a confluence of reasons, that rule out swapin
readahead for now, it's not a serious issue for us as yet.  But swapin
readahead and NUMA have always been a joke in tmpfs, and I'll be
amplifying that joke with my current NUMA placement in recovery.
Unfortunately, there's a lot of opportunity to make silly mistakes
when trying to get NUMA right: I doubt I can get it right, but do
need to get it a little less wrong before letting others take over.

> 
> Optimizing rmap operations in my patchset (see PG_double_map), I found
> that it would be very tricky to expand team pages to anon-THP without
> performance regression on rmap side due to amount of atomic ops it
> requires.

Thanks for thinking of it: I've been too busy with the recovery
to put more thought into extending teams to anon THP, though I'd
certainly like to try that once the huge tmpfs end is "complete".

Yes, there's not a doubt that starting from compound pages is more
rigid but should involve much less repetition; whereas starting from
the other end with a team of ordinary 4k pages, more flexible but a
lot of wasted effort.  I can't predict where we shall meet.

> 
> Is there any clever approach to the issue?

I'd been hoping that I could implement first, and then optimize away
the unnecessary; but you're right that it's easier to live with that
in the pagecache case, whereas with anon THP it would be a regression.

Hugh

> 
> Team pages are probably fine for file mappings due different performance
> baseline. I'm less optimistic about anon-THP.
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
