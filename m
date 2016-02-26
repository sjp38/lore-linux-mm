Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5316B0005
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 15:46:32 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so85412686wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 12:46:32 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id gi1si17904271wjd.61.2016.02.26.12.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 12:46:31 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 8A5A81C2150
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 20:46:30 +0000 (GMT)
Date: Fri, 26 Feb 2016 20:46:28 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/1] mm: thp: Redefine default THP defrag behaviour
 disable it by default
Message-ID: <20160226204628.GC2854@techsingularity.net>
References: <1456420339-29709-1-git-send-email-mgorman@techsingularity.net>
 <20160225190144.GE1180@redhat.com>
 <20160225195613.GZ2854@techsingularity.net>
 <20160225230219.GF1180@redhat.com>
 <20160226111316.GB2854@techsingularity.net>
 <20160226195015.GK1180@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160226195015.GK1180@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Feb 26, 2016 at 08:50:15PM +0100, Andrea Arcangeli wrote:
> Hello Mel,
> 
> On Fri, Feb 26, 2016 at 11:13:16AM +0000, Mel Gorman wrote:
> > 1. By default, "madvise" and direct reclaim/compaction for applications
> >    that specifically requested that behaviour. This will avoid breaking
> >    MADV_HUGEPAGE which you mentioned in a few places
> 
> Defragging memory synchronously only under madvise is fine with me.
> 

I think this is a sensible default though. As you pointed out, those
applications specifically requested it and a delay *should* be acceptable. If
not, then it's a one-liner to change the behaviour.

> > 2. "never" will never reclaim anything and was the default behaviour of
> >    version 1 but will not be the default in version 2.
> > 3. "defer" will wake kswapd which will reclaim or wake kcompactd
> >    whichever is necessary. This is new but avoids stalls while helping
> >    khugepaged do its work quickly in the near future.
> 
> This is an kABI visible change, but it should be ok. I'm not aware of
> any program that parses that file and could get confused.
> 

Neither am I but it'll be a wait and see approach unfortunately to see do
I get the dreaded "you broke an ABI that applications depend upon" report.

> "defer" sounds an interesting default option if it could be made to
> work better.
> 

I was tempted to set it but given that there was a host of reclaim-related
bugs recently I backed off. For example, the last three releases has a
serious bug whereby NUMA machines swapped heavily and no one reported it
(or I missed it).  There is still one excessive reclaiming bug open that
has a potential patch that hasn't been tested so that's still an issue. I
didn't want to muddy the waters further.

> > 4. "always" will direct reclaim/compact just like todays behaviour
> 
> I suspect there are a number of apps that took advantage of the
> "always" setting without realizing it, but we only could notice the
> ones that don't.

Agreed but in itself, it'll be interesting to see if anyone notices.  With
the new default, applications still get huge pages in a lot of cases. It'll
be interesting to report if someone complains about long-term behaviour where
THP utilisation is lower for periods of time until khugepaged recovers it.

> In any case those apps can start to call
> MADV_HUGEPAGE if they don't already and that will provide a definitive
> fix.

Yes or else they set the tunable to always and carry on.

> With this approach MADV_HUGEPAGE will provide the same
> reliability in allocation as before so there will be no problem then.
> 

Yes.

As I believe your concerns have been addressed, can I get an ack on
this patch?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
