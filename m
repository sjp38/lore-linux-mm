Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7221E6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:10:29 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so132233000wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:10:29 -0700 (PDT)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id mw8si15292701wic.89.2015.09.21.00.10.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Sep 2015 00:10:28 -0700 (PDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 21 Sep 2015 08:10:27 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8D29A1B0804B
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:12:08 +0100 (BST)
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8L7APNH30801966
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:10:25 GMT
Received: from d06av03.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8L7AOxl013267
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 01:10:25 -0600
Date: Mon, 21 Sep 2015 09:10:33 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150921091033.1799ea40@mschwide>
In-Reply-To: <20150918202109.GE2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
	<1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
	<20150917193152.GJ2000@uranus>
	<20150918085835.597fb036@mschwide>
	<20150918071549.GA2035@uranus>
	<20150918102001.0e0389c7@mschwide>
	<20150918085301.GC2035@uranus>
	<20150918111038.58c3a8de@mschwide>
	<20150918202109.GE2035@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, 18 Sep 2015 23:21:09 +0300
Cyrill Gorcunov <gorcunov@gmail.com> wrote:

> On Fri, Sep 18, 2015 at 11:10:38AM +0200, Martin Schwidefsky wrote:
> > > 
> > > You know, these are only two lines where we use _PAGE_SOFT_DIRTY
> > > directly, so I don't see much point in adding 22 lines of code
> > > for that. Maybe we can leave it as is?
> >  
> > Only x86 has pte_clear_flags. And the two lines require that there is exactly
> > one bit in the PTE for soft-dirty. An alternative encoding will not be allowed.
> 
> Agreed, still I would defer until there is a real need for an alternative encoding.

The s390 support for soft dirty ptes will need it.
 
> > And the current set of primitives is asymmetric, there are functions to query
> > and set the bit pte_soft_dirty and pte_mksoft_dirty but no function to clear
> > the bit.
> 
> Yes, but again I don't see an urgent need for these helpers.
> 
> Anyway, there is no strong objections against this approach
> from my side, but please at least compile-test the patch next
> time, because this is definitely a typo
> 
> static inline pmd_t pmd_clear_soft_dirty(pmd_t pmd)
> {
> 	return pmp_clear_flags(pmd, _PAGE_SOFT_DIRTY);
> }
> 
> I bet you meant pmd_clear_flags.

Yes, the final test is still pending. The patch was more or less for illustrative
purpose. I yet have to do the compile & boot test on an x86 system.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
