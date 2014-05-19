Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02E166B0037
	for <linux-mm@kvack.org>; Mon, 19 May 2014 19:24:24 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id ma3so6508407pbc.10
        for <linux-mm@kvack.org>; Mon, 19 May 2014 16:24:24 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id ip8si6901448pbc.427.2014.05.19.16.24.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 16:24:24 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so6451534pbc.40
        for <linux-mm@kvack.org>; Mon, 19 May 2014 16:24:23 -0700 (PDT)
Date: Mon, 19 May 2014 16:23:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
In-Reply-To: <53797511.1050409@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1405191531150.1317@eggly.anvils>
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils> <87wqdik4n5.fsf@rustcorp.com.au> <53797511.1050409@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Mon, 19 May 2014, Madhavan Srinivasan wrote:
> On Monday 19 May 2014 05:42 AM, Rusty Russell wrote:
> > Hugh Dickins <hughd@google.com> writes:
> >> On Thu, 15 May 2014, Madhavan Srinivasan wrote:
> >>>
> >>> Hi Ingo,
> >>>
> >>> 	Do you have any comments for the latest version of the patchset. If
> >>> not, kindly can you pick it up as is.
> >>>
> >>>
> >>> With regards
> >>> Maddy
> >>>
> >>>> Kirill A. Shutemov with 8c6e50b029 commit introduced
> >>>> vm_ops->map_pages() for mapping easy accessible pages around
> >>>> fault address in hope to reduce number of minor page faults.
> >>>>
> >>>> This patch creates infrastructure to modify the FAULT_AROUND_ORDER
> >>>> value using mm/Kconfig. This will enable architecture maintainers
> >>>> to decide on suitable FAULT_AROUND_ORDER value based on
> >>>> performance data for that architecture. First patch also defaults
> >>>> FAULT_AROUND_ORDER Kconfig element to 4. Second patch list
> >>>> out the performance numbers for powerpc (platform pseries) and
> >>>> initialize the fault around order variable for pseries platform of
> >>>> powerpc.
> >>
> >> Sorry for not commenting earlier - just reminded by this ping to Ingo.
> >>
> >> I didn't study your numbers, but nowhere did I see what PAGE_SIZE you use.
> >>
> >> arch/powerpc/Kconfig suggests that Power supports base page size of
> >> 4k, 16k, 64k or 256k.
> >>
> >> I would expect your optimal fault_around_order to depend very much on
> >> the base page size.
> > 
> > It was 64k, which is what PPC64 uses on all the major distributions.
> > You really only get a choice of 4k and 64k with 64 bit power.
> > 
> This is true. PPC64 support multiple pagesize and yes the default page
> size of 64k, is taken as base pagesize for the tests.
> 
> >> Perhaps fault_around_size would provide a more useful default?
> > 
> > That seems to fit.  With 4k pages and order 4, you're asking for 64k.
> > Maddy's result shows 64k is also reasonable for 64k pages.
> > 
> > Perhaps we try to generalize from two data points (a slight improvement
> > over doing it from 1!), eg:
> > 
> > /* 4 seems good for 4k-page x86, 0 seems good for 64k page ppc64, so: */
> > unsigned int fault_around_order __read_mostly =
> >         (16 - PAGE_SHIFT < 0 ? 0 : 16 - PAGE_SHIFT);

Rusty's bimodal answer doesn't seem the right starting point to me.

Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
the order of the fault-around size in bytes, and fault_around_pages()
use 1UL << (fault_around_order - PAGE_SHIFT)
- when that doesn't wrap, of course!

That would at least have a better chance of being appropriate for
architectures with 8k and 16k pages (Itanium springs to mind).

Not necessarily right for them, since each architecture may have
different faulting overheads; but a better chance of being right
than blindly assuming 4k or 64k pages for everyone.

I'd be glad to see that change go into v3.15: what do you think,
Kirill, are we too late to make such a change now?
Or do you see some objection to it?

> This may be right. But these are the concerns, will not this make other
> arch to pick default without any tuning

Wasn't FAULT_AROUND_ORDER 4 chosen solely on the basis of x86 4k pages?
Did other architectures, with other page sizes, back that default?
Clearly not powerpc.

> and also this will remove the
> compile time option to disable the feature?

Compile time option meaning your FAULT_AROUND_ORDER in mm/Kconfig
for v3.16?

I'm not sure whether Rusty was arguing against that or not.  I think
we are all three concerned to have a more sensible default than what's
there at present.  I don't feel very strongly about your Kconfig
option: I've no objection, if it were to default to byte order 16.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
