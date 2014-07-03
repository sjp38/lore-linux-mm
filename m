Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 165836B0035
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 04:29:07 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id w62so12215384wes.24
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 01:29:07 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id ej1si6626646wib.87.2014.07.03.01.29.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 01:29:07 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 3 Jul 2014 09:29:06 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 36DF21B08041
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 09:29:40 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s638T4J229163530
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 08:29:04 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s638T3Bc019047
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 02:29:04 -0600
Date: Thu, 3 Jul 2014 10:29:01 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v9] mm: support madvise(MADV_FREE)
Message-ID: <20140703102901.322bfdb0@mschwide>
In-Reply-To: <20140703072954.GC2939@bbox>
References: <1404174975-22019-1-git-send-email-minchan@kernel.org>
	<20140701145058.GA2084@node.dhcp.inet.fi>
	<20140703010318.GA2939@bbox>
	<20140703072954.GC2939@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Thu, 3 Jul 2014 16:29:54 +0900
Minchan Kim <minchan@kernel.org> wrote:

> Hello,
> 
> On Thu, Jul 03, 2014 at 10:03:19AM +0900, Minchan Kim wrote:
> > Hello,
> > 
> > On Tue, Jul 01, 2014 at 05:50:58PM +0300, Kirill A. Shutemov wrote:
> > > On Tue, Jul 01, 2014 at 09:36:15AM +0900, Minchan Kim wrote:
> > > > +	do {
> > > > +		/*
> > > > +		 * XXX: We can optimize with supporting Hugepage free
> > > > +		 * if the range covers.
> > > > +		 */
> > > > +		next = pmd_addr_end(addr, end);
> > > > +		if (pmd_trans_huge(*pmd))
> > > > +			split_huge_page_pmd(vma, addr, pmd);
> > > 
> > > Could you implement proper THP support before upstreaming the feature?
> > > It shouldn't be a big deal.
> > 
> > Okay, Hope to review.
> > 
> > Thanks for the feedback!
> > 
> 
> I tried to implement it but had a issue.
> 
> I need pmd_mkold, pmd_mkclean for MADV_FREE operation and pmd_dirty for
> page_referenced. When I investigate all of arches supported THP,
> it's not a big deal but s390 is not sure to me who has no idea of
> soft tracking of s390 by storage key instead of page table information.
> Cced s390 maintainer. Hope to help.

Storage key for dirty and referenced tracking is a thing of the past.
The current code for s390 uses software tracking for dirty and referenced.
There is one catch though, for ptes the software implementation covers
dirty and referenced bit but for pmds only referenced bit is available.
The reason is that there is no free bit left in the pmd entry for the
software dirty bit.
 
> So, if there isn't any help from s390, I should introduce
> HAVE_ARCH_THP_MADVFREE to disable MADV_FREE support of THP in s390 but
> not want to introduce such new config.

Why is the dirty bit for pmds needed for the MADV_FREE implementation?

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
