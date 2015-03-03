Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D56916B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 20:47:38 -0500 (EST)
Received: by padbj1 with SMTP id bj1so22956381pad.11
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 17:47:38 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id el10si4825737pdb.159.2015.03.02.17.47.36
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 17:47:37 -0800 (PST)
Date: Tue, 3 Mar 2015 12:47:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150303014733.GL18360@dastard>
References: <20150302010413.GP4251@dastard>
 <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 11:47:52AM -0800, Linus Torvalds wrote:
> On Sun, Mar 1, 2015 at 5:04 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Across the board the 4.0-rc1 numbers are much slower, and the
> > degradation is far worse when using the large memory footprint
> > configs. Perf points straight at the cause - this is from 4.0-rc1
> > on the "-o bhash=101073" config:
> >
> > -   56.07%    56.07%  [kernel]            [k] default_send_IPI_mask_sequence_phys
> >       - 99.99% physflat_send_IPI_mask
> >          - 99.37% native_send_call_func_ipi
> ..
> >
> > And the same profile output from 3.19 shows:
> >
> > -    9.61%     9.61%  [kernel]            [k] default_send_IPI_mask_sequence_phys
> >      - 99.98% physflat_send_IPI_mask
> >          - 96.26% native_send_call_func_ipi
> ...
> >
> > So either there's been a massive increase in the number of IPIs
> > being sent, or the cost per IPI have greatly increased. Either way,
> > the result is a pretty significant performance degradatation.
....
> I assume it's the mm queue from Andrew, so adding him to the cc. There
> are changes to the page migration etc, which could explain it.
> 
> There are also a fair amount of APIC changes in 4.0-rc1, so I guess it
> really could be just that the IPI sending itself has gotten much
> slower. Adding Ingo for that, although I don't think
> default_send_IPI_mask_sequence_phys() itself hasn't actually changed,
> only other things around the apic. So I'd be inclined to blame the mm
> changes.
> 
> Obviously bisection would find it..

Yes, though the time it takes to do a 13 step bisection means it's
something I don't do just for an initial bug report. ;)

Anyway, the difference between good and bad is pretty clear, so
I'm pretty confident the bisect is solid:

4d9424669946532be754a6e116618dcb58430cb4 is the first bad commit
commit 4d9424669946532be754a6e116618dcb58430cb4
Author: Mel Gorman <mgorman@suse.de>
Date:   Thu Feb 12 14:58:28 2015 -0800

    mm: convert p[te|md]_mknonnuma and remaining page table manipulations
    
    With PROT_NONE, the traditional page table manipulation functions are
    sufficient.
    
    [andre.przywara@arm.com: fix compiler warning in pmdp_invalidate()]
    [akpm@linux-foundation.org: fix build with STRICT_MM_TYPECHECKS]
    Signed-off-by: Mel Gorman <mgorman@suse.de>
    Acked-by: Linus Torvalds <torvalds@linux-foundation.org>
    Acked-by: Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>
    Tested-by: Sasha Levin <sasha.levin@oracle.com>
    Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Cc: Dave Jones <davej@redhat.com>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Ingo Molnar <mingo@redhat.com>
    Cc: Kirill Shutemov <kirill.shutemov@linux.intel.com>
    Cc: Paul Mackerras <paulus@samba.org>
    Cc: Rik van Riel <riel@redhat.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

:040000 040000 50985a3f84e80bb2bdd049d4f34739d99436f988 1bc79bfac2c138844373b603f9bc5914f0d010f3 M        arch
:040000 040000 ea69bcd1c59f832a4b012a57b4eb1d0c7516947d 0822692fa6c356952e723b56038585716fa51723 M        include
:040000 040000 c11960b9f1ee72edb08dc3fdc46f590fb1d545f7 f5d17ff5b639adcb7363a196a9efe70f2a7312b5 M        mm

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
