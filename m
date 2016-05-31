Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79CE06B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 06:14:00 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so96659543lbn.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 03:14:00 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v1si32731210wjp.44.2016.05.31.03.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 03:13:59 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 7BCC51C370E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:13:58 +0100 (IST)
Date: Tue, 31 May 2016 11:13:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0 (was: Re: mm,
 page_alloc: avoid looking up the first zone in a zonelist twice)
Message-ID: <20160531101356.GS2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <CAMuHMdWioTRo1PGymqCEv+3CoQYH8qnhP2T__orSbMw1q-CBMA@mail.gmail.com>
 <20160530185616.GQ2527@techsingularity.net>
 <CAMuHMdXCN5LeNCNJ9=B5sGAtdd81JeRNrUMSCOjSL_Bx1-tDvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAMuHMdXCN5LeNCNJ9=B5sGAtdd81JeRNrUMSCOjSL_Bx1-tDvA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Tue, May 31, 2016 at 11:28:05AM +0200, Geert Uytterhoeven wrote:
> Hi Mel,
> 
> On Mon, May 30, 2016 at 8:56 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > Thanks. Please try the following instead
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index bb320cde4d6d..557549c81083 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3024,6 +3024,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
> >                 apply_fair = false;
> >                 fair_skipped = false;
> >                 reset_alloc_batches(ac->preferred_zoneref->zone);
> > +               z = ac->preferred_zoneref;
> >                 goto zonelist_scan;
> >         }
> 
> Thanks a lot, that seems to fix the issue!.
> 
> Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> 
> JFTR, without the fix, sometimes I get a different, but equally obscure, crash
> than the one I posted before:
> 

I'm afraid I don't recognise it. Given the nature of the previous bug
though, I have a vague suspicion that someone is not handling a page
allocation failure properly and goes boom later.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
