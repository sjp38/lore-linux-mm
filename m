Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 458CF280244
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 06:34:53 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id e128so736217wmg.1
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 03:34:53 -0800 (PST)
Received: from outbound-smtp20.blacknight.com (outbound-smtp20.blacknight.com. [46.22.139.247])
        by mx.google.com with ESMTPS id l51si1255962edc.306.2018.01.04.03.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 03:34:52 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp20.blacknight.com (Postfix) with ESMTPS id A9E9A1C2291
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 11:34:51 +0000 (GMT)
Date: Thu, 4 Jan 2018 11:34:51 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
Message-ID: <20180104113451.j7dwal6mxbelt4p4@techsingularity.net>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
 <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
 <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <7dd95219-f0be-b30a-0a43-2aadcc61899c@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "??????(Caspar)" <jinli.zjl@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "??????(??????)" <zhiche.yy@alibaba-inc.com>, ?????? <shidao.ytt@alibaba-inc.com>

On Thu, Jan 04, 2018 at 02:13:43PM +0800, ??????(Caspar) wrote:
> 
> 
> On 2018/1/3 18:48, Mel Gorman wrote:
> > On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
> > > 
> > > 
> > > > ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
> > > > 
> > > > From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
> > > > 
> > > > in commit 441c228f817f7 ("mm: fadvise: document the
> > > > fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
> > > > explained why partial pages should be preserved instead of discarded
> > > > when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
> > > > end_index was unexpectedly wrong, the code behavior didn't match to the
> > > > statement in comments; Luckily in another commit 18aba41cbf
> > > > ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
> > > > Oleg Drokin fixed this behavior
> > > > 
> > > > Here I come up with a new idea that actually we can still discard the
> > > > last parital page iff the page-unaligned endbyte is also the end of
> > > > file, since no one else will use the rest of the page and it should be
> > > > safe enough to discard.
> > > 
> > > +akpm...
> > > 
> > > Hi Mel, Andrew:
> > > 
> > > Would you please take a look at this patch, to see if this proposal
> > > is reasonable enough, thanks in advance!
> > > 
> > 
> > I'm backlogged after being out for the Christmas. Superficially the patch
> > looks ok but I wondered how often it happened in practice as we already
> > would discard files smaller than a page on DONTNEED. It also requires
> 
> Actually, we would *not*. Let's look into the codes.
> 

You're right of course. I suggest updating the changelog with what you
found and the test case. I think it's reasonable to special case the
discarding of partial pages if it's the end of a file with the potential
addendum of checking if the endbyte is past the end of the file. The man
page should also be updated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
