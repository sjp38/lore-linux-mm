Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7141E6B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:29:59 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id e127so28930930pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:29:59 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id q88si12364149pfa.197.2016.02.11.04.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 04:29:57 -0800 (PST)
Subject: Re: [PATCH 1/2] mm,thp: refactor generic deposit/withdraw routines
 for wider usage
References: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
 <1455182907-15445-2-git-send-email-vgupta@synopsys.com>
 <20160211112223.0acc8237@mschwide> <56BC682D.6070808@synopsys.com>
 <20160211122023.6d719513@mschwide>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56BC7EAE.7070206@synopsys.com>
Date: Thu, 11 Feb 2016 17:59:34 +0530
MIME-Version: 1.0
In-Reply-To: <20160211122023.6d719513@mschwide>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Thursday 11 February 2016 04:50 PM, Martin Schwidefsky wrote:
> On Thu, 11 Feb 2016 16:23:33 +0530
> Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:
> 
>> On Thursday 11 February 2016 03:52 PM, Martin Schwidefsky wrote:
>>> On Thu, 11 Feb 2016 14:58:26 +0530
>>> Vineet Gupta <Vineet.Gupta1@synopsys.com> wrote:
>>>
>>>> Generic pgtable_trans_huge_deposit()/pgtable_trans_huge_withdraw()
>>>> assume pgtable_t to be struct page * which is not true for all arches.
>>>> Thus arc, s390, sparch end up with their own copies despite no special
>>>> hardware requirements (unlike powerpc).
>>>
>>> s390 does have a special hardware requirement. pgtable_t is an address
>>> for a 2K block of memory. It is *not* equivalent to a struct page *
>>> which refers to a 4K block of memory. That has been the whole point
>>> to introduce pgtable_t.
>>
>> Actually my reference to hardware requirement was more like powerpc style save a
>> hash value some where etc.
>>
>> Now pgtable_t need not be struct page * even if the actual sizes are same - e.g.
>> in ARC port I kept pgtable_t as pte_t * simply to avoid a few page_address() calls
>> in mm code (you could argue that is was a micro-optimization, anyways..)
>>
>> So given I know nothing about s390 MMU internals, I still think you can switch to
>> the update generic version despite 2K vs. 4K. Agree ?
> 
> No, we can not. For s390 a page table is aligned on a 2K boundary and is
> only half the size of a page (except for KVM but that is another story).
> For s390 a pgtable_t is a pointer to the memory location with the 256 ptes
> and not a struct page *.
> 
> The cast "struct page *new = (struct page*)pgtable;" in your first patch
> is already broken, "new" points to the memory of the page table and
> the list_head operations will clobber that memory.

The current s390 code does something similar using a different struct cast. It is
still writing in pgtable_t - although at a different location.

> You try to fix it up
> with the memset to zero in pgtable_trans_huge_withdraw but that does not
> correct the pte entries for s390 as an invalid page-table entry is *not*
> all zeros.

Right so that is the problem - just trying to understand.

> In short, please let s390 keep its own copy of deposit/withdraw.

You got it - I'm out of the way :-)

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
