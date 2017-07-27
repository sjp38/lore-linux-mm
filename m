Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD76B6B0496
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:36:19 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u89so36015323wrc.1
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:36:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d43si20307132wrd.85.2017.07.27.10.36.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 10:36:18 -0700 (PDT)
Date: Thu, 27 Jul 2017 18:36:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170727173613.g3vz2dv3fcxrsnf7@suse.de>
References: <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
 <20170726234025.GA4491@bbox>
 <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com>
 <20170727003434.GA537@bbox>
 <77AFE0A4-FE3D-4E05-B248-30ADE2F184EF@gmail.com>
 <AACB7A95-A1E1-4ACD-812F-BD9F8F564FD7@gmail.com>
 <20170727070420.GA1052@bbox>
 <20170727072113.dpv2nsqaft3inpru@suse.de>
 <68D28CCA-10CC-48F8-A38F-B682A98A4BA5@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <68D28CCA-10CC-48F8-A38F-B682A98A4BA5@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Thu, Jul 27, 2017 at 09:04:11AM -0700, Nadav Amit wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Thu, Jul 27, 2017 at 04:04:20PM +0900, Minchan Kim wrote:
> >>> There is one issue I forgot: pte_accessible() on x86 regards
> >>> mm_tlb_flush_pending() as an indication for NUMA migration. But now the code
> >>> does not make too much sense:
> >>> 
> >>>        if ((pte_flags(a) & _PAGE_PROTNONE) &&
> >>>                        mm_tlb_flush_pending(mm))
> >>> 
> >>> Either we remove the _PAGE_PROTNONE check or we need to use the atomic field
> >>> to count separately pending flushes due to migration and due to other
> >>> reasons. The first option is safer, but Mel objected to it, because of the
> >>> performance implications. The second one requires some thought on how to
> >>> build a single counter for multiple reasons and avoid a potential overflow.
> >>> 
> >>> Thoughts?
> >> 
> >> I'm really new for the autoNUMA so not sure I understand your concern
> >> If your concern is that increasing places where add up pending count,
> >> autoNUMA performance might be hurt. Right?
> >> If so, above _PAGE_PROTNONE check will filter out most of cases?
> >> Maybe, Mel could answer.
> > 
> > I'm not sure what I'm being asked. In the case above, the TLB flush pending
> > is only relevant against autonuma-related races so only those PTEs are
> > checked to limit overhead. It could be checked on every PTE but it's
> > adding more compiler barriers or more atomic reads which do not appear
> > necessary. If the check is removed, a comment should be added explaining
> > why every PTE has to be checked.
> 
> I considered breaking tlb_flush_pending to two: tlb_flush_pending_numa and
> tlb_flush_pending_other (they can share one atomic64_t field). This way,
> pte_accessible() would only consider ???tlb_flush_pending_numa", and the
> changes that Minchan proposed would not increase the number unnecessary TLB
> flushes.
> 
> However, considering the complexity of the TLB flushes scheme, and the fact
> I am not fully convinced all of these TLB flushes are indeed unnecessary, I
> will put it aside.
> 

Ok, I understand now. With a second set/clear of mm_tlb_flush_pending,
it is necessary to remove the PROT_NUMA check from pte_accessible because
it's no longer change_prot_range that is the only user of concern. At
this time, I do not see a value if adding two pending field because it's
a maintenance headache and an API that would be harder to get right. It's
also not clear it would add any performance advantage and even if it did,
it's the type of complexity that would need hard data supporting it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
