Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA986B02B4
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 03:21:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g71so12622387wmg.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 00:21:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q8si1318739wmd.8.2017.07.27.00.21.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 00:21:15 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:21:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170727072113.dpv2nsqaft3inpru@suse.de>
References: <20170725100722.2dxnmgypmwnrfawp@suse.de>
 <20170726054306.GA11100@bbox>
 <20170726092228.pyjxamxweslgaemi@suse.de>
 <A300D14C-D7EE-4A26-A7CF-A7643F1A61BA@gmail.com>
 <20170726234025.GA4491@bbox>
 <60FF1876-AC4F-49BB-BC36-A144C3B6EA9E@gmail.com>
 <20170727003434.GA537@bbox>
 <77AFE0A4-FE3D-4E05-B248-30ADE2F184EF@gmail.com>
 <AACB7A95-A1E1-4ACD-812F-BD9F8F564FD7@gmail.com>
 <20170727070420.GA1052@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170727070420.GA1052@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Thu, Jul 27, 2017 at 04:04:20PM +0900, Minchan Kim wrote:
> > There is one issue I forgot: pte_accessible() on x86 regards
> > mm_tlb_flush_pending() as an indication for NUMA migration. But now the code
> > does not make too much sense:
> > 
> >         if ((pte_flags(a) & _PAGE_PROTNONE) &&
> >                         mm_tlb_flush_pending(mm))
> > 
> > Either we remove the _PAGE_PROTNONE check or we need to use the atomic field
> > to count separately pending flushes due to migration and due to other
> > reasons. The first option is safer, but Mel objected to it, because of the
> > performance implications. The second one requires some thought on how to
> > build a single counter for multiple reasons and avoid a potential overflow.
> > 
> > Thoughts?
> > 
> 
> I'm really new for the autoNUMA so not sure I understand your concern
> If your concern is that increasing places where add up pending count,
> autoNUMA performance might be hurt. Right?
> If so, above _PAGE_PROTNONE check will filter out most of cases?
> Maybe, Mel could answer.

I'm not sure what I'm being asked. In the case above, the TLB flush pending
is only relevant against autonuma-related races so only those PTEs are
checked to limit overhead. It could be checked on every PTE but it's
adding more compiler barriers or more atomic reads which do not appear
necessary. If the check is removed, a comment should be added explaining
why every PTE has to be checked.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
