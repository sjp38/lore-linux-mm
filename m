Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 648B56B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:20:29 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id g62so16676020wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 03:20:29 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id 1si12194286wmy.90.2016.02.11.03.20.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 03:20:28 -0800 (PST)
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 11 Feb 2016 11:20:27 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id C98D62190023
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:20:10 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1BBKPQM15990944
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 11:20:25 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1BBKOMf007131
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:20:24 -0500
Date: Thu, 11 Feb 2016 12:20:23 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 1/2] mm,thp: refactor generic deposit/withdraw routines
 for wider usage
Message-ID: <20160211122023.6d719513@mschwide>
In-Reply-To: <56BC682D.6070808@synopsys.com>
References: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
	<1455182907-15445-2-git-send-email-vgupta@synopsys.com>
	<20160211112223.0acc8237@mschwide>
	<56BC682D.6070808@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 11 Feb 2016 16:23:33 +0530
Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:

> On Thursday 11 February 2016 03:52 PM, Martin Schwidefsky wrote:
> > On Thu, 11 Feb 2016 14:58:26 +0530
> > Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:
> > 
> >> Generic pgtable_trans_huge_deposit()/pgtable_trans_huge_withdraw()
> >> assume pgtable_t to be struct page * which is not true for all arches.
> >> Thus arc, s390, sparch end up with their own copies despite no special
> >> hardware requirements (unlike powerpc).
> > 
> > s390 does have a special hardware requirement. pgtable_t is an address
> > for a 2K block of memory. It is *not* equivalent to a struct page *
> > which refers to a 4K block of memory. That has been the whole point
> > to introduce pgtable_t.
> 
> Actually my reference to hardware requirement was more like powerpc style save a
> hash value some where etc.
> 
> Now pgtable_t need not be struct page * even if the actual sizes are same - e.g.
> in ARC port I kept pgtable_t as pte_t * simply to avoid a few page_address() calls
> in mm code (you could argue that is was a micro-optimization, anyways..)
> 
> So given I know nothing about s390 MMU internals, I still think you can switch to
> the update generic version despite 2K vs. 4K. Agree ?

No, we can not. For s390 a page table is aligned on a 2K boundary and is
only half the size of a page (except for KVM but that is another story).
For s390 a pgtable_t is a pointer to the memory location with the 256 ptes
and not a struct page *.

The cast "struct page *new = (struct page*)pgtable;" in your first patch
is already broken, "new" points to the memory of the page table and
the list_head operations will clobber that memory. You try to fix it up
with the memset to zero in pgtable_trans_huge_withdraw but that does not
correct the pte entries for s390 as an invalid page-table entry is *not*
all zeros.

In short, please let s390 keep its own copy of deposit/withdraw.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
