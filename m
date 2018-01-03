Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 535C26B033E
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 05:48:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p190so458995wmd.0
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 02:48:02 -0800 (PST)
Received: from outbound-smtp17.blacknight.com (outbound-smtp17.blacknight.com. [46.22.139.234])
        by mx.google.com with ESMTPS id g31si647307edd.353.2018.01.03.02.48.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 02:48:01 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp17.blacknight.com (Postfix) with ESMTPS id AFD1A1C1503
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 10:48:00 +0000 (GMT)
Date: Wed, 3 Jan 2018 10:48:00 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm/fadvise: discard partial pages iff endbyte is also eof
Message-ID: <20180103104800.xgqe32hv63xsmsjh@techsingularity.net>
References: <1514002568-120457-1-git-send-email-shidao.ytt@alibaba-inc.com>
 <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8DAEE48B-AD5D-4702-AB4B-7102DD837071@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "??????(Caspar)" <jinli.zjl@alibaba-inc.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, green@linuxhacker.ru, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "??????(??????)" <zhiche.yy@alibaba-inc.com>, ?????? <shidao.ytt@alibaba-inc.com>

On Wed, Jan 03, 2018 at 02:53:43PM +0800, ??????(Caspar) wrote:
> 
> 
> > ?? 2017??12??23????12:16?????? <shidao.ytt@alibaba-inc.com> ??????
> > 
> > From: "shidao.ytt" <shidao.ytt@alibaba-inc.com>
> > 
> > in commit 441c228f817f7 ("mm: fadvise: document the
> > fadvise(FADV_DONTNEED) behaviour for partial pages") Mel Gorman
> > explained why partial pages should be preserved instead of discarded
> > when using fadvise(FADV_DONTNEED), however the actual codes to calcuate
> > end_index was unexpectedly wrong, the code behavior didn't match to the
> > statement in comments; Luckily in another commit 18aba41cbf
> > ("mm/fadvise.c: do not discard partial pages with POSIX_FADV_DONTNEED")
> > Oleg Drokin fixed this behavior
> > 
> > Here I come up with a new idea that actually we can still discard the
> > last parital page iff the page-unaligned endbyte is also the end of
> > file, since no one else will use the rest of the page and it should be
> > safe enough to discard.
> 
> +akpm...
> 
> Hi Mel, Andrew:
> 
> Would you please take a look at this patch, to see if this proposal
> is reasonable enough, thanks in advance!
> 

I'm backlogged after being out for the Christmas. Superficially the patch
looks ok but I wondered how often it happened in practice as we already
would discard files smaller than a page on DONTNEED. It also requires
that the system call get the exact size of the file correct and would not
discard if the off + len was past the end of the file for whatever reason
(e.g. a stat to read the size, a truncate in parallel and fadvise using
stale data from stat) and that's why the patch looked like it might have
no impact in practice. Is the patch known to help a real workload or is
it motivated by a code inspection?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
